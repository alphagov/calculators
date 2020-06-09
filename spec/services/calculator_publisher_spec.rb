require "spec_helper"
require "gds_api/test_helpers/publishing_api"

describe CalculatorPublisher do
  include GdsApi::TestHelpers::PublishingApi

  describe "#publish" do
    it "publishes content items for form" do
      content_id = "882aecb2-90c9-49b1-908d-c800bf22da5a"
      put_content_request = stub_publishing_api_put_content(content_id, {})
      publish_request = stub_publishing_api_publish(content_id, {})

      calendar = Calculator.all.first
      CalculatorPublisher.new(calendar).publish

      expect(put_content_request).to have_been_made
      expect(publish_request).to have_been_made
    end
  end
end
