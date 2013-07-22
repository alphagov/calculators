# encoding: utf-8
require 'spec_helper'

feature "Child Benefit Tax Calculator" do

  it "should have a placeholder landing page" do
    visit "/child-benefit-tax-calculator"
    within "header.page-header" do
      page.should have_content("Quick answer Child Benefit tax calculator")
    end
  end

  it "should show no results if not enough info is entered" do
    visit "/child-benefit-tax-calculator"
    page.should have_no_css(".results-box")
  end

  describe "Calculating the benefits received for 2012-13" do
    before(:each) do
      ChildBenefitTaxCalculator.any_instance.stub(:benefits_claimed_amount).and_return(500000)
      visit "/child-benefit-tax-calculator"
      click_on "Start now"
    end

    it "calculates the overall cost for one child" do
      select "2011", :from => "starting_children[][start][year]"
      select "January", :from => "starting_children[][start][month]"
      select "1", :from => "starting_children[][start][day]"
      choose "year_2012"
      
      click_button "Get your estimate"
      
      within ".results-box" do
        page.should have_content("£500,000.00")
      end
    end
  end

end
