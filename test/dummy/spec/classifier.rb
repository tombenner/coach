require 'spec_helper'

describe Coach::Classifier do
  before(:each) do
    @positive_records = [
      [:lions, "Lions have hired John Bonamego as their new special-teams coordinator. Native of Mt. Pleasant who played at Central Michigan."],
      [:lions, "The NFL Draft should offer the Detroit #Lions plenty of options at running back"],
      [:lions, "Denard Robinson says he hopes to get drafted by the Lions because he wants to stay in Michigan."],
    ]
    @negative_records = [
      [nil, "#Marineland told bring in marine mammal ophthalmologist to deal with eye issues among seals, walruses and sea lions"],
      [nil, "what is snakes on a plane about? worth a watch?? think its about a pride of lions on the african plane, apparently"],
      [nil, "According to a source, the BC Lions have cut receiver Arland Bruce. #cfl #Lions"],
    ]
    @records = @positive_records + @negative_records

    @classifier = Coach::Classifier.new
    @positive_records.each do |record|
      @classifier.train(record[0], record[1])
    end
  end

  describe ".all_scores" do
    # This is just for debugging purposes
    it "inspects scores" do
      @records.each do |record|
        puts "\n#{record[1]}"
        puts @classifier.all_scores(record[1]).to_yaml
      end
    end
  end

  describe ".classify" do
    it "classifies correctly" do
      @positive_records.each do |record|
        @classifier.classify(record[1]).should =~ [:lions]
      end

      @negative_records.each do |record|
        @classifier.classify(record[1]).should == []
      end
    end
  end

  describe ".scores" do
    it "reduces the composite scores with negative scores from the rules classifier" do
      @classifier.set_option(:weight_rules, 0)
      bayesian_categories = @classifier.scores("All I want to do is go to Africa and play with all the baby tigers and baby lions. Is that so much to ask for?")
      @classifier.set_option(:weight_rules, 1)
      composite_categories = @classifier.scores("All I want to do is go to Africa and play with all the baby tigers and baby lions. Is that so much to ask for?")
      bayesian_categories[:lions].should be > composite_categories[:lions]
    end
  end
end