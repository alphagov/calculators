# encoding: utf-8
require 'spec_helper'

feature "Child Benefit Tax Calculator" do

  before(:each) do
    visit "/child-benefit-tax-calculator"
  end

  it "should have a placeholder landing page" do
    within "header.page-header" do
      page.should have_content("Estimate your High Income Child Benefit Tax Charge")
    end
  end

  it "should store the tax year when the user clicks it" do
    click_link "Click if you pay tax on Child Benefit for the tax year 2012 to 2013"
    page.should have_content("for 2012 to 2013")
  end

  describe "Calculating the results for 2012-13" do
    before(:each) do
      click_link "Click if you pay tax on Child Benefit for the tax year 2012 to 2013"
    end

    it "calculates the overall cost" do
      fill_in "total-annual-income-before-tax", :with => "5000"
      fill_in "children", :with => "2"
      click_button "Go"
      within ".calculator-results" do
        page.should have_content("You owe £1,000")
      end
    end
  end
end
