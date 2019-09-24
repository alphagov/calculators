require "spec_helper"

describe "session_store" do
  it "should be disabled" do
    expect(Calculators::Application.config.session_store).to be_nil
  end
end
