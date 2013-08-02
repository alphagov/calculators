# encoding: UTF-8
require 'spec_helper'

describe AdjustedNetIncomeCalculator do

  describe "adjusted_net_income" do
    it "should calculate with minimal parameters" do
      AdjustedNetIncomeCalculator.new(:gross_income => "£60,000").calculate_adjusted_net_income.should == 60000
    end
    it "should ignore other params" do
      AdjustedNetIncomeCalculator.new(:foo => "bar").calculate_adjusted_net_income.should == 0
    end
    it "should calculate parsed parameters" do
      calc = AdjustedNetIncomeCalculator.new(
        :gross_income => "£60,000", :other_income => "£5,000", :pensions => "£1000",
        :property => "£2,000", :non_employment_income => "£2000",
        :pension_contributions_from_pay => "£1000", :gift_aid_donations => "£500", :retirement_annuities => "£1000",
        :cycle_scheme => "£1,000", :childcare => "£2,000", :outgoing_pension_contributions => "£2 000"
      )
      calc.gross_income.should == 60000
      calc.other_income.should == 5000
      calc.pensions.should == 1000
      calc.property.should == 2000
      calc.non_employment_income.should == 2000

      calc.pension_contributions_from_pay.should == 1000
      calc.gift_aid_donations.should == 500
      calc.retirement_annuities.should == 1000
      calc.cycle_scheme.should == 1000
      calc.childcare.should == 2000
      calc.outgoing_pension_contributions.should == 2000

      calc.calculate_adjusted_net_income.should == 61875
    end
  end

end 
