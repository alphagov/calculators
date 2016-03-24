# encoding: UTF-8
require 'spec_helper'

describe ChildBenefitTaxHelper, type: :helper do
  describe "money_input" do
    it "should create an html text input with sensible defaults" do
      expect(money_input("foo", 0)).to eq('<input type="text" name="foo" id="foo" placeholder="£" />')
      expect(money_input("foo", 200)).to eq('<input type="text" name="foo" id="foo" value="£200.00" placeholder="£" />')
    end

    it "combines the field tag options with the placeholder value" do
      expect(money_input("foo", 0, foo: "bar")).to eq('<input type="text" name="foo" id="foo" placeholder="£" foo="bar" />')
      expect(money_input("foo", 0, placeholder: "Enter something")).to eq('<input type="text" name="foo" id="foo" placeholder="Enter something" />')
    end
  end

  describe "tax_year_label" do
    it "should format the years range" do
      expect(tax_year_label(2013)).to eq("2013 to 2014")
    end
  end

  describe "tax_year_incomplete?" do
    before :each do
      @calculator = double(tax_year: 2013)
    end

    it "should be true before the end of the tax year" do
      Timecop.freeze('2014-04-04') do
        expect(tax_year_incomplete?).to eq true
      end
    end

    it "should be false after the end of the tax year" do
      Timecop.freeze('2014-04-06') do
        expect(tax_year_incomplete?).to eq false
      end
    end
  end
end
