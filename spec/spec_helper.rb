# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'

# Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}


# Fixtures

ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"
ActiveRecord::Migration.verbose = false
load 'db/schema.rb'
require 'db/models'
require 'db/seeds'

# Locales

I18n.locale = :en
I18n.default_locale = :en
I18n.load_path = Dir["spec/locales/lang_spec.yml"]


RSpec.configure do |config|

  config.mock_with :rspec

end
