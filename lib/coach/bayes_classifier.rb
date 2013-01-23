module Coach
  class BayesClassifier
    def initialize(options={})
      defaults = {
        :stemming => true
      }
      @options = defaults.merge(options)
      @classifier = ::StuffClassifier::Bayes.new(nil, :stemming => @options[:stemming])
    end

    def train(category, text)
      @classifier.train(category, text)
    end

    def scores(text)
      scores_array_to_hash(@classifier.cat_scores(text))
    end

    def scores_array_to_hash(scores)
      hash = {}
      scores.each do |score|
        hash[score[0]] = score[1]
      end
      hash
    end
  end
end