if Rails.env.development? || Rails.env.test?
  require "ci/reporter/rake/rspec"
end
