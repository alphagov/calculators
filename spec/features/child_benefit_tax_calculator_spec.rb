# encoding: utf-8
require 'spec_helper'

feature "Child Benefit Tax Calculator" do

  it "should have a placeholder landing page" do
    visit "/child-benefit-tax-calculator"
    within "header.page-header" do
      page.should have_content("Quick answer Child Benefit tax calculator")
    end
  end

  it "should not show results until enough info is entered" do
    visit "/child-benefit-tax-calculator"
    page.should have_no_css(".results-box")
  end

  describe "For more than one child" do
    before(:each) do
      visit "/child-benefit-tax-calculator"
      click_on "Start now"
      select "2", :from => "children_count"
      click_button "Update"
    end
    it "should show the required number of date inputs" do
      page.should have_css("#starting_children_start_0_year")
      page.should have_css("#starting_children_start_0_month")
      page.should have_css("#starting_children_start_0_day")
      page.should have_css("#starting_children_start_1_year")
      page.should have_css("#starting_children_start_1_month")
      page.should have_css("#starting_children_start_1_day")
    end

    describe "Calculating benefits received for 2012-13" do
      before(:each) do
        ChildBenefitTaxCalculator.any_instance.stub(:benefits_claimed_amount).and_return(500000)
      end

      it "calculates the overall benefits received for both children" do
        select "2011", :from => "starting_children_start_0_year"
        select "January", :from => "starting_children_start_0_month"
        select "1", :from => "starting_children_start_0_day"

        select "2012", :from => "starting_children_start_1_year"
        select "February", :from => "starting_children_start_1_month"
        select "5", :from => "starting_children_start_1_day"
        choose "year_2012"
        
        click_button "Get your estimate"
        
        within ".results" do
          page.should have_content("£500,000.00")
        end
      end
    end
  end

  describe "Estimating the tax due" do
    before(:each) do
      ChildBenefitTaxCalculator.any_instance.stub(:benefits_claimed_amount).and_return(500000)
      ChildBenefitTaxCalculator.any_instance.stub(:tax_estimate).and_return(500000)
      visit "/child-benefit-tax-calculator"
      click_on "Start now"
    end
    
    it "should give an estimated total of tax due related to income" do
      select "2011", :from => "starting_children[][start][year]"
      select "January", :from => "starting_children[][start][month]"
      select "1", :from => "starting_children[][start][day]"
      choose "year_2012"
      fill_in "adjusted_net_income", :with => "60000"

      click_button "Get your estimate"
      
      within ".results" do
        page.should have_content("£500,000.00")
      end
    end
  end

end
