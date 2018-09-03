# encoding: UTF-8

require 'spec_helper'

describe AdjustedNetIncomeCalculator, type: :model do
  describe "adjusted_net_income" do
    it "should calculate with minimal parameters" do
      expect(AdjustedNetIncomeCalculator.new(gross_income: "£60,000").calculate_adjusted_net_income).to eq(60000)
    end
    it "should ignore other params" do
      expect(AdjustedNetIncomeCalculator.new(foo: "bar").calculate_adjusted_net_income).to eq(0)
    end
    it "should calculate parsed parameters" do
      calc = AdjustedNetIncomeCalculator.new(
        gross_income: "£60,000", other_income: "£5,000", pensions: "£1000",
        property: "£2,000", non_employment_income: "£2000",
        pension_contributions_from_pay: "£1000", gift_aid_donations: "£500", retirement_annuities: "£1000",
        cycle_scheme: "£1,000", childcare: "£2,000", outgoing_pension_contributions: "£2 000",
      )
      expect(calc.gross_income).to eq(60000)
      expect(calc.other_income).to eq(5000)
      expect(calc.pensions).to eq(1000)
      expect(calc.property).to eq(2000)
      expect(calc.non_employment_income).to eq(2000)

      expect(calc.pension_contributions_from_pay).to eq(1000)
      expect(calc.gift_aid_donations).to eq(500)
      expect(calc.retirement_annuities).to eq(1000)
      expect(calc.cycle_scheme).to eq(1000)
      expect(calc.childcare).to eq(2000)
      expect(calc.outgoing_pension_contributions).to eq(2000)

      expect(calc.calculate_adjusted_net_income).to eq(65625)
    end
  end
end
