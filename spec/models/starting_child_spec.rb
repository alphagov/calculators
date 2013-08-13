require 'spec_helper'

describe StartingChild do
  it "should expect a start date to be present" do
    child = StartingChild.new

    assert child.invalid?
    assert_equal ({:start_date => ["Enter the date Child Benefit started"]}), child.errors.messages
  end

  it "should produce a valid StartingChild object" do
    child = StartingChild.new(:start => {:year => "2012", :month => "02", :day => "01"},
                              :stop  => {:year => "2012", :month => "03", :day => "01"})
    assert child.valid?
  end

  describe "adjusted_start_date" do
    it "should return the same start date if on or before 7th January 2013" do
      assert_equal Date.parse("1 January 2012"),
                   StartingChild.new(:start => {:year => "2012", :month => "01", :day => "01"}).adjusted_start_date

      assert_equal Date.parse("7 January 2013"),
                   StartingChild.new(:start => {:year => "2013", :month => "01", :day => "07"}).adjusted_start_date
    end
  end
end
