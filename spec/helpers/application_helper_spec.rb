require "spec_helper"

describe ApplicationHelper, type: :helper do
  describe "#step" do
    it "generates the html for a step" do
      expect(helper.step(1, "Blah")).to eq("<span class=\"step step-1\">Blah</span>")
    end
  end

  describe "#current_path_without_query_string" do
    it "returns the path of the current request" do
      allow(helper).to receive(:request).and_return(ActionDispatch::TestRequest.new("PATH_INFO" => "/foo/bar"))
      assert_equal "/foo/bar", helper.current_path_without_query_string
    end

    it "returns the path of the current request stripping off any query string parameters" do
      allow(helper).to receive(:request).and_return(ActionDispatch::TestRequest.new("PATH_INFO" => "/foo/bar", "QUERY_STRING" => "ham=jam&spam=gram"))
      assert_equal "/foo/bar", helper.current_path_without_query_string
    end
  end

  describe "#form_errors" do
    it "formats and returns errors for the top of the page" do
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

      @calculator = double
      data = double

      allow(@calculator).to receive(:starting_children).and_return(data)
      allow(@calculator).to receive(:errors).and_return(
        tax_year: "select a tax year",
        part_year_children_count: "the number of children you're claiming a part year for can't be more than the total number of children you're claiming for",
      )
      allow(data).to receive(:map).and_return([ErrorDouble.new])

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

      expect(form_errors).to eq(expected)
    end
  end

  describe "#children_select_options" do
    it "generates an array of options for the select component" do
      expect(children_select_options(7)).to eq(
        [
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
        ],
      )
    end
  end

  describe "#q2_radio_options" do
    it "generates an array of options for the radio component for question 2" do
      @calculator = ChildBenefitTaxCalculator.new(year: "2015")

      expect(q2_radio_options.length).to eq(8)
      expect(q2_radio_options[0]).to eq(
        value: "2012",
        text: "2012 to 2013",
        checked: false,
      )

      expect(q2_radio_options[7]).to eq(
        value: "2019",
        text: "2019 to 2020",
        checked: false,
      )

      q2_radio_options.each_with_index do |option, i|
        if i == 3
          expect(option[:checked]).to eq(true)
        else
          expect(option[:checked]).to eq(false)
        end
      end
    end
  end

  describe "#q3_radio_options" do
    it "generates an array of options for the radio component for question 3" do
      @calculator = ChildBenefitTaxCalculator.new(year: "2015")

      conditional_file_content = render file: "#{Rails.root}/app/views/child_benefit_tax/_part_tax_year_conditional.html.erb"

      expect(q3_radio_options).to eq(
        [
          {
            value: "yes",
            text: "Yes",
            checked: false,
            conditional: conditional_file_content,
          },
          {
            value: "no",
            text: "No",
            checked: false,
            conditional: nil,
          },
        ],
      )
    end
  end

  describe "#date_options" do
    it "returns days for partial children options in q3" do
      days = day_options("2015-04-06")

      expect(days.length).to eq(32)
      expect(days[0]).to eq(
        text: "",
        value: "",
      )

      expect(days[1]).to eq(
        selected: false,
        text: 1,
        value: 1,
      )

      expect(days[31]).to eq(
        selected: false,
        text: 31,
        value: 31,
      )

      days[1..-1].each_with_index do |option, i|
        if i == 5
          expect(option[:selected]).to eq(true)
        else
          expect(option[:selected]).to eq(false)
        end
      end
    end

    it "returns months for partial children options in q3" do
      months = month_options("2015-04-06")

      expect(months.length).to eq(13)
      expect(months[0]).to eq(
        text: "",
        value: "",
      )

      expect(months[1]).to eq(
        selected: false,
        text: "January",
        value: 1,
      )

      expect(months[12]).to eq(
        selected: false,
        text: "December",
        value: 12,
      )

      months[1..-1].each_with_index do |option, i|
        if i == 3
          expect(option[:selected]).to eq(true)
        else
          expect(option[:selected]).to eq(false)
        end
      end
    end

    it "returns years for partial children options in q3" do
      years = year_options("2015-04-06")

      expect(years.length).to eq(11)
      expect(years[0]).to eq(
        text: "",
        value: "",
      )

      expect(years[1]).to eq(
        selected: false,
        text: 2011,
        value: 2011,
      )

      expect(years[10]).to eq(
        selected: false,
        text: 2020,
        value: 2020,
      )

      years[1..-1].each_with_index do |option, i|
        if i == 4
          expect(option[:selected]).to eq(true)
        else
          expect(option[:selected]).to eq(false)
        end
      end
    end
  end
end
