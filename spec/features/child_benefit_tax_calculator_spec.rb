require 'spec_helper'

feature "Child Benefit Tax Calculator" do

  it "should have a placeholder landing page" do
    visit "/child-benefit-tax-calculator"

    page.should have_content("Placeholder landing page")
  end
end
