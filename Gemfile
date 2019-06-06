source 'https://rubygems.org'

ruby File.read('.ruby-version').chomp

gem 'rails', '~> 5.2.3'

gem 'gds-api-adapters', '~> 59.4.0'
gem 'govuk_app_config', '~> 1.18.1'
gem 'govuk_elements_rails', '~> 3.1.3'
gem 'govuk_frontend_toolkit', '~> 8.2.0'
gem 'govuk_publishing_components', '~> 16.29.0'
gem 'govuk-content-schema-test-helpers', '~> 1.6.1'
gem 'nokogiri'
gem 'plek', '~> 3.0.0'
gem 'rack_strip_client_ip', '0.0.2'
gem 'sass-rails', '5.0.7'
gem 'slimmer', '~> 13.1.0'
gem 'uglifier', '~> 4.1'

group :development do
  gem 'better_errors', '~>2.5'
  gem 'binding_of_caller', '~>0.8'
  gem 'web-console', '>= 3.3.0'
end

group :development, :test do
  gem 'timecop', '~> 0.9.1'
  gem 'govuk-lint', '3.11.2'
  gem 'pry-byebug'
  gem 'listen', '~> 3.1.5'
  gem 'rspec-rails', '~> 3.8.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'ci_reporter_rspec', '~> 1.0.0'
  gem 'govuk_test'
  gem 'launchy'
  gem 'rails-controller-testing', '~> 1.0.4'
  gem 'simplecov', require: false
  gem 'webmock', '~> 3.6.0', require: false
end
