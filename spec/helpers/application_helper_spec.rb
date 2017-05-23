require "spec_helper"

describe ApplicationHelper, type: :helper do
  it "generates the html for a step" do
    expect(step(1, "Blah")).to eq("<div class=\"govuk-govspeak\"><ul class=\"steps\"><li class=\"steps-step1\"><h2>Blah</h2></li></ul></div>")
  end

  it "generates the html for a step with a description" do
    expect(step(1, "Blah", "(optional)")).to eq("<div class=\"govuk-govspeak\"><ul class=\"steps\"><li class=\"steps-step1\"><h2>Blah<span id='step-1-description'>(optional)</span></h2></li></ul></div>")
  end
end
