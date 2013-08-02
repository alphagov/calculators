# encoding: UTF-8
require 'spec_helper'

describe ChildBenefitTaxHelper do
  
  describe "money_input" do
    it "should create an html text input with sensible defaults" do
      money_input('foo', 0).should == '<input id="foo" name="foo" placeholder="£" type="text" />'
      money_input('foo', 200).should == '<input id="foo" name="foo" placeholder="£" type="text" value="£200.00" />'
    end
  end

  describe "tax_year_label" do
    it "should format the years range" do
      tax_year_label(2013).should == "2013 to 2014"
    end
  end

  describe "tax_year_incomplete?" do
    before :each do
      @calculator = stub(:tax_year => 2013)
    end

    it "should be true before the end of the tax year" do
      Timecop.freeze('2014-04-04') do
        tax_year_incomplete?.should be_true
      end
    end

    it "should be false after the end of the tax year" do
      Timecop.freeze('2014-04-06') do
        tax_year_incomplete?.should be_false
      end
    end
  end
end
