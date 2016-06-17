require 'spec_helper'

describe StartingChild, type: :model do
  it "should expect a start date to be present" do
    child = StartingChild.new
    expect(child).not_to be_valid
    expect(child.errors[:start_date]).to include "enter the date Child Benefit started"
  end

  it "should reject dates with days exceeding maximum for a month" do
    child = StartingChild.new(
      stop: { year: "2013", month: "02", day: "29" })
    expect(child).not_to be_valid
    error_msg = "enter a valid date - there are only 28 days in February"
    expect(child.errors[:end_date]).to include error_msg
  end

  it "should allow for leap years when checking for too many days" do
    child = StartingChild.new(start: { year: "2012", month: "02", day: "29" })
    expect(child.errors[:start_date]).to be_empty
  end

  context "when the start date has too many days for its month" do
    before :each do
      @child = StartingChild.new(
        start: { year: "2013", month: "02", day: "29" })
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
      start: { year: "2012", month: "02", day: "01" },
      stop: { year: "2012", month: "03", day: "01" },
    )
    expect(child).to be_valid
  end
end
