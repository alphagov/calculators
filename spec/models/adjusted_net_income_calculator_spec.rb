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
      AdjustedNetIncomeCalculator.new(
        :gross_income => "£60,000", :other_income => "£5,000", :pensions => "£1000",
        :property => "£2,000", :non_employment_income => "£2000",
        :pension_contributions_from_pay => "£1000", :retirement_annuities => "£1000",
        :cycle_scheme => "£1,000", :childcare => "£2,000"
      ).calculate_adjusted_net_income.should == 64750
    end
  end

end 
