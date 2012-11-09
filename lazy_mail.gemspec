$:.push File.expand_path("../lib", __FILE__)

require "lazy_mail/version"

Gem::Specification.new do |s|
  s.name        = "lazy_mail"
  s.version     = LazyMail::VERSION
  s.authors     = ["thomas floch"]
  s.email       = ["thomas.floch@gmail.com"]
  s.homepage    = "http://github.com/arkes/lazy_mail"
  s.summary     = "A lazy and quick way to use the function mail"
  s.description = "lazy_mail is a lazy and quick way to use the function mail and offers configurations to write less code"

  s.files = Dir["{lib,spec}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", ">= 3.0.0"

  s.add_development_dependency "rails", "~> 3.2"
  s.add_development_dependency 'rspec-rails', '~> 2.11.4'
  s.add_development_dependency 'sqlite3-ruby', '~> 1.3.3'
  
  s.required_rubygems_version = ">= 1.3.4"
end