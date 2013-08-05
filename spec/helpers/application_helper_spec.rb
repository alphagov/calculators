require "spec_helper"

describe ApplicationHelper do

  it "appends the private frontend url to internal links when constant is set" do
    stub_const("PRIVATE_FRONTEND_INTERNAL_LINKS", true)
    internal_url("/blah").should == "http://private-frontend.dev.gov.uk/blah"
  end

  it "does not append the private frontend url to internal links when constant is not set" do
    stub_const("PRIVATE_FRONTEND_INTERNAL_LINKS", false)
    internal_url("/blah").should == "/blah"
  end

end