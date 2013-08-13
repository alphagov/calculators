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
end
