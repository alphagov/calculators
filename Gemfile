source 'https://rubygems.org'

gem 'rails', '4.2.5.1'

gem 'unicorn', '4.6.2'

if ENV['SLIMMER_DEV']
  gem 'slimmer', :path => '../slimmer'
else
  gem 'slimmer', '9.0.0'
end
gem 'plek', '1.3.1'

gem 'gds-api-adapters', '~> 26.7'
gem 'govuk_frontend_toolkit', '0.41.1'
gem 'govuk-content-schema-test-helpers', '~> 1.3.0'
gem 'sass-rails', '5.0.3'

gem 'logstasher', '0.4.8'
gem 'airbrake', '~> 4.3.0'
gem 'rack_strip_client_ip', '0.0.1'

gem 'uglifier', '~> 2.7', '>= 2.7.2'

group :development, :test do
  gem 'rspec-rails', '~> 3.4.0'
  gem 'capybara', '~> 2.6.2'
  gem 'simplecov-rcov', '0.2.3', :require => false
  gem 'ci_reporter_rspec', '~> 1.0.0'
  gem 'webmock', '~> 1.24.2', :require => false
  gem 'timecop', '~> 0.8.0'
  gem 'poltergeist', '1.6.0'
  gem 'rubocop'
end
