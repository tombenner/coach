$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "coach/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "coach"
  s.version     = Coach::VERSION
  s.authors     = ["Tom Benner"]
  s.email       = ["tombenner@gmail.com"]
  s.homepage    = "https://github.com/tombenner/coach"
  s.summary     = "A highly tunable classifier (Bayes classification & explicit rules)"
  s.description = "A highly tunable classifier (Bayes classification & explicit rules)"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.11"
  s.add_dependency "stuff-classifier"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails"
end
