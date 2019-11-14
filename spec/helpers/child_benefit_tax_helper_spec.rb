# encoding: utf-8

require "spec_helper"

describe ChildBenefitTaxHelper, type: :helper do
  describe "money_input_value" do
    it "should convert a number into a monetary value" do
      expect(money_input_value(1001)).to eq("£1,001.00")
    end

    it "should return nothing if the number is zero" do
      expect(money_input_value(0)).to eq(nil)
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
      Timecop.freeze("2014-04-04") do
        expect(tax_year_incomplete?).to eq true
      end
    end

    it "should be false after the end of the tax year" do
      Timecop.freeze("2014-04-06") do
        expect(tax_year_incomplete?).to eq false
      end
    end
  end
end
