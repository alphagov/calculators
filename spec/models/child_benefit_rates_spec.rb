# encoding: UTF-8
require 'spec_helper'

describe ChildBenefitRates do

  describe "test initialization of instance variable" do

    it "should intialize instance correctly" do
      ChildBenefitRates.new(2014).year.should == 2014
    end

    it "should raise error" do
      expect {ChildBenefitRates.new(2000)}.to raise_error("Invalid tax year")
    end

  end

  describe "return correct rates for 2012 year passed in" do
    before(:each) do
      @calc = ChildBenefitRates.new(2012)
    end

    it "should return correct rates" do
      @calc.first_child_rate.should == 20.3
      @calc.additional_child_rate.should == 13.4
    end

  end

  describe "return correct rates for 2013 year passed in" do
    before(:each) do
      @calc = ChildBenefitRates.new(2013)
    end

    it "should return correct rates" do
      @calc.first_child_rate.should == 20.3
      @calc.additional_child_rate.should == 13.4
    end

  end

  describe "return correct rates for 2014 year passed in" do
    before(:each) do
      @calc = ChildBenefitRates.new(2014)
    end

    it "should return correct rates" do
      @calc.first_child_rate.should == 20.5
      @calc.additional_child_rate.should == 13.55
    end

  end

end
