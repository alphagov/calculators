require 'spec_helper'

describe StartingChild, :type => :model do
  it "should expect a start date to be present" do
    child = StartingChild.new
    expect(child).not_to be_valid
    expect(child.errors[:start_date]).to include "enter the date Child Benefit started"
  end

  it "should reject dates with days exceeding maximum for a month" do
    child = StartingChild.new(
              stop: {year: "2013", month: "02", day: "29"})
    expect(child).not_to be_valid
    error_msg = "enter a valid date - there are only 28 days in February"
    expect(child.errors[:end_date]).to include error_msg
  end

  it "should allow for leap years when checking for too many days" do
    child = StartingChild.new(start: {year: "2012", month: "02", day: "29"})
    expect(child.errors[:start_date]).to be_empty
  end

  context "when the start date has too many days for its month" do
    before :each do
      @child = StartingChild.new(
        start: {year: "2013", month: "02", day: "29"})
      @child.valid?
    end

    it "should reject it" do
      error_msg = "enter a valid date - there are only 28 days in February"
      expect(@child.errors[:start_date]).to include error_msg
    end

    it "should suppress validating its presence " do
      error_msg = "enter the date Child Benefit started"
      expect(@child.errors[:start_date]).not_to include error_msg
    end
  end

  it "should produce a valid StartingChild object" do
    child = StartingChild.new(
      start: {year: "2012", month: "02", day: "01"},
      stop: {year: "2012", month: "03", day: "01"},
    )
    expect(child).to be_valid
  end

  describe "adjusted_start_date" do
    it "should return the next Monday if start date is 7th January 2013" do
      child = StartingChild.new(start: {year: "2013", month: "01", day: "07"})
      expect(child.adjusted_start_date).to eq(Date.parse("14 January 2013"))
    end

    it "should return the next Monday for the provided start date" do
      child = StartingChild.new(start: {year: "2012", month: "01", day: "01"})
      expect(child.adjusted_start_date).to eq(Date.parse("2 January 2012"))

      child = StartingChild.new(start: {year: "2013", month: "05", day: "08"})
      expect(child.adjusted_start_date).to eq(Date.parse("13 May 2013"))

      child = StartingChild.new(start: {year: "2013", month: "08", day: "13"})
      expect(child.adjusted_start_date).to eq(Date.parse("19 August 2013"))

      child = StartingChild.new(start: {year: "2013", month: "01", day: "06"})
      expect(child.adjusted_start_date).to eq(Date.parse("7 January 2013"))

      child = StartingChild.new(start: {year: "2013", month: "01", day: "14"})
      expect(child.adjusted_start_date).to eq(Date.parse("21 January 2013"))
    end

    it "should not blow up with a nil start date" do
      expect(StartingChild.new(start: {}).adjusted_start_date).to be_nil
    end
  end
end
