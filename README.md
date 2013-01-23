Coach
=====
A highly tunable classifier (Bayes classification & explicit rules)

Description
-----------

Coach makes predictions by merging the predictions from explicitly written rules and a naive Bayes classifier. The influence of each of these two prediction methods can be adjusted or turned off entirely. Coach aims to solve the problem of how traditional classifiers take a great deal of training before learning basic associations that humans already know.

A naive Bayes classifier takes a lot of training before it has a strong understanding that the word "lions" refers to two different topics in the following texts, even though the difference is obvious to humans:

    Hope to see some dope lions at the zoo today!
    Hope the Lions get some dope draft picks today!

With Coach, you can set explicit rules in YAML to make the classifier more acutely aware of this difference. If you only wanted to match the Lions team, you could use:

    lions:
      positive:
        - detroit
        - draft
        - michigan
      negative:
        - africa
        - animal
        - zoo

*(If you were also interested in the animals, you could also specify rules for `lions_animal`.)*

Coach is highly configurable; see the Rules and Options sections below for more.

Installation
------------

Add coach to your Gemfile:

    gem 'coach', :git => 'git://github.com/tombenner/coach.git'

Usage
-----

Create `config/coach.yml` and write your rules. Use modules to hold rules that can be used in multiple categories:

    modules:
      nfl:
        positive:
          - draft
          - nfl
          - team
        negative:
          - cfl
    lions:
      modules: nfl
      positive:
        - detroit
        - michigan
      negative:
        - africa
        - animal
        - zoo

Set up the classifier:

    classifier = Coach::Classifier.new

Training is optional (without training, predictions will be based solely on the written rules):

    classifier.train(:lions, "Lions have hired John Bonamego as their new special-teams coordinator.")
    classifier.train(:lions, "The NFL Draft should offer the Detroit #Lions plenty of options at running back")
    classifier.train(:lions, "Denard Robinson hopes to get drafted by the Lions because he wants to stay in Michigan.")
    classifier.train(:jaguars, "Jaguars hire Mike Mallory as special teams coordinator")
    classifier.train(:jaguars, "Gus Bradley officially announced as Jaguars Head Coach.")

Classify texts:

    classifier.classify("Hope the Lions get some dope draft picks today!")
    # [:lions]
    classifier.classify("Hope to see some dope lions at the zoo today!")
    # []

The second text is correctly not categorized as `:lions` because of the negative `zoo` rule in `coach.yml`. Dope indeed!

Methods
-------

#### train(category, text)

Trains the Bayes classifier.

#### classify(text)

Returns an array of the estimated categories that have a score above the threshold specified in the options (see Options).

#### scores(text)

Returns a hash of the raw scores for the estimated categories.

#### all_scores(text)

Returns a hash of all of types of scores that were computed (Bayes, rules, composite). The composite score is the final score.

#### set_option

Change the value of an option (see Options below).

Options
-------

You can set options while instantiating the classifier. The default options are:

    classifier = Coach::Classifier.new(
      :config => File.join(Rails.root, 'config', 'coach.yml'),
      :stemming => true,
      :threshold => 0.5,
      :weight_classes => {
        :positive => 1,
        :negative => -1
      },
      :weight_bayes => 1,
      :weight_rules => 1
    )

#### config

The path of the YAML rules file.

#### stemming

Whether or not word stemming is used.

#### threshold

The minimum score necessary for an estimated category to be returned in `Coach::Classifier#classify`.

#### weight_classes

A hash of the types of weights used in the config file and their values.

#### weight_bayes

The influence of the Bayes prediction on the final prediction. Set to 0 to bypass the Bayes classifier and only use the rules in the config file.

#### weight_rules

The influence of the rules prediction (based on the config file's rules) on the final prediction. Set to 0 to bypass the rules classifier and only use the Bayes classifier.

Rules
-----

### Syntax

An example rules file looks like this:

    modules:
      nfl:
        positive:
          - draft
          - nfl
          - team
        negative:
          - cfl
      not_animal:
        negative:
          - animal
          - zoo
    lions:
      modules:
        - nfl
        - not_animal
      positive:
        - detroit
        - michigan
      negative:
        - africa
    vikings:
      modules: nfl
      positive:
        - minneapolis
        - minnesota
      negative:
        - ship

By default, a text won't match a category unless the text contains the category name. If you want to change this (or use IDs as the keys for categories), you can use `required:`:

    lions_nfl:
      required: lions
      positive:
        - detroit
        - michigan

You can also require multiple words:

    lions_nfl:
      required:
        - detroit
        - lions

### Custom Weight Classes

Custom weight classes can provide greater control over how influential different words are:

    lions:
      very_positive:
        - nfl
      positive:
        - detroit
      very_negative:
        - nittany

You specify the weights' values when setting up the classifier:

    classifier = Coach::Classifier.new(
      :weight_classes => {
        :very_positive => 10,
        :positive => 1,
        :negative => -1,
        :very_negative => -10
      }
    )

License
-------

Coach is released under the MIT License. Please see the MIT-LICENSE file for details.