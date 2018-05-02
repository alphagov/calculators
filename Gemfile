source 'https://rubygems.org'

ruby File.read('.ruby-version').chomp

gem 'rails', '~> 5.2.0'

gem 'gds-api-adapters', '~> 52.5.1'
gem 'govuk_app_config', '~> 1.4.2'
gem 'govuk_elements_rails', '~> 3.1.2'
gem 'govuk_frontend_toolkit', '~> 7.5.0'
gem 'govuk_publishing_components', '~> 7.0.0'
gem 'govuk-content-schema-test-helpers', '~> 1.6.1'
gem 'nokogiri'
gem 'plek', '~> 2.1.1'
gem 'rack_strip_client_ip', '0.0.2'
gem 'sass-rails', '5.0.7'
gem 'slimmer', '~> 12.1.0'
gem 'uglifier', '~> 4.1'

group :development do
  gem 'better_errors', '~>2.1'
  gem 'binding_of_caller', '~>0.8'
  gem 'web-console', '>= 3.3.0'
end

group :development, :test do
  gem 'timecop', '~> 0.9.1'
  gem 'govuk-lint', '3.8.0'
  gem 'pry-byebug'
  gem 'listen', '~> 3.1.5'
  gem 'rspec-rails', '~> 3.7.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'poltergeist'
  gem 'capybara', '~> 2.18.0'
  gem 'rails-controller-testing', '~> 1.0.2'
  gem 'simplecov-rcov', '0.2.3', require: false
  gem 'ci_reporter_rspec', '~> 1.0.0'
  gem 'webmock', '~> 3.4.1', require: false
end
