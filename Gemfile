source 'https://rubygems.org'

gem 'rails', '~> 4.2.7'

gem 'unicorn', '~> 5.0.0'

if ENV['SLIMMER_DEV']
  gem 'slimmer', path: '../slimmer'
else
  gem 'slimmer', '~> 10.0.0'
end
gem 'plek', '~> 1.12.0'

gem 'gds-api-adapters', '~> 37.1.0'
gem 'govuk_frontend_toolkit', '~> 4.9.1'
gem 'govuk-content-schema-test-helpers', '~> 1.4.0'
gem 'govuk_navigation_helpers', '~> 2.0.0'
gem 'sass-rails', '5.0.4'

gem 'logstasher', '0.6.5'
gem 'airbrake', '~> 4.3.0'
gem 'rack_strip_client_ip', '0.0.1'

gem 'uglifier', '~> 2.7', '>= 2.7.2'

group :development, :test do
  gem 'rspec-rails', '~> 3.4.0'
  gem 'capybara', '~> 2.6.2'
  gem 'simplecov-rcov', '0.2.3', require: false
  gem 'ci_reporter_rspec', '~> 1.0.0'
  gem 'webmock', '~> 1.24.2', require: false
  gem 'timecop', '~> 0.8.0'
  gem 'poltergeist', '1.6.0'
  gem 'govuk-lint', '0.8.1'
  gem 'pry-byebug'
end
