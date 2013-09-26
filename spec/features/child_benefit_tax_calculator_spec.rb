# encoding: utf-8
require 'spec_helper'

feature "Child Benefit Tax Calculator" do

  specify "inspecting the landing page" do
    visit "/child-benefit-tax-calculator"

    within 'head', :visible => :all do
      page.should have_selector("title", :text => "Child Benefit tax calculator - GOV.UK", :visible => :all)
    end

    within "main#content" do
      within "header.page-header" do
        page.should have_content("Child Benefit tax calculator")
        page.should have_content("Quick answer")
      end

      within 'article[role=article]' do
        within 'section.intro' do
          page.should have_link("Start now", :href => "/child-benefit-tax-calculator/main")
        end
      end

      page.should have_selector(".article-container #test-report_a_problem")
    end
    page.should have_selector("#test-related")
  end

  it "should not show results until enough info is entered" do
    visit "/child-benefit-tax-calculator"
    click_on "Start now"
    page.should have_no_css(".results")

    choose "year_2012"
    select "2", :from => "children_count"
    click_on "Update"
    page.should have_no_css(".results")
  end

  it "should display validation errors" do
    visit "/child-benefit-tax-calculator"
    click_on "Start now"
    click_on "Calculate"

    within ".validation-summary" do
      page.should have_content("Select a tax year")
      page.should have_content("Enter the date Child Benefit started")
    end

    within "#tax-year" do
      page.should have_css(".validation-error")
      page.should have_content("Select a tax year")
    end
    within "#children" do
      page.should have_css(".validation-error")
      page.should have_content("Enter the date Child Benefit started")
    end
  end

  it "should disallow dates with too many days for the selected month", js: true  do
    visit "/child-benefit-tax-calculator"
    click_on "Start now"

    select "2", :from => "children_count"

    select "2012", :from => "starting_children[0][start][year]"
    select "February", :from => "starting_children[0][start][month]"
    select "31", :from => "starting_children[0][start][day]"

    select "2002", :from => "starting_children[1][start][year]"
    select "March", :from => "starting_children[1][start][month]"
    select "1", :from => "starting_children[1][start][day]"

    select "2012", :from => "starting_children[1][stop][year]"
    select "February", :from => "starting_children[1][stop][month]"
    select "31", :from => "starting_children[1][stop][day]"

    choose "year_2012"

    click_button "Calculate"

    page.should have_selector(
      '.validation-error',
      text: 'Enter a valid date - there are only 29 days in February',
      count: 2
    )
  end

  it "should show error if no children are present in the selected tax year" do
    visit "/child-benefit-tax-calculator"
    click_on "Start now"

    select "1", :from => "children_count"
    click_button "Update"

    page.find('#starting_children_0_start_year').select('2011')
    page.find('#starting_children_0_start_month').select('January')
    page.find('#starting_children_0_start_day').select('1')

    page.find('#starting_children_0_stop_year').select('2012')
    page.find('#starting_children_0_stop_month').select('January')
    page.find('#starting_children_0_stop_day').select('1')

    choose "year_2013"

    click_on "Calculate"

    within ".validation-summary" do
      page.should have_content("You haven't received any Child Benefit for the tax year selected. Check your Child Benefit dates or choose a different tax year.")
    end

    within "#children" do
      page.should have_css(".validation-error")
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

    it "should show the required number of date inputs without reloading the page", :js => true do
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
        
        click_button "Calculate"
        
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
      fill_in "Salary before tax", :with => "£60,000"

      click_button "Calculate"
     
      within ".results" do
        page.should have_content("£500,000.00")
        page.should have_content("based on your estimated adjusted net income of £60,000.00")
      end
    end

    it "should explain that the adjusted net income is below the threshold" do
      ChildBenefitTaxCalculator.any_instance.stub(:tax_estimate).and_return(0)
      select "2011", :from => "starting_children[0][start][year]"
      select "January", :from => "starting_children[0][start][month]"
      select "1", :from => "starting_children[0][start][day]"
      choose "year_2012"
      fill_in "Salary before tax", :with => "45000"

      click_button "Calculate"
      
      within ".results" do
        page.should have_content("There is no tax charge")
      end
    end
  end

  describe "calculating adjusted net income" do
    it "should use the adjusted net income calculator inputs" do
      visit "/child-benefit-tax-calculator/main"

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
      
      click_on "Calculate"

      within ".results" do
        page.should have_content "Child Benefit received £263.90"
        page.should have_content "Tax charge to pay £263.00"

        page.should have_content("based on your estimated adjusted net income of £120,825.00")
      end
    end

    it "should update the adjusted_net_income when the calculator values are updated." do
      visit "/child-benefit-tax-calculator/main"

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

      click_on "Calculate"

      within ".results" do
        page.should have_content("based on your estimated adjusted net income of £120,825.00")
      end

      fill_in "Salary before tax", :with => "£50,000"
      click_on "Calculate"

      within ".results" do
        page.should have_content "Child Benefit received £263.90"
        page.should have_content "Tax charge to pay £21.00"
        page.should have_content("based on your estimated adjusted net income of £50,825.00")
      end
    end
  end

  describe "displaying the results" do
    context "without the tax estimate" do
      before :each do
        visit "/child-benefit-tax-calculator/main"

        select "2011", :from => "starting_children_0_start_year"
        select "January", :from => "starting_children_0_start_month"
        select "1", :from => "starting_children_0_start_day"
      end

      it "should display the amount of child benefit for 2012-2013" do
        choose "year_2012"
        
        click_button "Calculate"
        
        within ".results" do
          within :xpath, ".//div[contains(@class, 'results_estimate')][.//h3[.='Child Benefit received']]" do
            page.should have_content("£263.90")
            page.should have_content("Received between 7 January and 5 April 2013.")
            page.should have_content("Use this figure in your 2012 to 2013 Self Assessment tax return (if you fill one in).")
          end

          page.should have_content("To work out the tax charge, enter your income")
        end
      end

      it "should display the amount of child benefit for 2013-2014" do
        choose "year_2013"
        
        click_button "Calculate"
        
        within ".results" do
          within :xpath, ".//div[contains(@class, 'results_estimate')][.//h3[.='Child Benefit received']]" do
            page.should have_content("£1,055.60")
            page.should_not have_content("Received between 7 January and 5 April 2013.")
            page.should have_content("Use this figure in your 2013 to 2014 Self Assessment tax return (if you fill one in).")
          end

          page.should have_content("To work out the tax charge, enter your income")
        end
      end
    end # without tax estimate

    context "with the tax estimate" do
      before :each do
        visit "/child-benefit-tax-calculator/main"

        select "2011", :from => "starting_children_0_start_year"
        select "January", :from => "starting_children_0_start_month"
        select "1", :from => "starting_children_0_start_day"

        fill_in "Salary before tax", :with => "55000"
      end

      it "should display the amount of child benefit and tax estimate for 2012-13" do
        choose "year_2012"
        click_button "Calculate"

        within ".results" do
          within :xpath, ".//div[contains(@class, 'results_estimate')][.//h3[.='Child Benefit received']]" do
            page.should have_content("£263.90")
            page.should have_content("Received between 7 January and 5 April 2013.")
            page.should have_content("Use this figure in your 2012 to 2013 Self Assessment tax return (if you fill one in).")
          end

          page.should_not have_content("To work out the tax charge, enter your income")

          within :xpath, ".//div[contains(@class, 'results_estimate')][.//h3[.='Tax charge to pay']]" do
            page.should have_content("£131.00")
            page.should have_content("The tax charge only applies to the Child Benefit received between 7 January and 5 April 2013 and is based on your estimated adjusted net income of £55,000.00.")

            page.should have_content("Your result for the next tax year may be higher because the tax charge will apply to the whole tax year (and not just 7 January to 5 April 2013).")

            page.should have_content("To pay the tax charge you must fill in a Self Assessment tax return each tax year. Follow these steps:")
            page.should have_content("you should do this by 5 October 2013")
          end
        end
      end

      it "should display the amount of child benefit and tax estimate for 2013-14" do
        choose "year_2013"
        click_button "Calculate"

        within ".results" do
          within :xpath, ".//div[contains(@class, 'results_estimate')][.//h3[.='Child Benefit received']]" do
            page.should have_content("£1,055.60")
            page.should_not have_content("Received between 7 January and 5 April 2013.")
            page.should have_content("Use this figure in your 2013 to 2014 Self Assessment tax return (if you fill one in).")
          end

          page.should_not have_content("To work out the tax charge, enter your income")

          within :xpath, ".//div[contains(@class, 'results_estimate')][.//h3[.='Tax charge to pay']]" do
            page.should have_content("£527.00")
            page.should_not have_content("The tax charge only applies to the Child Benefit received between 7 January and 5 April 2013")

            page.should_not have_content("Your result for the next tax year may be higher")

            page.should have_content("To pay the tax charge you must fill in a Self Assessment tax return each tax year. Follow these steps:")
            page.should have_content("you should do this by 5 October 2014")
          end
        end
      end

      it "should show a warning if the tax_year is incomplete" do
        Timecop.travel "2013-09-01"

        choose "year_2013"
        click_button "Calculate"

        within ".results" do
          within :xpath, ".//div[contains(@class, 'results_estimate')][.//h3[.='Tax charge to pay']]" do
            page.should have_content("This is an estimate based on your adjusted net income of £55,000.00 - your circumstances may change before the end of the tax year.")
          end
        end
      end
    end # with the tax estimate

    context "with an Adjusted Net Income below the threshold" do

      it "should say there's nothing to pay" do
        visit "/child-benefit-tax-calculator/main"

        select "2011", :from => "starting_children_0_start_year"
        select "January", :from => "starting_children_0_start_month"
        select "1", :from => "starting_children_0_start_day"

        choose "year_2013"
        fill_in "Salary before tax", :with => "49000"
        click_button "Calculate"

        within ".results" do
          within :xpath, ".//div[contains(@class, 'results_estimate')][.//h3[.='Child Benefit received']]" do
            page.should have_content("£1,055.60")
            page.should_not have_content("Received between 7 January and 5 April 2013.")
            page.should have_content("Use this figure in your 2013 to 2014 Self Assessment tax return (if you fill one in).")
          end

          page.should_not have_content("To work out the tax charge, enter your income")

          within :xpath, ".//div[contains(@class, 'results_estimate')][.//h3[.='Tax charge to pay']]" do
            page.should have_content("£0.00")
            page.should have_content("There is no tax charge if your income is below £50,099.")
          end
        end
      end

    end # ANI below threshold

    context "with all children stopping before 7th January 2013" do
      it "should say there's nothing to pay when no ANI is entered" do
        visit "/child-benefit-tax-calculator/main"

        select "2012", :from => "starting_children_0_start_year"
        select "April", :from => "starting_children_0_start_month"
        select "5", :from => "starting_children_0_start_day"

        select "2013", :from => "starting_children_0_stop_year"
        select "January", :from => "starting_children_0_stop_month"
        select "5", :from => "starting_children_0_stop_day"

        choose "year_2012"
        click_button "Calculate"

        within ".results" do
          within ".results_estimate" do
            page.should have_content "Your Child Benefit stopped before 7 January 2013 so you aren’t affected by the tax charge."
            page.should have_content "Find out more about the tax charge"
          end

          page.should_not have_content("Use this figure in your 2012 to 2013 Self Assessment tax return")
        end
      end
    end
  end

  describe "child benefit week runs Monday to Sunday" do
    context "tax year is 2012/2013" do
      specify "should have no child benefit when start date is 07/01/2013" do
        visit "/child-benefit-tax-calculator/main"

        select "2013", :from => "starting_children_0_start_year"
        select "January", :from => "starting_children_0_start_month"
        select "7", :from => "starting_children_0_start_day"
        choose "year_2012"

        click_button "Calculate"

        page.should contain_child_benefit_value("£263.90")
      end

      specify "should have no child benefit when start date is 01/04/2013" do
        visit "/child-benefit-tax-calculator/main"

        select "2013", :from => "starting_children_0_start_year"
        select "April", :from => "starting_children_0_start_month"
        select "1", :from => "starting_children_0_start_day"
        choose "year_2012"

        click_button "Calculate"

        page.should contain_child_benefit_value("£0.00")
      end

      specify "should have no child benefit when start date is 05/04/2013" do
        visit "/child-benefit-tax-calculator/main"

        select "2013", :from => "starting_children_0_start_year"
        select "April", :from => "starting_children_0_start_month"
        select "5", :from => "starting_children_0_start_day"
        choose "year_2012"

        click_button "Calculate"

        page.should contain_child_benefit_value("£0.00")
      end
    end

    context "tax year is 2013/2014" do
      specify "should have no child benefit when start date is 31/03/2014" do
        visit "/child-benefit-tax-calculator/main"

        select "2014", :from => "starting_children_0_start_year"
        select "March", :from => "starting_children_0_start_month"
        select "31", :from => "starting_children_0_start_day"
        choose "year_2013"

        click_button "Calculate"

        page.should contain_child_benefit_value("£0.00")
      end

      specify "should have no child benefit when start date is 01/04/2014" do
        visit "/child-benefit-tax-calculator/main"

        select "2014", :from => "starting_children_0_start_year"
        select "April", :from => "starting_children_0_start_month"
        select "1", :from => "starting_children_0_start_day"
        choose "year_2013"

        click_button "Calculate"

        page.should contain_child_benefit_value("£0.00")
      end

      specify "should have no child benefit when start date is 05/04/2014" do
        visit "/child-benefit-tax-calculator/main"

        select "2014", :from => "starting_children_0_start_year"
        select "April", :from => "starting_children_0_start_month"
        select "5", :from => "starting_children_0_start_day"
        choose "year_2013"

        click_button "Calculate"

        page.should contain_child_benefit_value("£0.00")
      end
    end
  end

  it "should redirect requests for the old smart-answer" do
    visit "/child-benefit-tax-calculator/y"
    i_should_be_on "/child-benefit-tax-calculator"

    visit "/child-benefit-tax-calculator/y/income_work_out/2012-13"
    i_should_be_on "/child-benefit-tax-calculator"

    visit "/child-benefit-tax-calculator/y/income_work_out/2012-13.json"
    i_should_be_on "/child-benefit-tax-calculator"
  end

  it "should contain a selector for the feedback form" do
    visit "/child-benefit-tax-calculator/main"
    page.should have_selector("main#content div#test-report_a_problem")
  end
end
