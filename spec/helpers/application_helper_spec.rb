require "spec_helper"

describe ApplicationHelper, type: :helper do
  it "generates the html for a step" do
    expect(step(1, "Blah")).to eq("<h2 class=\"step step-1\">Blah</h2>")
  end
end
