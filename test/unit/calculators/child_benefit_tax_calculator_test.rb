require_relative "../../test_helper"

class ChildBenefitTaxCalculatorTest < ActiveSupport::TestCase
  context ChildBenefitTaxCalculator do
    setup do
      Timecop.travel("2020-04-02")
    end

    teardown do
      Timecop.return
    end

    should "use the adjusted net income if it's passed in" do
      calc = ChildBenefitTaxCalculator.new(adjusted_net_income: "20")
      assert_equal 20, calc.adjusted_net_income
    end

    should "not be valid if enough detail is not supplied" do
      # nothing given
      assert_not ChildBenefitTaxCalculator.new.can_calculate?
    end

    should "be valid if given enough detail" do
      assert ChildBenefitTaxCalculator.new(
        year: "2017",
        children_count: "1",
        is_part_year_claim: "yes",
        part_year_children_count: "1",
        starting_children: { "0" => { start: { year: "2016", month: "01", day: "01" } } },
      ).can_calculate?
    end

    should "parse integers from various formats of numerical input" do
      assert_equal 100_900, ChildBenefitTaxCalculator.new(adjusted_net_income: "£100,900").adjusted_net_income
    end

    context "input validation" do
      setup do
        @calc = ChildBenefitTaxCalculator.new(children_count: "1", is_part_year_claim: "yes", part_year_children_count: "1")
        @calc.valid?
      end

      should "contain errors for year if none is given" do
        assert @calc.errors.key?(:tax_year)
      end

      should "contain errors for year if outside of tax years range" do
        @calc = ChildBenefitTaxCalculator.new(year: "2010")
        @calc.valid?
        assert @calc.errors.key?(:tax_year)
      end

      should "contain errors if number of children is less than those being part claimed" do
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

        assert @calc.errors.key?(:part_year_children_count)
      end

      should "validate dates provided for children" do
        assert @calc.starting_children.first.errors.key?(:start_date)

        @calc.starting_children << StartingChild.new(
          start: { year: "2012", month: "02", day: "01" },
          stop: { year: "2012", month: "01", day: "01" },
        )
        @calc.valid?
        assert @calc.starting_children.second.errors.key?(:end_date)
      end

      should "contain an error on starting child if all outside of tax year" do
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
        assert @calc.starting_children.first.errors.key?(:end_date)
      end

      should "not calculate if there are any errors" do
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

        assert_not @calc.can_calculate?
      end

      should "be valid on starting child when some inside the tax year" do
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

        assert_empty @calc.errors
        assert_empty @calc.starting_children.first.errors
      end

      context "has_errors?" do
        should "be true if the calculator has errors" do
          @calc.starting_children << StartingChild.new(start: { year: "2012", month: "02", day: "01" })
          assert @calc.has_errors?
          assert_equal 1, @calc.errors.size
        end

        should "be true if any starting children have errors" do
          calc = ChildBenefitTaxCalculator.new(
            year: "2017",
            children_count: "1",
            is_part_year_claim: "yes",
            part_year_children_count: "1",
          )
          calc.valid?
          assert_empty calc.errors
          assert calc.has_errors?
        end

        should "be false if the tax year and starting date are valid" do
          assert_not ChildBenefitTaxCalculator.new(
            year: "2017",
            children_count: "1",
            is_part_year_claim: "yes",
            part_year_children_count: "1",
            starting_children: {
              "0" => { start: { year: "2017", month: "01", day: "07" } },
            },
          ).has_errors?
        end
      end

      context "#is_part_year_claim" do
        should "contain errors if tax claim duration is not provided" do
          calc = ChildBenefitTaxCalculator.new(children_count: "1", year: 2017)
          calc.valid?
          assert calc.errors.key?(:is_part_year_claim)
          assert_equal 1, calc.errors.size
        end

        should "not contain errors if tax claim duration is set to no" do
          calc = ChildBenefitTaxCalculator.new(children_count: "1", year: 2017, is_part_year_claim: "no")
          calc.valid?
          assert_empty calc.errors
        end

        should "not contain errors if tax claim duration is set to yes" do
          calc = ChildBenefitTaxCalculator.new(
            children_count: "1",
            year: 2017,
            is_part_year_claim: "yes",
            part_year_children_count: "1",
            starting_children: {
              "0" => { start: { year: "2017", month: "01", day: "07" } },
            },
          )
          calc.valid?
          assert_empty calc.errors
        end
      end
    end

    context "full year children only" do
      should "be able to calculate the child benefit amount" do
        calc = ChildBenefitTaxCalculator.new(
          children_count: 1,
          year: "2016",
          is_part_year_claim: "no",
          starting_children: {},
        )
        assert calc.can_calculate?
      end
    end

    context "full year and part year children" do
      should "not contain errors if valid part year and full year children" do
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
          assert_empty child.errors
        end
      end
    end

    context "calculating the number of weeks/Mondays" do
      context "for the full tax year 2012/2013" do
        should "calculate there are 13 Mondays" do
          calc = ChildBenefitTaxCalculator.new(
            year: "2012",
            children_count: "1",
            is_part_year_claim: "no",
          )
          start_date = calc.child_benefit_start_date
          end_date = calc.child_benefit_end_date
          assert_equal 13, calc.total_number_of_mondays(start_date, end_date)
        end
      end

      context "for the full tax year 2013/2014" do
        should "calculate there are 52 Mondays" do
          calc = ChildBenefitTaxCalculator.new(
            year: "2013",
            children_count: "1",
            is_part_year_claim: "no",
          )
          start_date = calc.child_benefit_start_date
          end_date = calc.child_benefit_end_date
          assert_equal 52, calc.total_number_of_mondays(start_date, end_date)
        end
      end

      context "for the full tax year 2014/2015" do
        should "calculate there are 52 Mondays" do
          calc = ChildBenefitTaxCalculator.new(
            year: "2014",
            children_count: "1",
            is_part_year_claim: "no",
          )
          start_date = calc.child_benefit_start_date
          end_date = calc.child_benefit_end_date
          assert_equal 52, calc.total_number_of_mondays(start_date, end_date)
        end
      end

      context "for the full tax year 2015/2016" do
        should "calculate there are 53 Mondays" do
          calc = ChildBenefitTaxCalculator.new(
            year: "2015",
            children_count: "1",
            is_part_year_claim: "no",
          )
          start_date = calc.child_benefit_start_date
          end_date = calc.child_benefit_end_date
          assert_equal 53, calc.total_number_of_mondays(start_date, end_date)
        end
      end

      context "for the full tax year 2016/2017" do
        should "calculate there are 52 Mondays" do
          calc = ChildBenefitTaxCalculator.new(
            year: "2016",
            children_count: "1",
            is_part_year_claim: "no",
          )
          start_date = calc.child_benefit_start_date
          end_date = calc.child_benefit_end_date
          assert_equal 52, calc.total_number_of_mondays(start_date, end_date)
        end
      end

      context "for the full tax year 2017/2018" do
        should "calculate there are 52 Mondays" do
          calc = ChildBenefitTaxCalculator.new(
            year: "2017",
            children_count: "1",
            is_part_year_claim: "no",
          )
          start_date = calc.child_benefit_start_date
          end_date = calc.child_benefit_end_date
          assert_equal 52, calc.total_number_of_mondays(start_date, end_date)
        end
      end

      context "for the full tax year 2018/2019" do
        should "calculate there are 52 Mondays" do
          calc = ChildBenefitTaxCalculator.new(
            year: "2018",
            children_count: "1",
            is_part_year_claim: "no",
          )
          start_date = calc.child_benefit_start_date
          end_date = calc.child_benefit_end_date
          assert_equal 52, calc.total_number_of_mondays(start_date, end_date)
        end
      end

      context "for the full tax year 2019/2020" do
        should "calculate there are 52 Mondays" do
          calc = ChildBenefitTaxCalculator.new(
            year: "2019",
            children_count: "1",
            is_part_year_claim: "no",
          )
          start_date = calc.child_benefit_start_date
          end_date = calc.child_benefit_end_date
          assert_equal 52, calc.total_number_of_mondays(start_date, end_date)
        end
      end

      context "for the full tax year 2020/2021" do
        should "calculate there are 53 Mondays" do
          calc = ChildBenefitTaxCalculator.new(
            year: "2020",
            children_count: "1",
            is_part_year_claim: "no",
          )
          start_date = calc.child_benefit_start_date
          end_date = calc.child_benefit_end_date
          assert_equal 53, calc.total_number_of_mondays(start_date, end_date)
        end
      end
    end

    context "calculating child benefits received" do
      context "for the tax year 2012" do
        should "give the total amount of benefits received for a full tax year 2012" do
          assert_equal 263.9, ChildBenefitTaxCalculator.new(
            year: "2012",
            children_count: "1",
            is_part_year_claim: "no",
          ).benefits_claimed_amount.round(2)
        end

        should "give the total amount of benefits received for a partial tax year" do
          assert_equal 263.9, ChildBenefitTaxCalculator.new(
            year: "2012",
            children_count: "1",
            is_part_year_claim: "yes",
            part_year_children_count: "1",
            starting_children: {
              "0" => {
                start: { year: "2012", month: "06", day: "01" },
                stop: { year: "2013", month: "06", day: "01" },
              },
            },
          ).benefits_claimed_amount.round(2)
        end

        should "should give the total amount of benefits received for a partial tax year with more than one child" do
          assert_equal 438.1, ChildBenefitTaxCalculator.new(
            year: "2012",
            children_count: "2",
            is_part_year_claim: "yes",
            part_year_children_count: "2",
            starting_children: {
              "0" => {
                start: { year: "2012", month: "06", day: "01" },
                stop: { year: "2013", month: "06", day: "01" },
              },
              "1" => {
                start: { year: "2012", month: "05", day: "01" },
                stop: { year: "2013", month: "07", day: "25" },
              },
            },
          ).benefits_claimed_amount.round(2)
        end
      end

      context "for the tax year 2013" do
        should "give the total amount of benefits received for a full tax year 2013" do
          assert_equal 1055.6, ChildBenefitTaxCalculator.new(
            year: "2013",
            children_count: "1",
            is_part_year_claim: "no",
          ).benefits_claimed_amount.round(2)
        end
      end

      context "for the tax year 2019" do
        should "give the total amount received for the full tax year for one child" do
          assert_equal 1076.4, ChildBenefitTaxCalculator.new(
            year: "2019",
            children_count: "1",
            is_part_year_claim: "no",
          ).benefits_claimed_amount.round(2)
        end

        should "give the total amount received for the full tax year for more than one child" do
          assert_equal 1788.8, ChildBenefitTaxCalculator.new(
            year: "2019",
            children_count: "2",
            is_part_year_claim: "no",
          ).benefits_claimed_amount.round(2)
        end

        should "give the total amount for a partial tax year for one child" do
          assert_equal 269.1, ChildBenefitTaxCalculator.new(
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
          ).benefits_claimed_amount.round(2)
        end

        should "give the total amount for a partial tax year for more than one child" do
          assert_equal 550.7, ChildBenefitTaxCalculator.new(
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
          ).benefits_claimed_amount.round(2)
        end

        should "give the total amount for three children, two of which are partial tax years" do
          assert_equal 1501.1, ChildBenefitTaxCalculator.new(
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
          ).benefits_claimed_amount.round(2)
        end
      end
    end

    context "calculating adjusted net income" do
      should "use the adjusted_net_income parameter when none of the calculation params are used" do
        assert_equal 50_099, ChildBenefitTaxCalculator.new(
          adjusted_net_income: "50099",
          other_income: "0",
          year: "2012",
          children_count: 2,
          is_part_year_claim: "no",
        ).adjusted_net_income
      end

      should "calculate the adjusted net income with the relevant params" do
        assert_equal 69_950, ChildBenefitTaxCalculator.new(
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
        ).adjusted_net_income
      end

      should "ignore the adjusted_net_income parameter when using the calculation form params" do
        assert_equal 69_950, ChildBenefitTaxCalculator.new(
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
        ).adjusted_net_income
      end
    end

    context "calculating percentage tax charge" do
      should "be 0.0 for an income of 50099" do
        assert_equal 0.0, ChildBenefitTaxCalculator.new(
          adjusted_net_income: "50099",
          year: "2012",
          children_count: 2,
          is_part_year_claim: "no",
        ).percent_tax_charge
      end

      should "be 1.0 for an income of 50199" do
        assert_equal 1.0, ChildBenefitTaxCalculator.new(
          adjusted_net_income: "50199",
          year: "2012",
          children_count: 2,
          is_part_year_claim: "no",
        ).percent_tax_charge
      end

      should "be 2.0 for an income of 50200" do
        assert_equal 2.0, ChildBenefitTaxCalculator.new(
          adjusted_net_income: "50200",
          year: "2012",
          children_count: 2,
          is_part_year_claim: "no",
        ).percent_tax_charge
      end

      should "be 40.0 for an income of 54013" do
        assert_equal 40.0, ChildBenefitTaxCalculator.new(
          adjusted_net_income: "54013",
          year: "2012",
          children_count: 2,
          is_part_year_claim: "no",
        ).percent_tax_charge
      end

      should "be 40.0 for an income of 54089" do
        assert_equal 40.0, ChildBenefitTaxCalculator.new(
          adjusted_net_income: "54089",
          year: "2012",
          children_count: 2,
          is_part_year_claim: "no",
        ).percent_tax_charge
      end

      should "be 99.0 for an income of 59999" do
        assert_equal 99.0, ChildBenefitTaxCalculator.new(
          adjusted_net_income: "59999",
          year: "2012",
          is_part_year_claim: "no",
          children_count: 2,
        ).percent_tax_charge
      end

      should "be 100.0 for an income of 60000" do
        assert_equal 100.0, ChildBenefitTaxCalculator.new(
          adjusted_net_income: "60000",
          year: "2012",
          children_count: 2,
          is_part_year_claim: "no",
        ).percent_tax_charge
      end

      should "be 100.0 for an income of 60001" do
        assert_equal 100.0, ChildBenefitTaxCalculator.new(
          adjusted_net_income: "60001",
          year: "2012",
          children_count: 2,
          is_part_year_claim: "no",
        ).percent_tax_charge
      end
    end

    context "calculating the correct amount owed" do
      context "below the income threshold" do
        should "be true for incomes under the threshold" do
          assert ChildBenefitTaxCalculator.new(
            adjusted_net_income: "49999",
            is_part_year_claim: "yes",
            children_count: 1,
            part_year_children_count: "1",
            starting_children: {
              "0" => { start: { year: "2018", month: "01", day: "01" } },
            },
            year: "2019",
          ).nothing_owed?
        end

        should "be true for incomes over the threshold" do
          assert_not ChildBenefitTaxCalculator.new(
            adjusted_net_income: "50100",
            is_part_year_claim: "yes",
            children_count: 1,
            part_year_children_count: "1",
            starting_children: {
              "0" => { start: { year: "2018", month: "01", day: "01" } },
            },
            year: "2019",
          ).nothing_owed?
        end
      end

      context "for the tax year 2012-13" do
        should "calculate the correct amount owed for % charge of 100" do
          assert_equal 263, ChildBenefitTaxCalculator.new(
            adjusted_net_income: "60001",
            children_count: "1",
            is_part_year_claim: "yes",
            part_year_children_count: "1",
            starting_children: {
              "0" => { start: { year: "2011", month: "01", day: "01" } },
            },
            year: "2012",
          ).tax_estimate.round(2)
        end

        should "calculate the corect amount for % charge of 99" do
          assert 261, ChildBenefitTaxCalculator.new(
            adjusted_net_income: "59900",
            children_count: 1,
            is_part_year_claim: "yes",
            part_year_children_count: "1",
            starting_children: {
              "0" => { start: { year: "2011", month: "01", day: "01" } },
            },
            year: "2012",
          ).tax_estimate.round(2)
        end

        should "calculate the correct amount for income < 59900" do
          assert_equal 105, ChildBenefitTaxCalculator.new(
            adjusted_net_income: "54000",
            children_count: 1,
            is_part_year_claim: "yes",
            part_year_children_count: "1",
            starting_children: {
              "0" => { start: { year: "2011", month: "01", day: "01" } },
            },
            year: "2012",
          ).tax_estimate.round(2)
        end
      end # tax year 2012-13

      context "for the tax year 2013-14" do
        should "calculate correctly for >60k earning" do
          calc = ChildBenefitTaxCalculator.new(
            adjusted_net_income: "60001",
            children_count: 1,
            is_part_year_claim: "yes",
            part_year_children_count: "1",
            starting_children: {
              "0" => { start: { year: "2013", month: "01", day: "01" } },
            },
            year: "2013",
          )
          assert_equal 1055, calc.tax_estimate.round(1)
        end

        should "calculate correctly for >55.9k earning" do
          calc = ChildBenefitTaxCalculator.new(
            adjusted_net_income: "59900",
            children_count: 1,
            is_part_year_claim: "yes",
            part_year_children_count: "1",
            starting_children: {
              "0" => { start: { year: "2013", month: "01", day: "01" } },
            },
            year: "2013",
          )
          assert_equal 1045, calc.tax_estimate.round(1)
        end

        should "calculate correctly for >50k earning" do
          calc = ChildBenefitTaxCalculator.new(
            adjusted_net_income: "54000",
            children_count: "1",
            is_part_year_claim: "yes",
            part_year_children_count: "1",
            starting_children: {
              "0" => {
                start: { year: "2011", month: "01", day: "01" },
                stop: { year: "", month: "", day: "" },
              },
            },
            year: "2013",
          )
          assert_equal 422, calc.tax_estimate.round(1)
        end
      end # tax year 2013-14
    end # no starting / stopping children

    context "starting and stopping children" do
      context "for the tax year 2012-2013" do
        should "calculate correctly with starting children" do
          calc = ChildBenefitTaxCalculator.new(
            adjusted_net_income: "61000",
            children_count: 1,
            is_part_year_claim: "yes",
            part_year_children_count: "1",
            starting_children: {
              "0" => {
                start: { year: "2013", month: "03", day: "01" },
                stop: { year: "", month: "", day: "" },
              },
            },
            year: "2012",
          )
          assert_equal 101, calc.tax_estimate.round(1)
        end

        should "not tax before Jan 7th 2013" do
          calc = ChildBenefitTaxCalculator.new(
            adjusted_net_income: "61000",
            children_count: 1,
            is_part_year_claim: "yes",
            part_year_children_count: "1",
            starting_children: {
              "0" => {
                start: { year: "2012", month: "05", day: "01" },
                stop: { year: "", month: "", day: "" },
              },
            },
            year: "2012",
          )
          assert_equal 263, calc.tax_estimate.round(1)
        end
      end

      context "for the tax year 2013-2014" do
        should "calculate correctly for 60k income" do
          calc = ChildBenefitTaxCalculator.new(
            adjusted_net_income: "61000",
            children_count: 1,
            is_part_year_claim: "yes",
            part_year_children_count: "1",
            starting_children: {
              "0" => {
                start: { year: "2014", month: "02", day: "22" },
                stop: { year: "", month: "", day: "" },
              },
            },
            year: "2013",
          )
          # starting child for 6 weeks
          assert_equal 121, calc.tax_estimate.round(1)
        end
      end # tax year 2013-14

      context "for the tax year 2016-2017" do
        should "calculate correctly with starting children" do
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
          # child from 01/03 to 01/04 => 5 weeks * 20.7
          assert_equal 103, calc.tax_estimate.round(1)
        end

        should "correctly calculate weeks for a child who started & stopped in tax year" do
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
          # child from 01/02 to 01/03 => 4 weeks * 20.7
          assert_equal 82, calc.tax_estimate.round(1)
        end
      end # tax year 2016
    end # starting & stopping children

    context "HMRC test scenarios" do
      should "calculate 3 children already in the household for 2012/2013" do
        calc = ChildBenefitTaxCalculator.new(
          year: "2012",
          children_count: 3,
          is_part_year_claim: "yes",
          part_year_children_count: "3",
          starting_children: {
            "0" => {
              start: { day: "06", month: "01", year: "2013" },
              stop: { day: "05", month: "04", year: "2013" },
            },
            "1" => {
              start: { day: "06", month: "01", year: "2013" },
              stop: { day: "05", month: "04", year: "2013" },
            },
            "2" => {
              start: { day: "06", month: "01", year: "2013" },
              stop: { day: "05", month: "04", year: "2013" },
            },
          },
        )
        assert_equal 612.30, calc.benefits_claimed_amount.round(2)
      end

      should "should calculate 3 children for 2012/2013 one child starting on 7 Jan 2013" do
        calc = ChildBenefitTaxCalculator.new(
          adjusted_net_income: "56000",
          year: "2012",
          children_count: 3,
          is_part_year_claim: "yes",
          part_year_children_count: "3",
          starting_children: {
            "0" => {
              start: { day: "06", month: "01", year: "2013" },
              stop: { day: "05", month: "04", year: "2013" },
            },
            "1" => {
              start: { day: "06", month: "01", year: "2013" },
              stop: { day: "05", month: "04", year: "2013" },
            },
            "2" => {
              start: { day: "07", month: "01", year: "2013" },
              stop: { day: "05", month: "04", year: "2013" },
            },
          },
        )
        assert_equal 612.30, calc.benefits_claimed_amount.round(2)
        assert_equal 367, calc.tax_estimate
      end

      should "calculate two weeks for one child observing the 'Monday' rules." do
        calc = ChildBenefitTaxCalculator.new(
          year: "2012",
          children_count: 1,
          is_part_year_claim: "yes",
          part_year_children_count: "1",
          starting_children: {
            "0" => {
              start: { day: "14", month: "01", year: "2013" },
              stop: { day: "21", month: "01", year: "2013" },
            },
          },
        )
        assert_equal 40.60, calc.benefits_claimed_amount.round(2)
      end

      should "should calculate 3 children already in the household for 2013/2014" do
        calc = ChildBenefitTaxCalculator.new(
          adjusted_net_income: "52000",
          year: "2013",
          children_count: 3,
          is_part_year_claim: "no",
        )
        assert_equal 2449.20, calc.benefits_claimed_amount.round(2)
        assert_equal 489, calc.tax_estimate.round(2)
      end

      should "calculate 3 children already in the household for 2013/2014 one stops on 14 June 2013" do
        calc = ChildBenefitTaxCalculator.new(
          adjusted_net_income: "53000",
          year: "2013",
          children_count: 3,
          is_part_year_claim: "yes",
          part_year_children_count: "1",
          starting_children: {
            "0" => {
              start: { day: "06", month: "04", year: "2013" },
              stop: { day: "14", month: "06", year: "2013" },
            },
          },
        )
        assert_equal 1886.40, calc.benefits_claimed_amount.round(2)
        assert_equal 565.0, calc.tax_estimate.round(2)
      end

      should "give an accurate figure for 40 weeks at £20.30" do
        calc = ChildBenefitTaxCalculator.new(
          adjusted_net_income: "61000",
          year: "2013",
          children_count: 1,
          is_part_year_claim: "yes",
          part_year_children_count: "1",
          starting_children: {
            "0" => {
              start: { day: "01", month: "07", year: "2013" },
              stop: { day: "", month: "", year: "" },
            },
          },
        )
        assert_equal 812.0, calc.benefits_claimed_amount
        assert_equal 812, calc.tax_estimate
      end

      context "tests for 2014 rates" do
        should "calculate 3 children already in the household for all of 2014/15" do
          calc = ChildBenefitTaxCalculator.new(
            year: "2014",
            children_count: 3,
            is_part_year_claim: "no",
          )
          assert_equal 2475.2, calc.benefits_claimed_amount.round(2)
        end

        should "give the total amount of benefits received for a full tax year 2014" do
          calc = ChildBenefitTaxCalculator.new(
            year: "2014",
            children_count: "1",
            is_part_year_claim: "no",
          )
          assert_equal 1066.0, calc.benefits_claimed_amount.round(2)
        end

        should "give total amount of benefits one child full year one child half a year" do
          calc = ChildBenefitTaxCalculator.new(
            year: "2014",
            children_count: 2,
            is_part_year_claim: "yes",
            part_year_children_count: "1",
            starting_children: {
              "0" => {
                start: { day: "06", month: "04", year: "2014" },
                stop: { day: "06", month: "11", year: "2014" },
              },
            },
          )
          assert_equal 1486.05, calc.benefits_claimed_amount.round(2)
        end

        should "give total amount of benefits for one child for half a year" do
          calc = ChildBenefitTaxCalculator.new(
            year: "2014",
            children_count: 1,
            is_part_year_claim: "yes",
            part_year_children_count: "1",
            starting_children: {
              "0" => {
                start: { day: "06", month: "04", year: "2014" },
                stop: { day: "06", month: "11", year: "2014" },
              },
            },
          )
          assert_equal 635.5, calc.benefits_claimed_amount.round(2)
        end
      end

      context "tests for 2015 rates" do
        should "calculate 3 children already in the household for all of 2015/16" do
          calc = ChildBenefitTaxCalculator.new(
            year: "2015",
            children_count: 3,
            is_part_year_claim: "no",
          )
          assert_equal 2549.3, calc.benefits_claimed_amount.round(2)
        end

        should "give the total amount of benefits received for a full tax year 2015" do
          calc = ChildBenefitTaxCalculator.new(
            year: "2015",
            children_count: "1",
            is_part_year_claim: "no",
          )
          assert_equal 1097.1, calc.benefits_claimed_amount.round(2)
        end

        should "give total amount of benefits one child full year one child half a year" do
          calc = ChildBenefitTaxCalculator.new(
            year: "2015",
            children_count: 2,
            is_part_year_claim: "yes",
            part_year_children_count: "1",
            starting_children: {
              "0" => {
                start: { day: "06", month: "04", year: "2015" },
                stop: { day: "06", month: "11", year: "2016" },
              },
            },
          )
          assert_equal 1823.2, calc.benefits_claimed_amount.round(2)
        end

        should "give total amount of benefits for one child for half a year" do
          calc = ChildBenefitTaxCalculator.new(
            year: "2015",
            children_count: 1,
            is_part_year_claim: "yes",
            part_year_children_count: "1",
            starting_children: {
              "0" => {
                start: { day: "06", month: "04", year: "2015" },
                stop: { day: "06", month: "11", year: "2015" },
              },
            },
          )
          assert_equal 641.7, calc.benefits_claimed_amount.round(2)
        end
      end

      context "tests for 2016 rates" do
        should "calculate 3 children already in the household for all of 2016/17" do
          calc = ChildBenefitTaxCalculator.new(
            year: "2016",
            children_count: 3,
            is_part_year_claim: "no",
          )
          assert_equal 2501.2, calc.benefits_claimed_amount.round(2)
        end

        should "give the total amount of benefits received for a full tax year 2016" do
          calc = ChildBenefitTaxCalculator.new(
            year: "2016",
            children_count: "1",
            is_part_year_claim: "no",
          )
          assert_equal 1076.4, calc.benefits_claimed_amount.round(2)
        end

        should "give total amount of benefits one child full year one child half a year" do
          calc = ChildBenefitTaxCalculator.new(
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
          )
          assert_equal 1432.6, calc.benefits_claimed_amount.round(2)
        end

        should "give total amount of benefits for one child for half a year" do
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
          assert_equal 621.0, calc.benefits_claimed_amount.round(2)
        end

        should "set the start date to start of the selected tax year" do
          calc = ChildBenefitTaxCalculator.new(
            year: "2016",
            children_count: 1,
            is_part_year_claim: "no",
          )

          assert_equal Date.parse("06 April 2016"), calc.child_benefit_start_date
          assert_equal Date.parse("05 April 2017"), calc.child_benefit_end_date
        end

        should "set the stop date to end of the selected tax year" do
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
          assert_equal Date.parse("05 April 2017"), calc.child_benefit_end_date
        end

        should "correctly calculate the benefit amount for multiple full year and part year children" do
          calc = ChildBenefitTaxCalculator.new(
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
          )
          assert_equal 2145, calc.benefits_claimed_amount.round(2)
        end
      end
    end
  end
end
