# encoding: utf-8

require "spec_helper"

describe ChildBenefitRates, type: :model do
  let(:year) { 2014 }
  let(:first_child_rate) { 42.42 }
  let(:additional_child_rate) { 13.17 }
  let(:calculator) { ChildBenefitRates.new(year) }
  let(:rates) { { year => [first_child_rate, additional_child_rate] } }

  before do
    allow(calculator).to receive(:rates_for_year).and_return(rates[year])
  end

  describe "#year" do
    it "returns the year passed during initialization" do
      expect(calculator.year).to eq(year)
    end
  end

  describe "#first_child_rate" do
    it "returns correct rates" do
      expect(calculator.first_child_rate).to eq(first_child_rate)
    end
  end

  describe "#additional_child_rate" do
    it "returns correct rates" do
      expect(calculator.additional_child_rate).to eq(additional_child_rate)
    end
  end
end
