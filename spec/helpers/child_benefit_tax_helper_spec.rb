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
      tax_year_label([Date.parse("1 Jan 2014"),
                      Date.parse("1 Jan 2015")]).should == "2014 to 2015"
    end
  end

end
