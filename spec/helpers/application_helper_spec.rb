require "spec_helper"

describe ApplicationHelper, type: :helper do
  it "generates the html for a step" do
    expect(step(1, "Blah")).to eq("<h2><span class='steps' id='step-1'><span class='visuallyhidden'>Step 1</span></span>Blah</h2>")
  end

  it "generates the html for a step with a description" do
    expect(step(1, "Blah", "(optional)")).to eq("<h2><span class='steps' id='step-1'><span class='visuallyhidden'>Step 1</span></span>Blah <span id='step-1-description'>(optional)</span></h2>")
  end
end
