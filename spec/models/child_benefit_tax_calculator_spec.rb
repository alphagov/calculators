# encoding: utf-8

require "spec_helper"

describe ChildBenefitTaxCalculator, type: :model do
  before { Timecop.travel("2020-04-02") }
  after { Timecop.return }

  it "uses the adjusted net income if it's passed in" do
    calc = ChildBenefitTaxCalculator.new(adjusted_net_income: "20")
    expect(calc.adjusted_net_income).to eq(20)
  end

  it "isnt valid if enough detail is not supplied" do
    # nothing given
    expect(ChildBenefitTaxCalculator.new.can_calculate?).to eq(false)
  end

  it "is valid if given enough detail" do
    expect(ChildBenefitTaxCalculator.new(
      year: "2017", children_count: "1",
      is_part_year_claim: "yes",
      part_year_children_count: "1",
      starting_children: { "0" => { start: { year: "2016", month: "01", day: "01" } } }
    ).can_calculate?).to eq(true)
  end

  it "parses integers from various formats of numerical input" do
    calc = ChildBenefitTaxCalculator.new(adjusted_net_income: "£100,900")
    expect(calc.adjusted_net_income).to eq(100900)
  end

  describe "input validation" do
    before(:each) do
      @calc = ChildBenefitTaxCalculator.new(children_count: "1", is_part_year_claim: "yes", part_year_children_count: "1")
      @calc.valid?
    end
    it "should contain errors for year if none is given" do
      expect(@calc.errors.has_key?(:tax_year)).to eq(true)
    end
    it "should contain errors for year if outside of tax years range" do
      @calc = ChildBenefitTaxCalculator.new(year: "2010")
      @calc.valid?
      expect(@calc.errors).to have_key(:tax_year)
    end
    it "should contain errors if number of children is less than those being part claimed" do
      @calc = ChildBenefitTaxCalculator.new(
        year: "2013",
        children_count: "1",
        part_year_children_count: "2",
        is_part_year_claim: "yes",
        starting_children: {
          "0" => {
            start: { year: "2013", month: "01", day: "01" },
            stop: { year: "2014", month: "01", day: "01" },
          },
          "1" => {
            start: { year: "2013", month: "03", day: "01" },
            stop: { year: "2014", month: "03", day: "01" },
          },
        },
      )
      @calc.valid?

      expect(@calc.errors).to have_key(:part_year_children_count)
    end
    it "should validate dates provided for children" do
      expect(@calc.starting_children.first.errors.has_key?(:start_date)).to eq(true)

      @calc.starting_children << StartingChild.new(
        start: { year: "2012", month: "02", day: "01" },
        stop: { year: "2012", month: "01", day: "01" },
      )
      @calc.valid?
      expect(@calc.starting_children.second.errors.has_key?(:end_date)).to eq(true)
    end
    it "should contain an error on starting child if all outside of tax year" do
      @calc = ChildBenefitTaxCalculator.new(
        year: "2018",
        children_count: "1",
        is_part_year_claim: "yes",
        part_year_children_count: "1",
        starting_children: {
          "0" => {
            start: { year: "2016", month: "01", day: "01" },
            stop: { year: "2017", month: "01", day: "01" },
          },
        },
      )
      @calc.valid?
      expect(@calc.starting_children.first.errors).to have_key(:end_date)
    end

    it "can't calculate if there are any errors" do
      @calc = ChildBenefitTaxCalculator.new(
        year: "2013",
        children_count: "1",
        is_part_year_claim: "yes",
        part_year_children_count: "1",
        starting_children: {
          "0" => {
            start: { year: "2011", month: "01", day: "01" },
            stop: { year: "2012", month: "01", day: "01" },
          },
        },
      )
      @calc.valid?

      expect(@calc.can_calculate?).to eq false
    end
    it "should be valid on starting child when some inside the tax year" do
      @calc = ChildBenefitTaxCalculator.new(
        year: "2018",
        children_count: "3",
        is_part_year_claim: "yes",
        part_year_children_count: "3",
        starting_children: {
          "0" => {
            start: { year: "2016", month: "01", day: "01" },
            stop: { year: "2017", month: "01", day: "01" },
          },
          "1" => {
            start: { year: "2018", month: "01", day: "01" },
            stop: { year: "2019", month: "01", day: "01" },
          },
          "2" => {
            start: { year: "2018", month: "01", day: "01" },
          },
        },
      )
      @calc.valid?
      expect(@calc).not_to have_errors
      expect(@calc.starting_children.first.errors).to be_empty
    end
    describe "has_errors?" do
      it "should be true if the calculator has errors" do
        @calc.starting_children << StartingChild.new(start: { year: "2012", month: "02", day: "01" })
        expect(@calc.has_errors?).to eq(true)
        expect(@calc.errors.size).to eq(1)
      end
      it "should be true if any starting children have errors" do
        calc = ChildBenefitTaxCalculator.new(
          year: "2017",
          children_count: "1",
          is_part_year_claim: "yes",
          part_year_children_count: "1",
        )
        calc.valid?
        expect(calc.errors).to be_empty
        expect(calc.has_errors?).to eq(true)
      end
      it "should be false if the tax year and starting date are valid" do
        expect(ChildBenefitTaxCalculator.new(
          year: "2017",
          children_count: "1",
          is_part_year_claim: "yes",
          part_year_children_count: "1",
          starting_children: {
            "0" => { start: { year: "2017", month: "01", day: "07" } },
          },
        ).has_errors?).to eq(false)
      end
    end

    describe "#is_part_year_claim" do
      it "should contain errors if tax claim duration is not provided" do
        calc = ChildBenefitTaxCalculator.new(children_count: "1", year: 2017)
        calc.valid?
        expect(calc.errors).to have_key(:is_part_year_claim)
        expect(calc.errors.size).to eq(1)
      end
      it "should not contain errors if tax claim duration is set to no" do
        calc = ChildBenefitTaxCalculator.new(children_count: "1", year: 2017, is_part_year_claim: "no")
        calc.valid?
        expect(calc.errors).to be_empty
      end
      it "should not contain errors if tax claim duration is set to yes" do
        calc = ChildBenefitTaxCalculator.new(children_count: "1",
            year: 2017,
            is_part_year_claim: "yes",
            part_year_children_count: "1",
            starting_children: {
              "0" => { start: { year: "2017", month: "01", day: "07" } },
            })
        calc.valid?
        expect(calc.errors).to be_empty
      end
    end
  end

  describe "full year children only" do
    it "should be able to calculate the child benefit amount" do
      calc = ChildBenefitTaxCalculator.new(
        children_count: 1,
        year: "2016",
        is_part_year_claim: "no",
        starting_children: {},
      )
      expect(calc.can_calculate?).to eq(true)
    end
  end

  describe "full year and part year children" do
    it "should not contain errors if valid part year and full year children" do
      calc = ChildBenefitTaxCalculator.new(
        children_count: "3",
        year: "2016",
        is_part_year_claim: "yes",
        part_year_children_count: "2",
        starting_children: {
          "0" => {
            start: { year: "2016", month: "06", day: "13" },
            stop: { year: "2016", month: "06", day: "19" },
          },
          "1" => {
            start: { year: "2016", month: "06", day: "20" },
            stop: { year: "2016", month: "06", day: "26" },
          },
        },
      )
      calc.valid?
      calc.starting_children.each do |child|
        expect(child.errors).to be_empty
      end
    end
  end

  describe "calculating the number of weeks/Mondays" do
    context "for the full tax year 2016/2017" do
      it "should calculate there are 52 Mondays" do
        calc = ChildBenefitTaxCalculator.new(
          year: "2016",
          children_count: "1",
          is_part_year_claim: "no",
        )
        start_date = calc.child_benefit_start_date
        end_date = calc.child_benefit_end_date
        expect(calc.total_number_of_mondays(start_date, end_date)).to eq(52)
      end
    end
    context "for the full tax year 2017/2018" do
      it "should calculate there are 52 Mondays" do
        calc = ChildBenefitTaxCalculator.new(
          year: "2017",
          children_count: "1",
          is_part_year_claim: "no",
        )
        start_date = calc.child_benefit_start_date
        end_date = calc.child_benefit_end_date
        expect(calc.total_number_of_mondays(start_date, end_date)).to eq(52)
      end
    end
    context "for the full tax year 2018/2019" do
      it "should calculate there are 52 Mondays" do
        calc = ChildBenefitTaxCalculator.new(
          year: "2018",
          children_count: "1",
          is_part_year_claim: "no",
        )
        start_date = calc.child_benefit_start_date
        end_date = calc.child_benefit_end_date
        expect(calc.total_number_of_mondays(start_date, end_date)).to eq(52)
      end
    end
    context "for the full tax year 2019/2020" do
      it "should calculate there are 52 Mondays" do
        calc = ChildBenefitTaxCalculator.new(
          year: "2019",
          children_count: "1",
          is_part_year_claim: "no",
        )
        start_date = calc.child_benefit_start_date
        end_date = calc.child_benefit_end_date
        expect(calc.total_number_of_mondays(start_date, end_date)).to eq(52)
      end
    end
    context "for the full tax year 2020/2021" do
      it "should calculate there are 53 Mondays" do
        calc = ChildBenefitTaxCalculator.new(
          year: "2020",
          children_count: "1",
          is_part_year_claim: "no",
        )
        start_date = calc.child_benefit_start_date
        end_date = calc.child_benefit_end_date
        expect(calc.total_number_of_mondays(start_date, end_date)).to eq(53)
      end
    end
  end

  describe "calculating child benefits received" do
    context "for the tax year 2019" do
      it "should give the total amount received for the full tax year for one child" do
        expect(ChildBenefitTaxCalculator.new(
          year: "2019",
          children_count: "1",
          is_part_year_claim: "no",
        ).benefits_claimed_amount.round(2)).to eq(1076.4)
      end
      it "should give the total amount received for the full tax year for more than one child" do
        expect(ChildBenefitTaxCalculator.new(
          year: "2019",
          children_count: "2",
          is_part_year_claim: "no",
        ).benefits_claimed_amount.round(2)).to eq(1788.8)
      end
      it "should give the total amount for a partial tax year for one child" do
        expect(ChildBenefitTaxCalculator.new(
          year: "2019",
          children_count: "1",
          is_part_year_claim: "yes",
          part_year_children_count: "1",
          starting_children: {
            "0" => {
              start: { year: "2020", month: "01", day: "06" },
              stop: { year: "2020", month: "04", day: "05" },
            },
          },
        ).benefits_claimed_amount.round(2)).to eq(269.1)
      end
      it "should give the total amount for a partial tax year for more than one child" do
        expect(ChildBenefitTaxCalculator.new(
          year: "2019",
          children_count: "2",
          is_part_year_claim: "yes",
          part_year_children_count: "2",
          starting_children: {
            "0" => { # 18 weeks/Mondays
              start: { year: "2019", month: "12", day: "2" },
              stop: { year: "2020", month: "04", day: "05" },
            },
            "1" => { # 13 weeks/Mondays
              start: { year: "2020", month: "01", day: "06" },
              stop: { year: "2020", month: "04", day: "05" },
            },
          },
        ).benefits_claimed_amount.round(2)).to eq(550.7)
      end
      it "should give the total amount for three children, two of which are partial tax years" do
        expect(ChildBenefitTaxCalculator.new(
          year: "2019",
          children_count: "3",
          is_part_year_claim: "yes",
          part_year_children_count: "2",
          starting_children: {
            "0" => { # 18 weeks/Mondays
              start: { year: "2019", month: "12", day: "2" },
              stop: { year: "2020", month: "04", day: "05" },
            },
            "1" => { # 13 weeks/Mondays
              start: { year: "2020", month: "01", day: "06" },
              stop: { year: "2020", month: "04", day: "05" },
            },
          },
        ).benefits_claimed_amount.round(2)).to eq(1501.1)
      end
    end
  end

  describe "calculating adjusted net income" do
    it "should use the adjusted_net_income parameter when none of the calculation params are used" do
      expect(ChildBenefitTaxCalculator.new(
        adjusted_net_income: "50099",
        other_income: "0",
        year: "2012",
        children_count: 2,
        is_part_year_claim: "no",
      ).adjusted_net_income).to eq(50099)
    end

    it "should calculate the adjusted net income with the relevant params" do
      expect(ChildBenefitTaxCalculator.new(
        gross_income: "£68000",
        other_income: "£2000",
        pensions: "£2000",
        property: "£1000",
        non_employment_income: "£1000",
        pension_contributions_from_pay: "£2000",
        gift_aid_donations: "£1000",
        retirement_annuities: "£1000",
        cycle_scheme: "£800",
        childcare: "£1500",
        year: "2012",
        children_count: 2,
        is_part_year_claim: "no",
      ).adjusted_net_income).to eq(69950)
    end

    it "should ignore the adjusted_net_income parameter when using the calculation form params" do
      expect(ChildBenefitTaxCalculator.new(
        adjusted_net_income: "£65,000",
        gross_income: "£68000",
        other_income: "£2000",
        pensions: "£2000",
        property: "£1000",
        non_employment_income: "£1000",
        pension_contributions_from_pay: "£2000",
        gift_aid_donations: "£1000",
        retirement_annuities: "£1000",
        cycle_scheme: "£800",
        childcare: "£1500",
        year: "2012",
        children_count: 2,
        is_part_year_claim: "no",
      ).adjusted_net_income).to eq(69950)
    end
  end

  describe "calculating percentage tax charge" do
    it "should be 0.0 for an income of 50099" do
      expect(ChildBenefitTaxCalculator.new(
        adjusted_net_income: "50099",
        year: "2012",
        children_count: 2,
        is_part_year_claim: "no",
      ).percent_tax_charge).to eq(0.0)
    end
    it "should be 1.0 for an income of 50199" do
      expect(ChildBenefitTaxCalculator.new(
        adjusted_net_income: "50199",
        year: "2012",
        children_count: 2,
        is_part_year_claim: "no",
      ).percent_tax_charge).to eq(1.0)
    end
    it "should be 2.0 for an income of 50200" do
      expect(ChildBenefitTaxCalculator.new(
        adjusted_net_income: "50200",
        year: "2012",
        children_count: 2,
        is_part_year_claim: "no",
      ).percent_tax_charge).to eq(2.0)
    end
    it "should be 40.0 for an income of 54013" do
      expect(ChildBenefitTaxCalculator.new(
        adjusted_net_income: "54013",
        year: "2012",
        children_count: 2,
        is_part_year_claim: "no",
      ).percent_tax_charge).to eq(40.0)
    end
    it "should be 40.0 for an income of 54089" do
      expect(ChildBenefitTaxCalculator.new(
        adjusted_net_income: "54089",
        year: "2012",
        children_count: 2,
        is_part_year_claim: "no",
      ).percent_tax_charge).to eq(40.0)
    end
    it "should be 99.0 for an income of 59999" do
      expect(ChildBenefitTaxCalculator.new(
        adjusted_net_income: "59999",
        year: "2012",
        is_part_year_claim: "no",
        children_count: 2,
      ).percent_tax_charge).to eq(99.0)
    end
    it "should be 100.0 for an income of 60000" do
      expect(ChildBenefitTaxCalculator.new(
        adjusted_net_income: "60000",
        year: "2012",
        children_count: 2,
        is_part_year_claim: "no",
      ).percent_tax_charge).to eq(100.0)
    end
    it "should be 100.0 for an income of 60001" do
      expect(ChildBenefitTaxCalculator.new(
        adjusted_net_income: "60001",
        year: "2012",
        children_count: 2,
        is_part_year_claim: "no",
      ).percent_tax_charge).to eq(100.0)
    end
  end

  describe "calculating the correct amount owed" do
    describe "below the income threshold" do
      it "should be true for incomes under the threshold" do
        expect(ChildBenefitTaxCalculator.new(
          adjusted_net_income: "49999",
          is_part_year_claim: "yes",
          children_count: 1,
          part_year_children_count: "1",
          starting_children: {
            "0" => { start: { year: "2018", month: "01", day: "01" } },
          },
          year: "2019",
        ).nothing_owed?).to eq(true)
      end

      it "should be true for incomes over the threshold" do
        expect(ChildBenefitTaxCalculator.new(
          adjusted_net_income: "50100",
          is_part_year_claim: "yes",
          children_count: 1,
          part_year_children_count: "1",
          starting_children: {
            "0" => { start: { year: "2018", month: "01", day: "01" } },
          },
          year: "2019",
        ).nothing_owed?).to eq(false)
      end
    end
  end # no starting / stopping children

  describe "starting and stopping children" do
    describe "tax year 2016" do
      it "calculates correctly with starting children" do
        calc = ChildBenefitTaxCalculator.new(
          adjusted_net_income: "61000",
          children_count: 1,
          is_part_year_claim: "yes",
          part_year_children_count: "1",
          starting_children: {
            "0" => {
              start: { year: "2017", month: "03", day: "01" },
              stop: { year: "", month: "", day: "" },
            },
          },
          year: "2016",
        )
        #child from 01/03 to 01/04 => 5 weeks * 20.7
        expect(calc.tax_estimate.round(1)).to eq(103)
      end

      it "correctly calculates weeks for a child who started & stopped in tax year" do
        calc = ChildBenefitTaxCalculator.new(
          adjusted_net_income: "61000",
          children_count: 1,
          is_part_year_claim: "yes",
          part_year_children_count: "1",
          starting_children: {
            "0" => {
              start: { year: "2017", month: "02", day: "01" },
              stop: { year: "2017", month: "03", day: "01" },
            },
          },
          year: "2016",
        )
        #child from 01/02 to 01/03 => 4 weeks * 20.7
        expect(calc.tax_estimate.round(1)).to eq(82)
      end
    end # tax year 2016
  end # starting & stopping children

  describe "HMRC test scenarios" do
    describe "tests for 2016 rates" do
      it "should calculate 3 children already in the household for all of 2016/17" do
        expect(ChildBenefitTaxCalculator.new(
          year: "2016",
          children_count: 3,
          is_part_year_claim: "no",
       ).benefits_claimed_amount.round(2)).to eq(2501.2)
      end

      it "should give the total amount of benefits received for a full tax year 2016" do
        expect(ChildBenefitTaxCalculator.new(
          year: "2016",
          children_count: "1",
          is_part_year_claim: "no",
        ).benefits_claimed_amount.round(2)).to eq(1076.4)
      end

      it "should give total amount of benefits one child full year one child half a year" do
        expect(ChildBenefitTaxCalculator.new(
          year: "2016",
          children_count: 2,
          is_part_year_claim: "yes",
          part_year_children_count: "1",
          starting_children: {
            "0" => {
              start: { day: "06", month: "04", year: "2016" },
              stop: { day: "06", month: "10", year: "2016" },
            },
          },
        ).benefits_claimed_amount.round(2)).to eq(1432.6)
      end

      it "should give total amount of benefits for one child for half a year" do
        calc = ChildBenefitTaxCalculator.new(
          year: "2016",
          children_count: 1,
          is_part_year_claim: "yes",
          part_year_children_count: "1",
          starting_children: {
            "0" => {
              start: { day: "06", month: "04", year: "2016" },
              stop: { day: "06", month: "11", year: "2016" },
            },
          },
        )
        expect(calc.benefits_claimed_amount.round(2)).to eq(621.0)
      end

      it "should set the start date to start of the selected tax year" do
        calc = ChildBenefitTaxCalculator.new(
          year: "2016",
          children_count: 1,
          is_part_year_claim: "no",
        )

        expect(calc.child_benefit_start_date).to eq(Date.parse("06 April 2016"))
        expect(calc.child_benefit_end_date).to eq(Date.parse("05 April 2017"))
      end

      it "should set the stop date to end of the selected tax year" do
        calc = ChildBenefitTaxCalculator.new(
          year: "2016",
          children_count: 1,
          is_part_year_claim: "yes",
          part_year_children_count: "1",
          starting_children: {
            "0" => {
              start: { day: "06", month: "04", year: "2016" },
              stop: { day: "", month: "", year: "" },
            },
          },
        )

        expect(calc.child_benefit_end_date).to eq(Date.parse("05 April 2017"))
      end

      it "should correctly calculate the benefit amount for multiple full year and part year children" do
        expect(ChildBenefitTaxCalculator.new(
          year: "2016",
          children_count: 4,
          is_part_year_claim: "yes",
          part_year_children_count: "2",
          starting_children: {
            "0" => {
              start: { day: "01", month: "06", year: "2016" },
              stop: { day: "01", month: "09", year: "2016" },
            },
            "1" => {
              start: { day: "01", month: "01", year: "2017" },
              stop: { day: "01", month: "04", year: "2017" },
            },
          },
        ).benefits_claimed_amount.round(2)).to eq(2145)
      end
    end
  end
end
