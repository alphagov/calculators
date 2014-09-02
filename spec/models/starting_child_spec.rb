require 'spec_helper'

describe StartingChild do
  it "should expect a start date to be present" do
    child = StartingChild.new
    child.should_not be_valid
    child.errors[:start_date].should include "enter the date Child Benefit started"
  end

  it "should reject dates with days exceeding maximum for a month" do
    child = StartingChild.new(
              stop: {year: "2013", month: "02", day: "29"})
    child.should_not be_valid
    error_msg = "enter a valid date - there are only 28 days in February"
    child.errors[:end_date].should include error_msg
  end

  it "should allow for leap years when checking for too many days" do
    child = StartingChild.new(start: {year: "2012", month: "02", day: "29"})
    child.errors[:start_date].should be_empty
  end

  context "when the start date has too many days for its month" do
    before :each do
      @child = StartingChild.new(
        start: {year: "2013", month: "02", day: "29"})
      @child.valid?
    end

    it "should reject it" do
      error_msg = "enter a valid date - there are only 28 days in February"
      @child.errors[:start_date].should include error_msg
    end

    it "should suppress validating its presence " do
      error_msg = "enter the date Child Benefit started"
      @child.errors[:start_date].should_not include error_msg
    end
  end

  it "should produce a valid StartingChild object" do
    child = StartingChild.new(
      start: {year: "2012", month: "02", day: "01"},
      stop: {year: "2012", month: "03", day: "01"},
    )
    child.should be_valid
  end

  describe "adjusted_start_date" do
    it "should return the next Monday if start date is 7th January 2013" do
      child = StartingChild.new(start: {year: "2013", month: "01", day: "07"})
      child.adjusted_start_date.should == Date.parse("14 January 2013")
    end

    it "should return the next Monday for the provided start date" do
      child = StartingChild.new(start: {year: "2012", month: "01", day: "01"})
      child.adjusted_start_date.should ==  Date.parse("2 January 2012")

      child = StartingChild.new(start: {year: "2013", month: "05", day: "08"})
      child.adjusted_start_date.should == Date.parse("13 May 2013")

      child = StartingChild.new(start: {year: "2013", month: "08", day: "13"})
      child.adjusted_start_date.should == Date.parse("19 August 2013")

      child = StartingChild.new(start: {year: "2013", month: "01", day: "06"})
      child.adjusted_start_date.should == Date.parse("7 January 2013")

      child = StartingChild.new(start: {year: "2013", month: "01", day: "14"})
      child.adjusted_start_date.should == Date.parse("21 January 2013")
    end

    it "should not blow up with a nil start date" do
      StartingChild.new(start: {}).adjusted_start_date.should be_nil
    end
  end
end
