require 'webmock'
require 'gds_api/test_helpers/content_api'

RSpec.configure do |config|
  config.include GdsApi::TestHelpers::ContentApi, :type => :controller
  config.before(:each, :type => :controller) do
    stub_content_api_default_artefact
  end

  config.include GdsApi::TestHelpers::ContentApi, :type => :feature
  config.before(:each, :type => :feature) do
    stub_content_api_default_artefact
  end
end
