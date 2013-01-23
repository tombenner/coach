module Coach
  class RulesClassifier
    attr_reader :options

    def initialize(options={})
      @options = options
      @words_categories_weights = {}
      @categories_required_words = {}
      @config = read_config
      @stemmer = Lingua::Stemmer.new(:language => "en")
      init_words_categories_weights
      init_categories_required_words
    end
    
    def init_words_categories_weights
      @words_categories_weights = {}
      @config.each do |category, category_config|
        category = category.to_sym
        category_config.each do |weight, words|
          next if words.blank?
          weight = weight.to_sym
          next if weight == :required
          weight_value = @options[:weight_classes][weight]
          raise "Weight value not found for weight \"#{weight}\"" if weight_value.nil?
          words.each do |word|
            word = get_stem(word)
            @words_categories_weights[word] = {} if @words_categories_weights[word].blank?
            if @words_categories_weights[word][category].nil?
              @words_categories_weights[word][category] = weight_value
            else
              @words_categories_weights[word][category] += weight_value
            end
          end
        end
      end
    end

    def init_categories_required_words
      @categories_required_words = {}
      @config.each do |category, category_config|
        if category_config.has_key?(:required)
          words = category_config[:required]
          words = [words] unless words.is_a?(Array)
          words.collect! { |word| get_stem(word) }
          @categories_required_words[category] = words
        else
          @categories_required_words[category] = [get_stem(category.to_s)]
        end
      end
    end
    
    def scores(text)
      words = words(text)
      categories = []
      @categories_required_words.each do |category, required_words|
        if (words & required_words).length > 0
          categories << category
        end
      end
      category_probabilities = {}
      words.each do |word|
        next if @words_categories_weights[word].blank?
        @words_categories_weights[word].each do |category, weight|
          next unless categories.include?(category)
          if category_probabilities[category].nil?
            category_probabilities[category] = weight
          else
            category_probabilities[category] += weight
          end
        end
      end
      category_probabilities
    end

    def words(text)
      text = text.gsub("'", '').gsub(/[^\w]+/, ' ')
      text.split.collect { |word| get_stem(word) }
    end

    def get_stem(word)
      @options[:stemming] ? @stemmer.stem(word).downcase : word.downcase
    end

    def read_config
      config = YAML.load(File.read(@options[:config]))
      config = config.symbolize_keys
      config.each do |category, weight_words|
        config[category] = weight_words.symbolize_keys
      end
      config = merge_modules_in_config(config)
      config
    end

    def merge_modules_in_config(config)
      config.each do |category, weight_words|
        if weight_words.has_key?(:modules)
          weight_words[:modules] = [weight_words[:modules]] unless weight_words[:modules].is_a?(Array)
          weight_words[:modules].each do |module_key|
            module_key = module_key.to_sym
            config[category] = merge_module_config_into_category_config(config[category], config[:modules][module_key])
          end
          config[category].delete(:modules)
        end
      end
      config.delete(:modules)
      config
    end

    def merge_module_config_into_category_config(category_config, module_config)
      module_config.each do |key, value|
        if category_config[key].blank?
          category_config[key] = module_config[key]
        else
          category_config[key] += module_config[key]
        end
      end
      category_config
    end
  end
end