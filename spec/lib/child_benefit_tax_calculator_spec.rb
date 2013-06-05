require 'spec_helper'

describe ChildBenefitTaxCalculator do
  it "uses the adjusted net income if it's passed in" do
    calc = ChildBenefitTaxCalculator.new({
      :adjusted_net_income=> 20
    })
    calc.adjusted_net_income.should == 20
  end

  it "calculates net income from other values" do
    calc = ChildBenefitTaxCalculator.new({
      :gross_pension_contributions => 10,
      :net_pension_contributions => 10,
      :trading_losses_self_employed => 10,
      :gift_aid_donations => 10,
      :total_annual_income => 100,
    })
    calc.adjusted_net_income.should == 55.0
  end

  it "uses the total annual income if both are supplied" do
    calc = ChildBenefitTaxCalculator.new({
      :gross_pension_contributions => 10,
      :net_pension_contributions => 10,
      :trading_losses_self_employed => 10,
      :gift_aid_donations => 10,
      :total_annual_income => 100,
      :adjusted_net_income => 20
    })
    calc.adjusted_net_income.should == 20
  end

  describe "calculating the correct amount owed" do

    it "calculates the correct amount owed for % charge of 100" do
      calc = ChildBenefitTaxCalculator.new({
        :adjusted_net_income => "60001",
        :children_count => "1"
      })
      calc.amount_owed.round(2).should == 312.31
    end

    it "calculates the corect amount for % charge of 99" do
      calc = ChildBenefitTaxCalculator.new({
        :adjusted_net_income => "59900",
        :children_count => "1"
      })
      calc.amount_owed.round(2).should == 309.18
    end

    it "calculates the correct amount for income < 59900" do
      calc = ChildBenefitTaxCalculator.new({
        :adjusted_net_income => "54000",
        :children_count => "1"
      })
      calc.amount_owed.round(2).should == 124.92
    end
  end
end
