require "spec_helper"

describe ApplicationHelper do

  before do
    @existing_website_root = ENV["GOVUK_WEBSITE_ROOT"]
  end

  after do
    ENV["GOVUK_WEBSITE_ROOT"] = @existing_website_root
  end

  it "appends the website root to internal links" do
    ENV["GOVUK_WEBSITE_ROOT"] = "https://www.dev.gov.uk"
    internal_url("/blah").should == "https://www.dev.gov.uk/blah"
  end

end