source 'https://rubygems.org'

gem 'rails', '~> 4.2.7'

gem 'unicorn', '~> 5.0.0'

if ENV['SLIMMER_DEV']
  gem 'slimmer', path: '../slimmer'
else
  gem 'slimmer', '~> 10.1.1'
end
gem 'plek', '~> 1.12.0'

gem 'gds-api-adapters', '~> 46.0'
gem 'govuk_frontend_toolkit', '~> 6.0.3'
gem 'govuk-content-schema-test-helpers', '~> 1.4.0'
gem 'govuk_navigation_helpers', '~> 6.2'
gem 'govuk_ab_testing', '~>2.3'
gem 'sass-rails', '5.0.6'
gem 'govuk_elements_rails', '~> 3.0.0'

gem 'logstasher', '0.6.5'
gem 'airbrake', '~> 4.3.0'
gem 'rack_strip_client_ip', '0.0.1'

gem 'uglifier', '~> 2.7', '>= 2.7.2'

group :development, :test do
  gem 'capybara'
  gem 'poltergeist'
  gem 'rspec-rails', '~> 3.6.0'
  gem 'simplecov-rcov', '0.2.3', require: false
  gem 'ci_reporter_rspec', '~> 1.0.0'
  gem 'webmock', '~> 1.24.2', require: false
  gem 'timecop', '~> 0.8.0'
  gem 'govuk-lint', '0.8.1'
  gem 'pry-byebug'
  gem 'better_errors', '~>2.1'
  gem 'binding_of_caller', '~>0.7'
end
