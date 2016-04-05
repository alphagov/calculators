require 'capybara/rails'
require 'capybara/rspec'

require 'capybara/poltergeist'

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, phantomjs_options: ['--ssl-protocol=TLSv1'])
end

Capybara.javascript_driver = :poltergeist
