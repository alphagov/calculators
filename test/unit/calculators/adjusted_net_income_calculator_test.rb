require_relative "../../test_helper"

class AdjustedNetIncomeCalculatorTest < ActiveSupport::TestCase
  context AdjustedNetIncomeCalculator do
    should "calculate with minimal parameters" do
      assert_equal 60_000, AdjustedNetIncomeCalculator.new(gross_income: "£60,000").calculate_adjusted_net_income
    end
    should "ignore other params" do
      assert_equal 0, AdjustedNetIncomeCalculator.new(foo: "bar").calculate_adjusted_net_income
    end
    should "calculate parsed parameters" do
      calc = AdjustedNetIncomeCalculator.new(
        gross_income: "£60,000",
        other_income: "£5,000",
        pensions: "£1000",
        property: "£2,000",
        non_employment_income: "£2000",
        pension_contributions_from_pay: "£1000",
        gift_aid_donations: "£500",
        retirement_annuities: "£1000",
        cycle_scheme: "£1,000",
        childcare: "£2,000",
        outgoing_pension_contributions: "£2 000",
      )

      assert_equal 60_000, calc.gross_income
      assert_equal 5000, calc.other_income
      assert_equal 1000, calc.pensions
      assert_equal 2000, calc.property
      assert_equal 2000, calc.non_employment_income

      assert_equal 1000, calc.pension_contributions_from_pay
      assert_equal 500, calc.gift_aid_donations
      assert_equal 1000, calc.retirement_annuities
      assert_equal 1000, calc.cycle_scheme
      assert_equal 2000, calc.childcare
      assert_equal 2000, calc.outgoing_pension_contributions

      assert_equal 65_625, calc.calculate_adjusted_net_income      
    end
  end
end
