require_relative "../../test_helper"

class StartingChildTest < ActiveSupport::TestCase
  context StartingChild do
    should "expect a start date to be present" do
      child = StartingChild.new
      assert_not child.valid?
      assert child.errors[:start_date].include? "enter the date Child Benefit started"
    end

    should "reject dates with days exceeding maximum for a month" do
      child = StartingChild.new(
        stop: { year: "2013", month: "02", day: "29" },
      )
      assert_not child.valid?
      error_msg = "enter a valid date - there are only 28 days in February"
      assert child.errors[:end_date].include? error_msg
    end

    should "allow for leap years when checking for too many days" do
      child = StartingChild.new(start: { year: "2012", month: "02", day: "29" })
      assert_empty child.errors[:start_date]
    end

    context "when the start date has too many days for its month" do
      setup do
        @child = StartingChild.new(
          start: { year: "2013", month: "02", day: "29" },
        )
        @child.valid?
      end

      should "reject it" do
        error_msg = "enter a valid date - there are only 28 days in February"
        assert @child.errors[:start_date].include? error_msg
      end

      should "suppress validating its presence" do
        error_msg = "enter the date Child Benefit started"
        assert_not @child.errors[:start_date].include? error_msg
      end
    end

    should "produce a valid StartingChild object" do
      child = StartingChild.new(
        start: { year: "2012", month: "02", day: "01" },
        stop: { year: "2012", month: "03", day: "01" },
      )
      assert child.valid?
    end
  end
end
