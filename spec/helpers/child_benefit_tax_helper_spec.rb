# encoding: UTF-8
require 'spec_helper'

describe ChildBenefitTaxHelper do

  describe "money_input" do
    it "should create an html text input with sensible defaults" do
      money_input("foo", 0).should == '<input type="text" name="foo" id="foo" placeholder="£" />'
      money_input("foo", 200).should == '<input type="text" name="foo" id="foo" value="£200.00" placeholder="£" />'
    end

    it "combines the field tag options with the placeholder value" do
      money_input("foo", 0, foo: "bar").should == '<input type="text" name="foo" id="foo" placeholder="£" foo="bar" />'
      money_input("foo", 0, placeholder: "Enter something").should == '<input type="text" name="foo" id="foo" placeholder="Enter something" />'
    end
  end

  describe "tax_year_label" do
    it "should format the years range" do
      tax_year_label(2013).should == "2013 to 2014"
    end
  end

  describe "tax_year_incomplete?" do
    before :each do
      @calculator = double(tax_year: 2013)
    end

    it "should be true before the end of the tax year" do
      Timecop.freeze('2014-04-04') do
        tax_year_incomplete?.should eq true
      end
    end

    it "should be false after the end of the tax year" do
      Timecop.freeze('2014-04-06') do
        tax_year_incomplete?.should eq false
      end
    end
  end
end
