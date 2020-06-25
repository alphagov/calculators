require_relative "../test_helper"
require "gds_api/content_store"
require "capybara/rails"

Capybara.server = :webrick
Capybara.default_driver = :rack_test

GovukTest.configure
#  update to use assert_page_has_content from /text/integration_test_helper

class ChildBenefitTaxCalculatorTest < ActionDispatch::IntegrationTest
  include Capybara::DSL

  # taken from smart-answers /text/integration_test_helper.rb
  def assert_page_has_content(text)
    assert page.has_content?(text), %(expected there to be content #{text} in #{page.text.inspect})
  end

  setup do
    stub_request(:get, Plek.new.find("content-store") + "/content/child-benefit-tax-calculator/main").to_return(body: {}.to_json)
    Services.stubs(:content_store).returns(stub(:content_item => {}))
    Timecop.travel("2020-04-02")
  end

  context "Child Benefit Tax Calculator" do
    should "not show results until enough info is entered" do
      visit "/child-benefit-tax-calculator/main"
      assert page.has_no_selector?(".results")

      visit "/child-benefit-tax-calculator/main"
      choose "year-0", allow_label_click: true, visible: false
      select "2", from: "children_count"
      click_on "Update"

      assert page.has_no_selector?(".results")
    end

    should "support all tax years since 2012" do
      visit "/child-benefit-tax-calculator/main"

      within "#tax_year" do
        (2012..Time.zone.now.year).map.with_index do |year, index|
          assert page.has_selector?("#year-#{index}[value='#{year}']", visible: false)
        end
      end
    end

    context "page errors" do
      setup do
        visit "/child-benefit-tax-calculator/main"
      end

      context "when tax claim duration isn't selected" do
        should "display validation errors" do
          click_on "Calculate"

          within ".gem-c-error-summary" do
            assert_page_has_content "select a tax year"
            assert_page_has_content "select part year tax claim"
            assert page.has_no_content? "enter the date Child Benefit started"
          end

          within "#tax_year" do
            assert page.has_selector?(".govuk-error-message")
            assert_page_has_content "Select a tax year"
          end

          within "#is_part_year_claim" do
            assert page.has_selector?(".govuk-error-message")
            assert_page_has_content "Select part year tax claim"
          end
        end
      end

      context "when NO is selected for tax claim duration" do
        should "display validation errors" do
          choose "No", allow_label_click: true
          click_on "Calculate"

          within ".gem-c-error-summary" do
            assert_page_has_content "select a tax year"
            assert page.has_no_content?("enter the date Child Benefit started")
          end

          within "#tax_year" do
            assert page.has_selector?(".gem-c-error-message")
            assert_page_has_content "Select a tax year"
          end

          within "#is_part_year_claim" do
            assert page.has_no_selector?(".error-message")
            assert page.has_no_selector?("#children")
            assert page.has_no_content?("Select part year tax claim")
          end
        end
      end

      context "when YES is selected for tax claim duration" do
        should "display validation errors" do
          choose "Yes", allow_label_click: true
          click_on "Calculate"
          within ".gem-c-error-summary" do
            assert_page_has_content "select a tax year"
            assert_page_has_content "enter the date Child Benefit started"
          end

          within "#tax_year" do
            assert page.has_selector?(".gem-c-error-message")
            assert_page_has_content "Select a tax year"
          end

          within "#is_part_year_claim" do
            assert page.has_selector?(".govuk-error-message")
            assert page.has_no_content?("Select part year tax claim")

            within "#children-template" do
              fieldsets = page.all("fieldset")

              assert (fieldsets[0]).has_selector?(".govuk-error-message")
              assert (fieldsets[0]).has_content?("Enter the date Child Benefit started")
            end
          end
        end

        should "ask how many children are being claimed for a part year" do
          choose "Yes", allow_label_click: true
          within "#is_part_year_claim" do
            assert page.has_select?("part_year_children_count")
          end
        end

        should "should show two date selectors if two part year children are selected" do
          choose "Yes", allow_label_click: true
          select "2", from: "part_year_children_count"
          click_button "Update Children"

          within "#is_part_year_claim" do
            assert page.has_select?("part_year_children_count", selected: "2")

            assert page.has_selector?("#starting_children_0_start_year")
            assert page.has_selector?("#starting_children_0_start_month")
            assert page.has_selector?("#starting_children_0_start_day")
            assert page.has_selector?("#starting_children_1_start_year")
            assert page.has_selector?("#starting_children_1_start_month")
            assert page.has_selector?("#starting_children_1_start_day")
          end
        end
      end

      context "when NO, then YES is selected for tax claim duration" do
        should "display a date selector for one part year child" do
          choose "year-3", allow_label_click: true, visible: false
          choose "No", allow_label_click: true
          click_button "Calculate"

          choose "Yes", allow_label_click: true
          within "#is_part_year_claim" do
            assert page.has_selector?("#starting_children_0_start_year")
            assert page.has_selector?("#starting_children_0_start_month")
            assert page.has_selector?("#starting_children_0_start_day")
          end
        end
      end
    end

    # should "should disallow dates with too many days for the selected month" do
    #   visit "/child-benefit-tax-calculator/main"
    #   choose "Yes", allow_label_click: true
    #
    #   select "2", from: "part_year_children_count"
    #
    #   select "2016", from: "starting_children[0][start][year]"
    #   select "February", from: "starting_children[0][start][month]"
    #   select "31", from: "starting_children[0][start][day]"
    #
    #   select "2016", from: "starting_children[1][start][year]"
    #   select "March", from: "starting_children[1][start][month]"
    #   select "1", from: "starting_children[1][start][day]"
    #
    #   select "2016", from: "starting_children[1][stop][year]"
    #   select "February", from: "starting_children[1][stop][month]"
    #   select "31", from: "starting_children[1][stop][day]"
    #
    #   choose "year-0", allow_label_click: true, visible: false
    #
    #   click_button "Calculate"
    #
    #   within "#children-template" do
    #     assert page.has_selector?("#starting_children_0_start_year_error", text: "Enter a valid date - there are only 29 days in February")
    #     assert page.has_selector?("#starting_children_1_stop_year_error", text: "Enter a valid date - there are only 29 days in February")
    #   end
    # end

    should "reload children with valid dates if one child has a date error" do
      visit "/child-benefit-tax-calculator/main"
      choose "year-2", allow_label_click: true, visible: false
      choose "Yes", allow_label_click: true
      select "2", from: "children_count"
      select "2", from: "part_year_children_count"
      within "#is_part_year_claim" do
        Capybara.ignore_hidden_elements = false
        click_button "Update Children"
        Capybara.ignore_hidden_elements = true
      end

      select "2016", from: "starting_children[0][start][year]"
      select "April", from: "starting_children[0][start][month]"
      select "31", from: "starting_children[0][start][day]"

      select "2016", from: "starting_children[1][start][year]"
      select "June", from: "starting_children[1][start][month]"
      select "1", from: "starting_children[1][start][day]"

      select "2016", from: "starting_children[1][stop][year]"
      select "September", from: "starting_children[1][stop][month]"
      select "1", from: "starting_children[1][stop][day]"

      click_button "Calculate"

      within "#children-template" do
        assert page.has_selector?("#starting_children_0_start_year_error", text: "Enter a valid date - there are only 30 days in April")
      end

      assert page.has_select?("children_count", selected: "2")
      assert page.has_select?("part_year_children_count", selected: "2")

      assert page.has_select?("starting_children_1_start_year", selected: "2016")
      assert page.has_select?("starting_children_1_start_month", selected: "June")
      assert page.has_select?("starting_children_1_start_day", selected: "1")

      assert page.has_select?("starting_children_1_stop_year", selected: "2016")
      assert page.has_select?("starting_children_1_stop_month", selected: "September")
      assert page.has_select?("starting_children_1_stop_day", selected: "1")
    end

    should "reload part year children with the correct dates" do
      visit "/child-benefit-tax-calculator/main"
      choose "year-2", allow_label_click: true, visible: false
      choose "Yes", allow_label_click: true
      select "2", from: "children_count"
      select "1", from: "part_year_children_count"
      within "#is_part_year_claim" do
        Capybara.ignore_hidden_elements = false
        click_button "Update Children"
        Capybara.ignore_hidden_elements = true
      end

      select "2016", from: "starting_children[0][start][year]"
      select "June", from: "starting_children[0][start][month]"
      select "1", from: "starting_children[0][start][day]"

      select "2016", from: "starting_children[0][stop][year]"
      select "September", from: "starting_children[0][stop][month]"
      select "1", from: "starting_children[0][stop][day]"

      click_button "Calculate"

      assert page.has_select?("children_count", selected: "2")
      assert page.has_select?("part_year_children_count", selected: "1")

      assert page.has_select?("starting_children_0_start_year", selected: "2016")
      assert page.has_select?("starting_children_0_start_month", selected: "June")
      assert page.has_select?("starting_children_0_start_day", selected: "1")

      assert page.has_select?("starting_children_0_stop_year", selected: "2016")
      assert page.has_select?("starting_children_0_stop_month", selected: "September")
      assert page.has_select?("starting_children_0_stop_day", selected: "1")
    end

    should "show an error if start date is after end date" do
      visit "/child-benefit-tax-calculator/main"
      choose "year-2", allow_label_click: true, visible: false
      choose "Yes", allow_label_click: true
      select "1", from: "children_count"
      select "1", from: "part_year_children_count"
      within "#is_part_year_claim" do
        Capybara.ignore_hidden_elements = false
        click_button "Update Children"
        Capybara.ignore_hidden_elements = true
      end

      select "2016", from: "starting_children[0][start][year]"
      select "June", from: "starting_children[0][start][month]"
      select "1", from: "starting_children[0][start][day]"

      select "2016", from: "starting_children[0][stop][year]"
      select "April", from: "starting_children[0][stop][month]"
      select "1", from: "starting_children[0][stop][day]"

      click_button "Calculate"

      within "#children-template" do
        assert page.has_selector?("#starting_children_0_stop_year_error", text: "Child Benefit start date must be before stop date")
      end
    end

    should "render start dates since 2011" do
      visit "/child-benefit-tax-calculator/main"
      choose "Yes", allow_label_click: true

      expected_year_list = ("2011".."2021").to_a.unshift("")
      assert page.has_select?("starting_children_0_start_year", options: expected_year_list)
    end

    should "render stop date containing the specified date range" do
      visit "/child-benefit-tax-calculator/main"

      choose "Yes", allow_label_click: true
      expected_year_list = ("2011".."2021").to_a.unshift("")
      assert page.has_select?("starting_children_0_stop_year", options: expected_year_list)
    end

    should "show error if no children are present in the selected tax year" do
      visit "/child-benefit-tax-calculator/main"

      within "#tax_year" do
        choose "year-0", allow_label_click: true, visible: false
      end

      within "#is_part_year_claim" do
        choose "Yes", allow_label_click: true

        find("#starting_children_0_start_year").select("2018")
        find("#starting_children_0_start_month").select("January")
        find("#starting_children_0_start_day").select("1")

        find("#starting_children_0_stop_year").select("2019")
        find("#starting_children_0_stop_month").select("January")
        find("#starting_children_0_stop_day").select("1")
      end

      click_on "Calculate"

      within ".gem-c-error-summary" do
        assert_page_has_content "You haven't received any Child Benefit for the tax year selected. Check your Child Benefit dates or choose a different tax year."
      end
    end

    context "For more than one child" do
      setup do
        visit "/child-benefit-tax-calculator/main"
        choose "Yes", allow_label_click: true
        select "2", from: "part_year_children_count"
        click_button "Update Children"
      end

      should "show the required number of date inputs" do
        assert page.has_select?("part_year_children_count", selected: "2")

        assert page.has_selector?("#starting_children_0_start_year")
        assert page.has_selector?("#starting_children_0_start_month")
        assert page.has_selector?("#starting_children_0_start_day")
        assert page.has_selector?("#starting_children_1_start_year")
        assert page.has_selector?("#starting_children_1_start_month")
        assert page.has_selector?("#starting_children_1_start_day")

        page.find("#starting_children_0_start_year").select("2016")
        page.find("#starting_children_0_start_month").select("January")
        page.find("#starting_children_0_start_day").select("1")

        select "3", from: "part_year_children_count"

        click_button "Update Children"

        assert page.has_select?("part_year_children_count", selected: "3")

        assert page.has_select?("starting_children_0_start_year", selected: "2016")
        assert page.has_select?("starting_children_0_start_month", selected: "January")
        assert page.has_select?("starting_children_0_start_day", selected: "1")

        assert page.has_selector?("#starting_children_2_start_year")
        assert page.has_selector?("#starting_children_2_start_month")
        assert page.has_selector?("#starting_children_2_start_day")

        select "2016", from: "starting_children_1_start_year"
        select "January", from: "starting_children_1_start_month"
        select "7", from: "starting_children_1_start_day"

        select "1", from: "part_year_children_count"

        click_button "Update Children"

        assert page.has_no_selector?("#starting_children_1_start_year")
        assert page.has_no_selector?("#starting_children_1_start_month")
        assert page.has_no_selector?("#starting_children_1_start_day")
      end

      # javascript
      # should "show the required number of date inputs without reloading the page" do
      #   choose "Yes", allow_label_click: true
      #   select "2", from: "part_year_children_count"
      #   click_button "Update Children"
      #
      #   assert page.has_select?("part_year_children_count", selected: "2")
      #
      #   assert page.has_selector?("#starting_children_0_start_year")
      #   assert page.has_selector?("#starting_children_0_start_month")
      #   assert page.has_selector?("#starting_children_0_start_day")
      #   assert page.has_selector?("#starting_children_1_start_year")
      #   assert page.has_selector?("#starting_children_1_start_month")
      #   assert page.has_selector?("#starting_children_1_start_day")
      #
      #   page.find("#starting_children_0_start_year").select("2016")
      #   page.find("#starting_children_0_start_month").select("January")
      #   page.find("#starting_children_0_start_day").select("1")
      #
      #   select "3", from: "part_year_children_count"
      #
      #   assert page.has_select?("starting_children_0_start_year", selected: "2016")
      #   assert page.has_select?("starting_children_0_start_month", selected: "January")
      #   assert page.has_select?("starting_children_0_start_day", selected: "1")
      #
      #   assert page.has_selector?("#starting_children_2_start_year")
      #   assert page.has_selector?("#starting_children_2_start_month")
      #   assert page.has_selector?("#starting_children_2_start_day")
      #
      #   select "2016", from: "starting_children_1_start_year"
      #   select "January", from: "starting_children_1_start_month"
      #   select "7", from: "starting_children_1_start_day"
      #
      #   select "1", from: "part_year_children_count"
      #
      #   assert page.has_no_selector?("#starting_children_1_start_year")
      #   assert page.has_no_selector?("#starting_children_1_start_month")
      #   assert page.has_no_selector?("#starting_children_1_start_day")
      # end

      # context "Calculating benefits received for 2012-13" do
      #   setup do
      #     @calculator = ChildBenefitTaxCalculator.new(year: "2012")
      #     @calculator.stubs(:benefits_claimed_amount).returns(500_000)
      #   end
      #
      #   should "calculate the overall benefits received for both children" do
      #     select "2", from: "children_count"
      #     choose "Yes", allow_label_click: true
      #     select "2", from: "part_year_children_count"
      #     click_button "Update Children"
      #
      #     select "2011", from: "starting_children_0_start_year"
      #     select "January", from: "starting_children_0_start_month"
      #     select "1", from: "starting_children_0_start_day"
      #
      #     select "2012", from: "starting_children_1_start_year"
      #     select "February", from: "starting_children_1_start_month"
      #     select "5", from: "starting_children_1_start_day"
      #
      #     choose "year-0", allow_label_click: true, visible: false
      #     click_button "Calculate"
      #
      #     assert_page_has_content("£500,000.00")
      #   end
      # end
    end

    context "Estimating the tax due" do
      setup do
        visit "/child-benefit-tax-calculator/main"
        choose "Yes", allow_label_click: true
      end

      should "give an estimated total of tax due related to income" do
        select "2011", from: "starting_children[0][start][year]"
        select "January", from: "starting_children[0][start][month]"
        select "1", from: "starting_children[0][start][day]"
        choose "year-0", allow_label_click: true, visible: false
        fill_in "Salary before tax", with: "£60,000"

        click_button "Calculate"

        assert_page_has_content("Tax charge to pay\n£263.00")
        assert_page_has_content("based on your estimated adjusted net income of £60,000.00")
      end

    end

    context "calculating adjusted net income" do
      setup do
        visit "/child-benefit-tax-calculator/main"
        choose "Yes", allow_label_click: true
      end

      should "use the adjusted net income calculator inputs" do
        select "2011", from: "starting_children[0][start][year]"
        select "January", from: "starting_children[0][start][month]"
        select "1", from: "starting_children[0][start][day]"
        choose "year-0", allow_label_click: true, visible: false

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

        assert_page_has_content "Child Benefit received\n£263.90"
        assert_page_has_content "Tax charge to pay\n£263.00"
        assert_page_has_content "based on your estimated adjusted net income of £123,325.00"
      end

      should "update the adjusted_net_income when the calculator values are updated." do
        select "2011", from: "starting_children[0][start][year]"
        select "January", from: "starting_children[0][start][month]"
        select "1", from: "starting_children[0][start][day]"
        choose "year-0", allow_label_click: true, visible: false

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

        assert_page_has_content "based on your estimated adjusted net income of £123,325.00"

        fill_in "Salary before tax", with: "£50,000"
        click_on "Calculate"

        assert_page_has_content "Child Benefit received\n£263.90"
        assert_page_has_content "Tax charge to pay\n£87.00"
        assert_page_has_content "based on your estimated adjusted net income of £53,325.00"
      end
    end

    context "displaying the results" do
      setup do
        visit "/child-benefit-tax-calculator/main"
        choose "Yes", allow_label_click: true
      end

      context "without the tax estimate" do
        setup do
          select "2011", from: "starting_children_0_start_year"
          select "January", from: "starting_children_0_start_month"
          select "1", from: "starting_children_0_start_day"
        end

        should "display the amount of child benefit for 2012-2013" do
          choose "year-0", allow_label_click: true, visible: false

          click_button "Calculate"

          assert_page_has_content "£263.90"
          assert_page_has_content "Received between 7 January and 5 April 2013."
          assert_page_has_content "Use this figure in your 2012 to 2013 Self Assessment tax return (if you fill one in)."
          assert_page_has_content "To work out the tax charge, enter your income"
        end

        should "display the amount of child benefit for 2013-2014" do
          choose "year-1", allow_label_click: true, visible: false

          click_button "Calculate"

          assert_page_has_content"£1,055.60"
          assert page.has_no_content? ("Received between 7 January and 5 April 2013.")
          assert_page_has_content"Use this figure in your 2013 to 2014 Self Assessment tax return (if you fill one in)."
          assert_page_has_content"To work out the tax charge, enter your income"
        end
      end # without tax estimate
    end

    context "with the tax estimate" do
      setup do
        visit "/child-benefit-tax-calculator/main"
        choose "Yes", allow_label_click: true
        select "2011", from: "starting_children_0_start_year"
        select "January", from: "starting_children_0_start_month"
        select "1", from: "starting_children_0_start_day"

        fill_in "Salary before tax", with: "55000"
      end

      should "display the amount of child benefit and tax estimate for 2012-13" do
        choose "year-0", allow_label_click: true, visible: false
        click_button "Calculate"

        assert_page_has_content("£263.90")
        assert_page_has_content("Received between 7 January and 5 April 2013.")
        assert_page_has_content("Use this figure in your 2012 to 2013 Self Assessment tax return (if you fill one in).")
        assert page.has_no_content?("To work out the tax charge, enter your income")

        assert_page_has_content("£131.00")
        assert_page_has_content("The tax charge only applies to the Child Benefit received between 7 January and 5 April 2013")
        assert_page_has_content("and is based on your estimated adjusted net income of £55,000.00.")
        assert_page_has_content("Your result for the next tax year may be higher because the tax charge will apply to the whole tax year (and not just 7 January to 5 April 2013).")
        assert_page_has_content("To pay the tax charge you must fill in a Self Assessment tax return each tax year. Follow these steps:")
        assert_page_has_content("you should do this by 5 October 2013")
      end

      should "display the amount of child benefit and tax estimate for 2013-14" do
        choose "year-1", allow_label_click: true, visible: false
        click_button "Calculate"

        assert_page_has_content("£1,055.60")
        assert page.has_no_content?("Received between 7 January and 5 April 2013.")
        assert_page_has_content("Use this figure in your 2013 to 2014 Self Assessment tax return (if you fill one in).")

        assert_page_has_content("£527.00")
        assert page.has_no_content?("The tax charge only applies to the Child Benefit received between 7 January and 5 April 2013")
        assert page.has_no_content?("Your result for the next tax year may be higher")
        assert_page_has_content("To pay the tax charge you must fill in a Self Assessment tax return each tax year. Follow these steps:")
        assert_page_has_content("you should do this by 5 October 2014")
      end
    end # with the tax estimate

    context "with an Adjusted Net Income below the threshold" do
      setup do
        visit "/child-benefit-tax-calculator/main"

      end

      should "say there's nothing to pay" do
        choose "year-1", allow_label_click: true, visible: false
        choose "Yes", allow_label_click: true
        select "1", from: "part_year_children_count"

        select "2011", from: "starting_children_0_start_year"
        select "January", from: "starting_children_0_start_month"
        select "1", from: "starting_children_0_start_day"

        fill_in "Salary before tax", with: "49000"

        click_button "Calculate"

        assert page.has_no_content?("Received between 7 January and 5 April 2013.")
        assert page.has_no_content?("To work out the tax charge, enter your income")

        assert_page_has_content("£1,055.60")
        assert_page_has_content("Use this figure in your 2013 to 2014 Self Assessment tax return (if you fill one in).")
        assert_page_has_content("£0.00")
        assert_page_has_content("There is no tax charge if your income is below £50,099.")
      end
    end

    context "displaying results for full year children only" do
      setup do
        visit "/child-benefit-tax-calculator/main"
      end

      context "one child" do
        should "correctly display the amount for one child" do
          choose "year-3", allow_label_click: true, visible: false
          choose "No", allow_label_click: true

          click_button "Calculate"

          assert_page_has_content("£1,097.10")
        end
      end

      context "two children" do
        should "correctly display the amount for two children" do
          select "2", from: "children_count"
          choose "year-3", allow_label_click: true, visible: false
          choose "No", allow_label_click: true

          click_button "Calculate"

          assert_page_has_content("£1,823.20")
        end
      end
    end

    context "child benefit week runs Monday to Sunday" do
      setup do
        visit "/child-benefit-tax-calculator/main"
          # select "1", from: "children_count"
          # choose "year-0", allow_label_click: true, visible: false # 2012
          # choose "Yes", allow_label_click: true
      end

  # result is £263.90
      context "tax year is 2012/2013" do
        # should "have no child benefit when start date is 07/01/2013" do
        #   select "1", from: "children_count"
        #   choose "year-0", allow_label_click: true, visible: false # 2012
        #   choose "Yes", allow_label_click: true
        #
        #   select "2013", from: "starting_children_0_start_year"
        #   select "January", from: "starting_children_0_start_month"
        #   select "7", from: "starting_children_0_start_day"
        #
        #   click_button "Calculate"
        #
        #   assert_page_has_content("£243.60")
        # end

# result returns £20.30
        # should "have no child benefit when start date is 01/04/2013" do
        #   select "1", from: "children_count"
        #   choose "year-0", allow_label_click: true, visible: false # 2012
        #   choose "Yes", allow_label_click: true
        #   select "2013", from: "starting_children_0_start_year"
        #   select "April", from: "starting_children_0_start_month"
        #   select "1", from: "starting_children_0_start_day"
        #
        #   click_button "Calculate"
        #
        #   assert_page_has_content("£0.00")
        # end

        # should "have no child benefit when start date is 05/04/2013" do
        #   select "2013", from: "starting_children_0_start_year"
        #   select "April", from: "starting_children_0_start_month"
        #   select "5", from: "starting_children_0_start_day"
        #   choose "year-0", allow_label_click: true, visible: false # 2012
        #
        #   click_button "Calculate"
        #
        #   assert_page_has_content("£0.00")
        # end
      end

      context "tax year is 2016/2017" do
        setup do
            visit "/child-benefit-tax-calculator/main"
        end

        should "have no child benefit when start date is 31/03/2017" do
          select "1", from: "children_count"
          choose "year-1", allow_label_click: true, visible: false
          choose "Yes", allow_label_click: true
          select "2017", from: "starting_children_0_start_year"
          select "March", from: "starting_children_0_start_month"
          select "31", from: "starting_children_0_start_day"

          click_button "Calculate"

          within ".results" do
            within :xpath, ".//div[contains(@class, 'results_estimate')][.//h3[.='Child Benefit received']]" do
              page.should have_content("£0.00")
            end
          end
        end

        # should "have no child benefit when start date is 01/04/2017" do
        #   select "2017", from: "starting_children_0_start_year"
        #   select "April", from: "starting_children_0_start_month"
        #   select "1", from: "starting_children_0_start_day"
        #   choose "year-4", allow_label_click: true, visible: false
        #
        #   click_button "Calculate"
        #
        #   assert_page_has_content("£0.00")
        # end

        # should "have no child benefit when start date is 05/04/2017" do
        #   select "2017", from: "starting_children_0_start_year"
        #   select "April", from: "starting_children_0_start_month"
        #   select "5", from: "starting_children_0_start_day"
        #   choose "year-4", allow_label_click: true, visible: false
        #
        #   click_button "Calculate"
        #
        #   assert_page_has_content("£0.00")
        # end
      end
    end
  end
end
