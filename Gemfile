source 'https://rubygems.org'

gem 'rails', '4.2.2'

gem 'unicorn', '4.6.2'

if ENV['SLIMMER_DEV']
  gem 'slimmer', :path => '../slimmer'
else
  gem 'slimmer', '8.2.1'
end
gem 'plek', '1.3.1'

gem 'gds-api-adapters', '20.1.1'
gem 'govuk_frontend_toolkit', '0.41.1'
gem 'sass-rails', '5.0.3'

gem 'logstasher', '0.4.8'
gem 'airbrake', '3.1.15'
gem 'rack_strip_client_ip', '0.0.1'

gem 'uglifier', '>= 2.7.1'

group :development, :test do
  gem 'rspec-rails', '3.2.1'
  gem 'capybara', '2.4.4'
  gem 'simplecov-rcov', '0.2.3', :require => false
  gem 'ci_reporter_rspec', '~> 1.0.0'
  gem 'webmock', :require => false
  gem 'timecop', '0.6.2.2'
  gem 'poltergeist', '1.6.0'
  gem 'rubocop'
end
