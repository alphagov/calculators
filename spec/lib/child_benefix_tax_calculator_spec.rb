require 'spec_helper'

describe ChildBenefitTaxCalculator do
  it "calculates the proper owed value" do
    calc = ChildBenefitTaxCalculator.new({
      :total_annual_income => 20,
      :children_count => 1
    })
    calc.owed.should == 2
  end

  it "calculates the total amount from other values" do
    calc = ChildBenefitTaxCalculator.new({
      :gross_pension_contributions => 10,
      :net_pension_contributions => 10,
      :trading_losses_self_employed => 10,
      :children_count => 1
    })
    calc.total_annual_income.should == 30
    calc.owed.should == 3
  end

  it "uses the total annual income if both are supplied" do
    calc = ChildBenefitTaxCalculator.new({
      :total_annual_income => 20,
      :gross_pension_contributions => 10,
      :net_pension_contributions => 10,
      :trading_losses_self_employed => 10,
      :children_count => 1
    })
    calc.total_annual_income.should == 20
  end
end
