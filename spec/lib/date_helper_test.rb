require "spec_helper"

describe DateHelper do
  describe "day" do
    it "returns today's date if no date is supplied" do
      Timecop.freeze("2017-01-01") do
        expect(DateHelper.day.to_s).to eq("2017-01-01")
      end
    end

    it "returns a parsed date if a valid date is supplied" do
      expect(DateHelper.day("2017-02-01")).to eq(Date.parse("2017-02-01"))
    end

    it "raises an ArgumentError if a invalid date is supplied" do
      expect(lambda { DateHelper.day("702-01") }).to raise_error(ArgumentError, "invalid date")
    end
  end

  describe "years_ago" do
    it "returns a date 10 years earlier" do
      Timecop.freeze("2017-01-01") do
        expect(DateHelper.years_ago.to_s).to eq("2007-01-01")
      end
    end

    it "returns an earlier date based on the period supplied" do
      Timecop.freeze("2017-01-01") do
        expect(DateHelper.years_ago(20).to_s).to eq("1997-01-01")
      end
    end

    it "returns an earlier date based on the period and date supplied" do
      expect(DateHelper.years_ago(5, "1990-01-01").to_s).to eq("1985-01-01")
    end
  end

  describe "years_since" do
    it "returns a date 10 years from today" do
      Timecop.freeze("2017-01-01") do
        expect(DateHelper.years_since.to_s).to eq("2027-01-01")
      end
    end

    it "returns an future date based on the period supplied" do
      Timecop.freeze("2017-01-01") do
        expect(DateHelper.years_since(20).to_s).to eq("2037-01-01")
      end
    end

    it "returns an future date based on the period and date supplied" do
      expect(DateHelper.years_since(5, "1990-01-01").to_s).to eq("1995-01-01")
    end
  end
end
