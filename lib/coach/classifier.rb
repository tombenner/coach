module Coach
  class Classifier
    def initialize(options={})
      defaults = {
        :config => File.join(Rails.root, 'config', 'coach.yml'),
        :stemming => true,
        :threshold => 0.5,
        :weight_classes => {
          :positive => 1,
          :negative => -1
        },
        :weight_bayes => 1,
        :weight_rules => 1
      }
      @options = defaults.merge(options)
      @bayes_classifier = BayesClassifier.new(@options)
      @rules_classifier = RulesClassifier.new(@options)
    end

    def set_option(key, value)
      @options[key] = value
    end

    def train(category, text)
      @bayes_classifier.train(category, text)
    end

    def classify(text)
      scores = scores(text)
      categories = []
      scores.each do |category, score|
        categories << category if score > @options[:threshold]
      end
      categories
    end
    
    def scores(text)
      bayes_scores = bayes_scores(text)
      rules_scores = rules_scores(text)
      composite_scores(bayes_scores, rules_scores)
    end

    def all_scores(text)
      bayes_scores = bayes_scores(text)
      rules_scores = rules_scores(text)
      {
        :bayes => bayes_scores,
        :rules => rules_scores,
        :composite => composite_scores(bayes_scores, rules_scores)
      }
    end

    def bayes_scores(text)
      scores = @options[:weight_bayes] == 0 ? {} : @bayes_classifier.scores(text)
      scores.each do |key, value|
        scores[key] = value * @options[:weight_bayes]
      end
      scores
    end

    def rules_scores(text)
      scores = @options[:weight_rules] == 0 ? {} : @rules_classifier.scores(text)
      scores.each do |key, value|
        scores[key] = value * @options[:weight_rules]
      end
      scores
    end

    def composite_scores(bayes_scores, rules_scores)
      scores = rules_scores.dup
      bayes_scores.each do |category, bayes_score|
        next if bayes_score < 0.00001
        if scores[category].blank?
          scores[category] = bayes_score * @options[:weight_bayes]
        else
          scores[category] = scores[category] * @options[:weight_rules] + bayes_score * @options[:weight_bayes]
        end
      end
      scores
    end 
  end
end