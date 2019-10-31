# encoding: utf-8

require "spec_helper"

feature "Child Benefit Tax Calculator", js: true do
  before do
    stub_request(:get, Plek.new.find("content-store") + "/content/child-benefit-tax-calculator/main").to_return(body: {}.to_json)
  end

  it "should not show results until enough info is entered" do
    visit "/child-benefit-tax-calculator/main"
    expect(page).to have_no_css(".results")

    choose "year-0", allow_label_click: true, visible: false # 2012
    select "2", from: "children_count"
    click_on "Update"
    expect(page).to have_no_css(".results")
  end

  it "supports all tax years from 2012 to current" do
    visit "/child-benefit-tax-calculator/main"

    within "#tax_year" do
      # This is written out explicitly to avoid using the same
      # generator code (e.g. ranges) as is used in the actual app,
      # since a bug or typo in the code would be hidden by the same
      # typo in the tests.
      tax_years = %w[
        2012
        2013
        2014
        2015
        2016
        2017
        2018
        2019
      ]

      tax_years.each_with_index do |year, index|
        expect(page).to have_css("#year-#{index}[value='#{year}']", visible: false)
      end
    end
  end

  context "page errors" do
    before :each do
      visit "/child-benefit-tax-calculator/main"
    end

    context "when tax claim duration isn't selected" do
      it "should display validation errors" do
        click_on "Calculate"
        within ".gem-c-error-alert" do
          expect(page).to have_content("select a tax year")
          expect(page).to have_content("select part year tax claim")
          expect(page).to have_no_content("enter the date Child Benefit started")
        end

        within "#tax_year" do
          expect(page).to have_css(".govuk-error-message")
          expect(page).to have_content("Select a tax year")
        end

        within "#is_part_year_claim" do
          expect(page).to have_css(".govuk-error-message")
          expect(page).to have_content("Select part year tax claim")
        end
      end
    end

    context "when NO is selected for tax claim duration" do
      it "should display validation errors" do
        choose "No", allow_label_click: true
        click_on "Calculate"
        within ".gem-c-error-alert" do
          expect(page).to have_content("select a tax year")
          expect(page).to have_no_content("enter the date Child Benefit started")
        end

        within "#tax_year" do
          expect(page).to have_css(".gem-c-error-message")
          expect(page).to have_content("Select a tax year")
        end

        within "#is_part_year_claim" do
          expect(page).to have_no_css(".error-message")
          expect(page).to have_no_css("#children")
          expect(page).to have_no_content("Select part year tax claim")
        end
      end
    end

    context "when YES is selected for tax claim duration" do
      it "should display validation errors" do
        choose "Yes", allow_label_click: true
        click_on "Calculate"
        within ".gem-c-error-alert" do
          expect(page).to have_content("select a tax year")
          expect(page).to have_content("enter the date Child Benefit started")
        end

        within "#tax_year" do
          expect(page).to have_css(".gem-c-error-message")
          expect(page).to have_content("Select a tax year")
        end

        within "#is_part_year_claim" do
          expect(page).to have_css(".govuk-error-message")
          expect(page).to have_no_content("Select part year tax claim")

          within "#children-template" do
            fieldsets = page.all("fieldset")

            expect(fieldsets[0]).to have_css(".govuk-error-message")
            expect(fieldsets[0]).to have_content("Enter the date Child Benefit started")
          end
        end
      end

      it "should ask how many children are being claimed for a part year" do
        choose "Yes", allow_label_click: true
        within "#is_part_year_claim" do
          expect(page).to have_select("part_year_children_count")
        end
      end

      it "should show two date selectors if two part year children are selected" do
        choose "Yes", allow_label_click: true
        select "2", from: "part_year_children_count"
        click_button "Update Children"

        within "#is_part_year_claim" do
          expect(page).to have_select("part_year_children_count", selected: "2")

          expect(page).to have_css("#starting_children_0_start_year")
          expect(page).to have_css("#starting_children_0_start_month")
          expect(page).to have_css("#starting_children_0_start_day")
          expect(page).to have_css("#starting_children_1_start_year")
          expect(page).to have_css("#starting_children_1_start_month")
          expect(page).to have_css("#starting_children_1_start_day")
        end
      end
    end

    context "when NO, then YES is selected for tax claim duration" do
      it "should display a date selector for one part year child" do
        choose "year-3", allow_label_click: true, visible: false # 2015
        choose "No", allow_label_click: true
        click_button "Calculate"

        choose "Yes", allow_label_click: true
        within "#is_part_year_claim" do
          expect(page).to have_css("#starting_children_0_start_year")
          expect(page).to have_css("#starting_children_0_start_month")
          expect(page).to have_css("#starting_children_0_start_day")
        end
      end
    end
  end

  it "should disallow dates with too many days for the selected month" do
    Timecop.travel "2014-09-01"
    visit "/child-benefit-tax-calculator/main"
    choose "Yes", allow_label_click: true

    select "2", from: "part_year_children_count"

    select "2012", from: "starting_children[0][start][year]"
    select "February", from: "starting_children[0][start][month]"
    select "31", from: "starting_children[0][start][day]"

    select "2012", from: "starting_children[1][start][year]"
    select "March", from: "starting_children[1][start][month]"
    select "1", from: "starting_children[1][start][day]"

    select "2012", from: "starting_children[1][stop][year]"
    select "February", from: "starting_children[1][stop][month]"
    select "31", from: "starting_children[1][stop][day]"

    choose "year-0", allow_label_click: true, visible: false # 2012

    click_button "Calculate"

    within "#children-template" do
      expect(page).to have_css("#starting_children_0_start_year_error", text: "Enter a valid date - there are only 29 days in February")
      expect(page).to have_css("#starting_children_1_stop_year_error", text: "Enter a valid date - there are only 29 days in February")
    end
  end

  it "should reload children with valid dates if one child has a date error" do
    visit "/child-benefit-tax-calculator/main"
    choose "year-2", allow_label_click: true, visible: false # 2014
    choose "Yes", allow_label_click: true
    select "2", from: "children_count"
    select "2", from: "part_year_children_count"
    within "#is_part_year_claim" do
      Capybara.ignore_hidden_elements = false
      click_button "Update Children"
      Capybara.ignore_hidden_elements = true
    end

    select "2014", from: "starting_children[0][start][year]"
    select "April", from: "starting_children[0][start][month]"
    select "31", from: "starting_children[0][start][day]"

    select "2014", from: "starting_children[1][start][year]"
    select "June", from: "starting_children[1][start][month]"
    select "1", from: "starting_children[1][start][day]"

    select "2014", from: "starting_children[1][stop][year]"
    select "September", from: "starting_children[1][stop][month]"
    select "1", from: "starting_children[1][stop][day]"

    click_button "Calculate"

    within "#children-template" do
      expect(page).to have_css("#starting_children_0_start_year_error", text: "Enter a valid date - there are only 30 days in April")
    end

    expect(page).to have_select("children_count", selected: "2")
    expect(page).to have_select("part_year_children_count", selected: "2")

    expect(page).to have_select("starting_children_1_start_year", selected: "2014")
    expect(page).to have_select("starting_children_1_start_month", selected: "June")
    expect(page).to have_select("starting_children_1_start_day", selected: "1")

    expect(page).to have_select("starting_children_1_stop_year", selected: "2014")
    expect(page).to have_select("starting_children_1_stop_month", selected: "September")
    expect(page).to have_select("starting_children_1_stop_day", selected: "1")
  end

  it "should reload part year children with the correct dates" do
    Timecop.travel "2014-05-01"
    visit "/child-benefit-tax-calculator/main"
    choose "year-2", allow_label_click: true, visible: false # 2014
    choose "Yes", allow_label_click: true
    select "2", from: "children_count"
    select "1", from: "part_year_children_count"
    within "#is_part_year_claim" do
      Capybara.ignore_hidden_elements = false
      click_button "Update Children"
      Capybara.ignore_hidden_elements = true
    end

    select "2014", from: "starting_children[0][start][year]"
    select "June", from: "starting_children[0][start][month]"
    select "1", from: "starting_children[0][start][day]"

    select "2014", from: "starting_children[0][stop][year]"
    select "September", from: "starting_children[0][stop][month]"
    select "1", from: "starting_children[0][stop][day]"

    click_button "Calculate"

    expect(page).to have_select("children_count", selected: "2")
    expect(page).to have_select("part_year_children_count", selected: "1")

    expect(page).to have_select("starting_children_0_start_year", selected: "2014")
    expect(page).to have_select("starting_children_0_start_month", selected: "June")
    expect(page).to have_select("starting_children_0_start_day", selected: "1")

    expect(page).to have_select("starting_children_0_stop_year", selected: "2014")
    expect(page).to have_select("starting_children_0_stop_month", selected: "September")
    expect(page).to have_select("starting_children_0_stop_day", selected: "1")
  end

  it "should show an error if start date is after end date" do
    visit "/child-benefit-tax-calculator/main"
    choose "year-2", allow_label_click: true, visible: false # 2014
    choose "Yes", allow_label_click: true
    select "1", from: "children_count"
    select "1", from: "part_year_children_count"
    within "#is_part_year_claim" do
      Capybara.ignore_hidden_elements = false
      click_button "Update Children"
      Capybara.ignore_hidden_elements = true
    end

    select "2014", from: "starting_children[0][start][year]"
    select "June", from: "starting_children[0][start][month]"
    select "1", from: "starting_children[0][start][day]"

    select "2014", from: "starting_children[0][stop][year]"
    select "April", from: "starting_children[0][stop][month]"
    select "1", from: "starting_children[0][stop][day]"

    click_button "Calculate"

    within "#children-template" do
      expect(page).to have_css("#starting_children_0_stop_year_error", text: "Child Benefit start date must be before stop date")
    end
  end

  it "should render start date to be ten years in the past" do
    allow(DateHelper).to receive(:years_ago).and_return(Date.parse("2010-01-01"))
    allow(DateHelper).to receive(:years_since).and_return(Date.parse("2012-01-01"))

    visit "/child-benefit-tax-calculator/main"
    choose "Yes", allow_label_click: true

    expected_year_list = ("2010".."2012").to_a.unshift("")
    expect(page).to have_select("starting_children_0_start_year", options: expected_year_list)
  end

  it "should render stop date containing the specified date range" do
    allow(DateHelper).to receive(:years_ago).and_return(Date.parse("2012-01-01"))
    allow(DateHelper).to receive(:years_since).and_return(Date.parse("2014-01-01"))
    visit "/child-benefit-tax-calculator/main"

    choose "Yes", allow_label_click: true
    expected_year_list = ("2012".."2014").to_a.unshift("")
    expect(page).to have_select("starting_children_0_stop_year", options: expected_year_list)
  end

  it "should show error if no children are present in the selected tax year" do
    Timecop.travel "2014-09-01"
    visit "/child-benefit-tax-calculator/main"
    choose "Yes", allow_label_click: true

    select "1", from: "part_year_children_count"
    within "#is_part_year_claim" do
      Capybara.ignore_hidden_elements = false
      click_button "Update Children"
      Capybara.ignore_hidden_elements = true
    end

    page.find("#starting_children_0_start_year").select("2011")
    page.find("#starting_children_0_start_month").select("January")
    page.find("#starting_children_0_start_day").select("1")

    page.find("#starting_children_0_stop_year").select("2012")
    page.find("#starting_children_0_stop_month").select("January")
    page.find("#starting_children_0_stop_day").select("1")

    choose "year-1", allow_label_click: true, visible: false # 2013

    click_on "Calculate"

    within ".gem-c-error-alert" do
      expect(page).to have_content("You haven't received any Child Benefit for the tax year selected. Check your Child Benefit dates or choose a different tax year.")
    end
  end

  describe "For more than one child" do
    before(:each) do
      visit "/child-benefit-tax-calculator/main"
      choose "Yes", allow_label_click: true
      select "2", from: "part_year_children_count"
      click_button "Update Children"
    end

    it "should show the required number of date inputs" do
      expect(page).to have_select("part_year_children_count", selected: "2")

      expect(page).to have_css("#starting_children_0_start_year")
      expect(page).to have_css("#starting_children_0_start_month")
      expect(page).to have_css("#starting_children_0_start_day")
      expect(page).to have_css("#starting_children_1_start_year")
      expect(page).to have_css("#starting_children_1_start_month")
      expect(page).to have_css("#starting_children_1_start_day")

      page.find("#starting_children_0_start_year").select("2011")
      page.find("#starting_children_0_start_month").select("January")
      page.find("#starting_children_0_start_day").select("1")

      select "3", from: "part_year_children_count"

      click_button "Update Children"

      expect(page).to have_select("part_year_children_count", selected: "3")

      expect(page).to have_select("starting_children_0_start_year", selected: "2011")
      expect(page).to have_select("starting_children_0_start_month", selected: "January")
      expect(page).to have_select("starting_children_0_start_day", selected: "1")

      expect(page).to have_css("#starting_children_2_start_year")
      expect(page).to have_css("#starting_children_2_start_month")
      expect(page).to have_css("#starting_children_2_start_day")

      select "2011", from: "starting_children_1_start_year"
      select "January", from: "starting_children_1_start_month"
      select "7", from: "starting_children_1_start_day"

      select "1", from: "part_year_children_count"

      click_button "Update Children"

      expect(page).to have_no_css("#starting_children_1_start_year")
      expect(page).to have_no_css("#starting_children_1_start_month")
      expect(page).to have_no_css("#starting_children_1_start_day")
    end

    it "should show the required number of date inputs without reloading the page" do
      choose "Yes", allow_label_click: true
      select "2", from: "part_year_children_count"
      click_button "Update Children"

      expect(page).to have_select("part_year_children_count", selected: "2")

      expect(page).to have_css("#starting_children_0_start_year")
      expect(page).to have_css("#starting_children_0_start_month")
      expect(page).to have_css("#starting_children_0_start_day")
      expect(page).to have_css("#starting_children_1_start_year")
      expect(page).to have_css("#starting_children_1_start_month")
      expect(page).to have_css("#starting_children_1_start_day")

      page.find("#starting_children_0_start_year").select("2011")
      page.find("#starting_children_0_start_month").select("January")
      page.find("#starting_children_0_start_day").select("1")

      select "3", from: "part_year_children_count"

      expect(page).to have_select("starting_children_0_start_year", selected: "2011")
      expect(page).to have_select("starting_children_0_start_month", selected: "January")
      expect(page).to have_select("starting_children_0_start_day", selected: "1")

      expect(page).to have_css("#starting_children_2_start_year")
      expect(page).to have_css("#starting_children_2_start_month")
      expect(page).to have_css("#starting_children_2_start_day")

      select "2011", from: "starting_children_1_start_year"
      select "January", from: "starting_children_1_start_month"
      select "7", from: "starting_children_1_start_day"

      select "1", from: "part_year_children_count"

      expect(page).to have_no_css("#starting_children_1_start_year")
      expect(page).to have_no_css("#starting_children_1_start_month")
      expect(page).to have_no_css("#starting_children_1_start_day")
    end

    describe "Calculating benefits received for 2012-13" do
      before(:each) do
        allow_any_instance_of(ChildBenefitTaxCalculator).to receive(:benefits_claimed_amount).and_return(500000)
      end

      it "calculates the overall benefits received for both children" do
        select "2", from: "children_count"
        choose "Yes", allow_label_click: true
        select "2", from: "part_year_children_count"
        click_button "Update Children"

        select "2011", from: "starting_children_0_start_year"
        select "January", from: "starting_children_0_start_month"
        select "1", from: "starting_children_0_start_day"

        select "2012", from: "starting_children_1_start_year"
        select "February", from: "starting_children_1_start_month"
        select "5", from: "starting_children_1_start_day"

        choose "year-0", allow_label_click: true, visible: false # 2012

        click_button "Calculate"

        expect(page).to have_content("£500,000.00")
      end
    end
  end

  describe "Estimating the tax due" do
    before(:each) do
      allow_any_instance_of(ChildBenefitTaxCalculator).to receive(:benefits_claimed_amount).and_return(500000)
      visit "/child-benefit-tax-calculator/main"
      choose "Yes", allow_label_click: true
    end

    it "should give an estimated total of tax due related to income" do
      allow_any_instance_of(ChildBenefitTaxCalculator).to receive(:tax_estimate).and_return(500000)

      select "2011", from: "starting_children[0][start][year]"
      select "January", from: "starting_children[0][start][month]"
      select "1", from: "starting_children[0][start][day]"
      choose "year-0", allow_label_click: true, visible: false # 2012
      fill_in "Salary before tax", with: "£60,000"

      click_button "Calculate"

      expect(page).to have_content("£500,000.00")
      expect(page).to have_content("based on your estimated adjusted net income of £60,000.00")
    end

    it "should explain that the adjusted net income is below the threshold" do
      allow_any_instance_of(ChildBenefitTaxCalculator).to receive(:tax_estimate).and_return(0)
      select "2011", from: "starting_children[0][start][year]"
      select "January", from: "starting_children[0][start][month]"
      select "1", from: "starting_children[0][start][day]"
      choose "year-0", allow_label_click: true, visible: false # 2012
      fill_in "Salary before tax", with: "45000"

      click_button "Calculate"

      expect(page).to have_content("There is no tax charge")
    end
  end

  describe "calculating adjusted net income" do
    before(:each) do
      visit "/child-benefit-tax-calculator/main"
      choose "Yes", allow_label_click: true
    end
    it "should use the adjusted net income calculator inputs" do
      select "2011", from: "starting_children[0][start][year]"
      select "January", from: "starting_children[0][start][month]"
      select "1", from: "starting_children[0][start][day]"
      choose "year-0", allow_label_click: true, visible: false # 2012

      fill_in "gross_income", with: "£120,000"
      fill_in "other_income", with: "£8,000"
      fill_in "pension_contributions_from_pay", with: "£2000"
      fill_in "retirement_annuities", with: "£2000"
      fill_in "cycle_scheme", with: "£800"
      fill_in "childcare", with: "£1500"
      fill_in "pensions", with: "£3000"
      fill_in "non_employment_income", with: "£500"
      fill_in "gift_aid_donations", with: "£1500"
      fill_in "outgoing_pension_contributions", with: "£2000"

      click_on "Calculate"

      expect(page).to have_content "Child Benefit received\n£263.90"
      expect(page).to have_content "Tax charge to pay\n£263.00"
      expect(page).to have_content("based on your estimated adjusted net income of £123,325.00")
    end

    it "should update the adjusted_net_income when the calculator values are updated." do
      select "2011", from: "starting_children[0][start][year]"
      select "January", from: "starting_children[0][start][month]"
      select "1", from: "starting_children[0][start][day]"
      choose "year-0", allow_label_click: true, visible: false # 2012

      fill_in "gross_income", with: "£120,000"
      fill_in "other_income", with: "£8,000"
      fill_in "pension_contributions_from_pay", with: "£2000"
      fill_in "retirement_annuities", with: "£2000"
      fill_in "cycle_scheme", with: "£800"
      fill_in "childcare", with: "£1500"
      fill_in "pensions", with: "£3000"
      fill_in "non_employment_income", with: "£500"
      fill_in "gift_aid_donations", with: "£1500"
      fill_in "outgoing_pension_contributions", with: "£2000"

      click_on "Calculate"

      expect(page).to have_content("based on your estimated adjusted net income of £123,325.00")

      fill_in "Salary before tax", with: "£50,000"
      click_on "Calculate"

      expect(page).to have_content "Child Benefit received\n£263.90"
      expect(page).to have_content "Tax charge to pay\n£87.00"
      expect(page).to have_content("based on your estimated adjusted net income of £53,325.00")
    end
  end

  describe "displaying the results" do
    before(:each) do
      visit "/child-benefit-tax-calculator/main"
      choose "Yes", allow_label_click: true
    end

    context "without the tax estimate" do
      before :each do
        select "2011", from: "starting_children_0_start_year"
        select "January", from: "starting_children_0_start_month"
        select "1", from: "starting_children_0_start_day"
      end

      it "should display the amount of child benefit for 2012-2013" do
        choose "year-0", allow_label_click: true, visible: false # 2012

        click_button "Calculate"

        expect(page).to have_content("£263.90")
        expect(page).to have_content("Received between 7 January and 5 April 2013.")
        expect(page).to have_content("Use this figure in your 2012 to 2013 Self Assessment tax return (if you fill one in).")
        expect(page).to have_content("To work out the tax charge, enter your income")
      end

      it "should display the amount of child benefit for 2013-2014" do
        choose "year-1", allow_label_click: true, visible: false # 2013

        click_button "Calculate"

        expect(page).to have_content("£1,055.60")
        expect(page).not_to have_content("Received between 7 January and 5 April 2013.")
        expect(page).to have_content("Use this figure in your 2013 to 2014 Self Assessment tax return (if you fill one in).")
        expect(page).to have_content("To work out the tax charge, enter your income")
      end
    end # without tax estimate

    context "with the tax estimate" do
      before :each do
        select "2011", from: "starting_children_0_start_year"
        select "January", from: "starting_children_0_start_month"
        select "1", from: "starting_children_0_start_day"

        fill_in "Salary before tax", with: "55000"
      end

      it "should display the amount of child benefit and tax estimate for 2012-13" do
        choose "year-0", allow_label_click: true, visible: false # 2012
        click_button "Calculate"

        expect(page).to have_content("£263.90")
        expect(page).to have_content("Received between 7 January and 5 April 2013.")
        expect(page).to have_content("Use this figure in your 2012 to 2013 Self Assessment tax return (if you fill one in).")
        expect(page).not_to have_content("To work out the tax charge, enter your income")

        expect(page).to have_content("£131.00")
        expect(page).to have_content("The tax charge only applies to the Child Benefit received between 7 January and 5 April 2013")
        expect(page).to have_content("and is based on your estimated adjusted net income of £55,000.00.")
        expect(page).to have_content("Your result for the next tax year may be higher because the tax charge will apply to the whole tax year (and not just 7 January to 5 April 2013).")
        expect(page).to have_content("To pay the tax charge you must fill in a Self Assessment tax return each tax year. Follow these steps:")
        expect(page).to have_content("you should do this by 5 October 2013")
      end

      it "should display the amount of child benefit and tax estimate for 2013-14" do
        choose "year-1", allow_label_click: true, visible: false # 2013
        click_button "Calculate"

        expect(page).to have_content("£1,055.60")
        expect(page).not_to have_content("Received between 7 January and 5 April 2013.")
        expect(page).to have_content("Use this figure in your 2013 to 2014 Self Assessment tax return (if you fill one in).")

        expect(page).to have_content("£527.00")
        expect(page).not_to have_content("The tax charge only applies to the Child Benefit received between 7 January and 5 April 2013")
        expect(page).not_to have_content("Your result for the next tax year may be higher")
        expect(page).to have_content("To pay the tax charge you must fill in a Self Assessment tax return each tax year. Follow these steps:")
        expect(page).to have_content("you should do this by 5 October 2014")
      end

      it "should show a warning if the tax_year is incomplete" do
        Timecop.travel "2013-09-01"

        choose "year-1", allow_label_click: true, visible: false # 2013
        click_button "Calculate"

        expect(page).to have_content("This is an estimate based on your adjusted net income of £55,000.00")
      end
    end # with the tax estimate

    context "with an Adjusted Net Income below the threshold" do
      it "should say there's nothing to pay" do
        select "2011", from: "starting_children_0_start_year"
        select "January", from: "starting_children_0_start_month"
        select "1", from: "starting_children_0_start_day"

        choose "year-1", allow_label_click: true, visible: false # 2013
        fill_in "Salary before tax", with: "49000"
        click_button "Calculate"

        expect(page).to have_content("£1,055.60")
        expect(page).not_to have_content("Received between 7 January and 5 April 2013.")
        expect(page).to have_content("Use this figure in your 2013 to 2014 Self Assessment tax return (if you fill one in).")

        expect(page).not_to have_content("To work out the tax charge, enter your income")

        expect(page).to have_content("£0.00")
        expect(page).to have_content("There is no tax charge if your income is below £50,099.")
      end
    end # ANI below threshold
  end

  describe "displaying results for full year children only" do
    before(:each) do
      visit "/child-benefit-tax-calculator/main"
    end

    context "one child" do
      it "should correctly display the amount for one child" do
        choose "year-3", allow_label_click: true, visible: false # 2015
        choose "No", allow_label_click: true

        click_button "Calculate"

        expect(page.text).to have_content("£1,097.10")
      end
    end

    context "two children" do
      it "should correctly display the amount for two children" do
        select "2", from: "children_count"
        choose "year-3", allow_label_click: true, visible: false # 2015
        choose "No", allow_label_click: true

        click_button "Calculate"

        expect(page.text).to have_content("£1,823.20")
      end
    end
  end

  describe "child benefit week runs Monday to Sunday" do
    before(:each) do
      visit "/child-benefit-tax-calculator/main"
      choose "Yes", allow_label_click: true
    end

    context "tax year is 2012/2013" do
      specify "should have no child benefit when start date is 07/01/2013" do
        select "2013", from: "starting_children_0_start_year"
        select "January", from: "starting_children_0_start_month"
        select "7", from: "starting_children_0_start_day"
        choose "year-0", allow_label_click: true, visible: false # 2012

        click_button "Calculate"

        expect(page.text).to contain_child_benefit_value("£243.60")
      end

      specify "should have no child benefit when start date is 01/04/2013" do
        select "2013", from: "starting_children_0_start_year"
        select "April", from: "starting_children_0_start_month"
        select "1", from: "starting_children_0_start_day"
        choose "year-0", allow_label_click: true, visible: false # 2012

        click_button "Calculate"

        expect(page).to contain_child_benefit_value("£0.00")
      end

      specify "should have no child benefit when start date is 05/04/2013" do
        select "2013", from: "starting_children_0_start_year"
        select "April", from: "starting_children_0_start_month"
        select "5", from: "starting_children_0_start_day"
        choose "year-0", allow_label_click: true, visible: false # 2012

        click_button "Calculate"

        expect(page).to contain_child_benefit_value("£0.00")
      end
    end

    context "tax year is 2013/2014" do
      specify "should have no child benefit when start date is 31/03/2014" do
        select "2014", from: "starting_children_0_start_year"
        select "March", from: "starting_children_0_start_month"
        select "31", from: "starting_children_0_start_day"
        choose "year-1", allow_label_click: true, visible: false # 2013

        click_button "Calculate"

        expect(page).to contain_child_benefit_value("£0.00")
      end

      specify "should have no child benefit when start date is 01/04/2014" do
        select "2014", from: "starting_children_0_start_year"
        select "April", from: "starting_children_0_start_month"
        select "1", from: "starting_children_0_start_day"
        choose "year-1", allow_label_click: true, visible: false # 2013

        click_button "Calculate"

        expect(page).to contain_child_benefit_value("£0.00")
      end

      specify "should have no child benefit when start date is 05/04/2014" do
        select "2014", from: "starting_children_0_start_year"
        select "April", from: "starting_children_0_start_month"
        select "5", from: "starting_children_0_start_day"
        choose "year-1", allow_label_click: true, visible: false # 2013

        click_button "Calculate"

        expect(page).to contain_child_benefit_value("£0.00")
      end
    end
  end
end
