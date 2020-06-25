require "test_helper"

class ApplicationHelperTest < ActiveSupport::TestCase
  setup do
    @helper = ApplicationController.helpers
  end

  context "#step" do
    should "generate the html for a step" do
      assert_equal ApplicationController.helpers.step(1, "Blah"), "<span class=\"step step-1\">Blah</span>"
    end
  end

  context "#current_path_without_query_string" do
    should "return the path of the current request" do
      @helper.stubs(:request).returns(ActionDispatch::TestRequest.new("PATH_INFO" => "/foo/bar"))
      assert_equal "/foo/bar", @helper.current_path_without_query_string
    end

    should "return the path of the current request stripping off any query string parameters" do
      @helper.stubs(:request).returns(ActionDispatch::TestRequest.new("PATH_INFO" => "/foo/bar", "QUERY_STRING" => "ham=jam&spam=gram"))
      assert_equal "/foo/bar", @helper.current_path_without_query_string
    end
  end

  context "#form_errors" do
    should "format and return errors for the top of the page" do
      class ErrorDouble
        def messages
          {
            start_date: [
              "enter the date Child Benefit started",
              "enter a valid date - there are only 29 days in February",
            ],
            end_date: [
              "child Benefit start date must be before stop date",
            ],
          }
        end
      end

      @calculator = ChildBenefitTaxCalculator.new
      data = []

      @calculator.stubs(:starting_children).returns(data)
      @calculator.stubs(:errors).returns(
        tax_year: "select a tax year",
        part_year_children_count: "the number of children you're claiming a part year for can't be more than the total number of children you're claiming for",
      )

      @helper.instance_variable_set("@calculator", @calculator)

      data.stubs(:map).returns([ErrorDouble.new])

      expected = [
        {
          href: "#children_heading",
          text: "enter the date Child Benefit started",
        },
        {
          href: "#children_heading",
          text: "enter a valid date - there are only 29 days in February",
        },
        {
          href: "#children_heading",
          text: "child Benefit start date must be before stop date",
        },
        {
          href: "#tax_year",
          text: "select a tax year",
        },
        {
          href: "#part_year_children_count",
          text: "the number of children you're claiming a part year for can't be more than the total number of children you're claiming for",
        },
      ]

      assert_equal expected, @helper.form_errors
    end
  end

  context "#children_select_options" do
    should "generate an array of options for the select component" do
      options = [
        {
          text: 1,
          value: 1,
          selected: false,
        },
        {
          text: 2,
          value: 2,
          selected: false,
        },
        {
          text: 3,
          value: 3,
          selected: false,
        },
        {
          text: 4,
          value: 4,
          selected: false,
        },
        {
          text: 5,
          value: 5,
          selected: false,
        },
        {
          text: 6,
          value: 6,
          selected: false,
        },
        {
          text: 7,
          value: 7,
          selected: true,
        },
        {
          text: 8,
          value: 8,
          selected: false,
        },
        {
          text: 9,
          value: 9,
          selected: false,
        },
        {
          text: 10,
          value: 10,
          selected: false,
        },
      ]

      assert_equal options, @helper.children_select_options(7)
    end
  end

  context "#q2_radio_options" do
    should "generate an array of hashes for the radio component for question 2" do
      # The last hash is for the current year (here provided by Timecop as 2020).
      # The other hashes are for the previous years.
      # The only hash with checked true is that for the year passed to the calculator (here 2019).

      # teardown do
      #   @helper.remove_instance_variable("@calculator")
      # end

      Timecop.freeze("2020-01-01") do
        @helper.instance_variable_set("@calculator", ChildBenefitTaxCalculator.new(year: 2019))

        options = [
          { value: "2012", text: "2012 to 2013", checked: false },
          { value: "2013", text: "2013 to 2014", checked: false },
          { value: "2014", text: "2014 to 2015", checked: false },
          { value: "2015", text: "2015 to 2016", checked: false },
          { value: "2016", text: "2016 to 2017", checked: false },
          { value: "2017", text: "2017 to 2018", checked: false },
          { value: "2018", text: "2018 to 2019", checked: false },
          { value: "2019", text: "2019 to 2020", checked: true },
          { value: "2020", text: "2020 to 2021", checked: false },
        ]
        assert_equal options, @helper.q2_radio_options
      end
    end
  end

  # This Q will change in smart-answers and won't be using js
  # Sub questions will be separated into individual pages
  # context "#q3_radio_options" do
  #   should "generate an array of options for the radio component for question 3" do
  #     @calculator = ChildBenefitTaxCalculator.new(year: "2015")
  #     conditional_file_content = render file: Rails.root.join("app/views/child_benefit_tax/_part_tax_year_conditional.html.erb")
  #
  #     options = [
  #       {
  #         value: "yes",
  #         text: "Yes",
  #         checked: false,
  #         conditional: conditional_file_content,
  #       },
  #       {
  #         value: "no",
  #         text: "No",
  #         checked: false,
  #         conditional: nil,
  #       },
  #     ]
  #
  #     assert_equal options, @helper.q3_radio_options
  #   end
  # end

  context "#date_options" do
    should "return days for partial children options in q3" do
      days = @helper.day_options("2015-04-06")

      assert_equal 32, days.length

      assert_equal (
        {
          text: "", value: ""
          }
      ), days[0]

      assert_equal (
        {
          selected: false,
          text: 1,
          value: 1,
        }
      ), days[1]

      assert_equal (
        {
          selected: false,
          text: 31,
          value: 31,
        }
      ), days[31]

      days[1..-1].each_with_index do |option, i|
        if i == 5
          assert option[:selected]
          # expect(option[:selected]).to eq(true)
        else
          assert_not option[:selected]
          # expect(option[:selected]).to eq(false)
        end
      end
    end

    should "return months for partial children options in q3" do
      months = @helper.month_options("2015-04-06")

      assert_equal 13, months.length

      assert_equal (
        {
          text: "",
          value: "",
        }
      ), months[0]

      assert_equal (
        {
          selected: false,
          text: "January",
          value: 1,
        }
      ), months[1]

      assert_equal (
        {
          selected: false,
          text: "December",
          value: 12,
        }
      ), months[12]

      months[1..-1].each_with_index do |option, i|
        if i == 3
          assert option[:selected]
        else
          assert_not option[:selected]
        end
      end
    end

    should "return years for partial children options in q3" do
      Timecop.freeze("2020-01-01") do
        years = @helper.year_options("2011-04-06")

        assert_equal 12, years.length

        assert_equal (
          {
            text: "",
            value: "",
          }
        ), years[0]

        assert_equal (
          {
            selected: true,
            text: 2011,
            value: 2011,
          }
        ), years[1]

        assert_equal (
          {
            selected: false,
            text: 2021,
            value: 2021,
          }
        ), years[-1]

        years.each_with_index do |option, i|
          if i == 1
            assert option[:selected]
          else
            assert_not option[:selected]
          end
        end
      end
    end
  end
end
