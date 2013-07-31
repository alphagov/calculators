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
    click_on "Start now"
    page.should have_no_css(".results")
  end

  it "should have a blank adjusted net income field" do
    visit "/child-benefit-tax-calculator"
    click_on "Start now"
    page.should have_css("input#adjusted_net_income[placeholder='£']")
  end

  it "should display validation errors" do
    visit "/child-benefit-tax-calculator"
    click_on "Start now"
    click_on "Get your estimate"

    within ".validation-summary" do
      page.should have_content("Select a tax year")
      page.should have_content("Enter the date child benefit started")
    end

    within "#tax_year" do
      page.should have_css(".validation-error")
      page.should have_content("Select a tax year")
    end
    within "#children" do
      page.should have_css(".validation-error")
      page.should have_content("Enter the date child benefit started")
    end
  end

  describe "For more than one child" do
    before(:each) do
      visit "/child-benefit-tax-calculator"
      click_on "Start now"
      select "2", :from => "children_count"
      click_button "Update"
    end
    it "should show the required number of date inputs" do
      page.should have_select("children_count", :selected => '2')
      
      page.should have_css("#starting_children_0_start_year")
      page.should have_css("#starting_children_0_start_month")
      page.should have_css("#starting_children_0_start_day")
      page.should have_css("#starting_children_1_start_year")
      page.should have_css("#starting_children_1_start_month")
      page.should have_css("#starting_children_1_start_day")

      page.find('#starting_children_0_start_year').select('2011')
      page.find('#starting_children_0_start_month').select('January')
      page.find('#starting_children_0_start_day').select('1')

      select "3", :from => "children_count"
      
      click_button "Update"

      page.should have_select("children_count", :selected => '3')

      page.should have_select("starting_children_0_start_year", :selected => "2011")
      page.should have_select("starting_children_0_start_month", :selected => "January")
      page.should have_select("starting_children_0_start_day", :selected => "1")

      page.should have_css("#starting_children_2_start_year")
      page.should have_css("#starting_children_2_start_month")
      page.should have_css("#starting_children_2_start_day")

      select "2011", :from => "starting_children_1_start_year"
      select "January", :from => "starting_children_1_start_month"
      select "7", :from => "starting_children_1_start_day"

      select "1", :from => "children_count"

      click_button "Update"

      page.should have_no_css("#starting_children_1_start_year")
      page.should have_no_css("#starting_children_1_start_month")
      page.should have_no_css("#starting_children_1_start_day")

    end

    describe "Calculating benefits received for 2012-13" do
      before(:each) do
        ChildBenefitTaxCalculator.any_instance.stub(:benefits_claimed_amount).and_return(500000)
      end

      it "calculates the overall benefits received for both children" do
        select "2011", :from => "starting_children_0_start_year"
        select "January", :from => "starting_children_0_start_month"
        select "1", :from => "starting_children_0_start_day"

        select "2012", :from => "starting_children_1_start_year"
        select "February", :from => "starting_children_1_start_month"
        select "5", :from => "starting_children_1_start_day"
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
      visit "/child-benefit-tax-calculator"
      click_on "Start now"
    end
    
    it "should give an estimated total of tax due related to income" do
      ChildBenefitTaxCalculator.any_instance.stub(:tax_estimate).and_return(500000)
      select "2011", :from => "starting_children[0][start][year]"
      select "January", :from => "starting_children[0][start][month]"
      select "1", :from => "starting_children[0][start][day]"
      choose "year_2012"
      fill_in "adjusted_net_income", :with => "£60,000"

      click_button "Get your estimate"
     
      page.should have_field("adjusted_net_income", :with => "£60,000.00")

      within ".results" do
        page.should have_content("£500,000.00")
      end
    end

    it "should explain that the adjusted net income is below the threshold" do
      ChildBenefitTaxCalculator.any_instance.stub(:tax_estimate).and_return(0)
      select "2011", :from => "starting_children[0][start][year]"
      select "January", :from => "starting_children[0][start][month]"
      select "1", :from => "starting_children[0][start][day]"
      choose "year_2012"
      fill_in "adjusted_net_income", :with => "45000"

      click_button "Get your estimate"
      
      within ".results" do
        page.should have_content("There is no tax charge")
      end
    end
  end

  describe "calculating adjusted net income" do
    before(:each) do
      ChildBenefitTaxCalculator.any_instance.stub(:benefits_claimed_amount).and_return(100000)
      ChildBenefitTaxCalculator.any_instance.stub(:tax_estimate).and_return(100000)     
      ChildBenefitTaxCalculator.any_instance.stub(:calculate_adjusted_net_income).and_return(100000)
      visit "/child-benefit-tax-calculator"
      click_on "Start now"
    end
    it "should use the adjusted net income calculator inputs" do
      select "2011", :from => "starting_children[0][start][year]"
      select "January", :from => "starting_children[0][start][month]"
      select "1", :from => "starting_children[0][start][day]"
      choose "year_2012"

      #click_on "Help working out your adjusted net income"
      
      fill_in "gross_income", :with => "£120,000"
      fill_in "other_income", :with => "£8,000"
      fill_in "pension_contributions_from_pay", :with => "£2000"
      fill_in "retirement_annuities", :with => "£2000"
      fill_in "cycle_scheme", :with => "£800"
      fill_in "childcare", :with => "£1500"
      fill_in "pensions", :with => "£3000"
      fill_in "non_employment_income", :with => "£500"
      fill_in "gift_aid_donations", :with => "£1500"
      fill_in "outgoing_pension_contributions", :with => "£2000"
      
      click_on "Get your estimate"

      page.should have_field "adjusted_net_income", :with => "£100,000.00"

      within ".results_estimate", :text => "Child benefit received" do
        page.should have_content "£100,000.00"
      end
      within ".results_estimate", :text => "Tax charge to pay" do
        page.should have_content "£100,000.00"
      end
    end
  end

end
