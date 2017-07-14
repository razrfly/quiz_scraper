# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "quiz_scraper/version"

Gem::Specification.new do |spec|
  spec.name          = "quiz_scraper"
  spec.version       = QuizScraper::VERSION
  spec.authors       = ["Rafał Tchórzewski"]
  spec.email         = ["tchorzewski.rafal@gmail.com"]
  spec.summary       = "Scraper for publicly accessible data from pub quizzes "\
                       "related sites."
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/razrfly/quiz_scraper"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_dependency "nokogiri", "~> 1.8.0"
  spec.add_dependency "httparty", "~> 0.15.5"
  spec.add_dependency "activesupport", "~> 5.0"
end
