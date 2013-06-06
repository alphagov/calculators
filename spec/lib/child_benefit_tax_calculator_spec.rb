require 'spec_helper'

describe ChildBenefitTaxCalculator do
  it "uses the adjusted net income if it's passed in" do
    calc = ChildBenefitTaxCalculator.new({
      :adjusted_net_income=> 20
    })
    calc.adjusted_net_income.should == 20
  end

  it "calculates net income from other values" do
    calc = ChildBenefitTaxCalculator.new({
      :gross_pension_contributions => 10,
      :net_pension_contributions => 10,
      :trading_losses_self_employed => 10,
      :gift_aid_donations => 10,
      :total_annual_income => 100,
    })
    calc.adjusted_net_income.should == 55.0
  end

  it "uses the total annual income if both are supplied" do
    calc = ChildBenefitTaxCalculator.new({
      :gross_pension_contributions => 10,
      :net_pension_contributions => 10,
      :trading_losses_self_employed => 10,
      :gift_aid_donations => 10,
      :total_annual_income => 100,
      :adjusted_net_income => 20
    })
    calc.adjusted_net_income.should == 20
  end

  describe "calculating the correct amount owed" do

    describe "for the tax year 2012-13" do
      it "calculates the correct amount owed for % charge of 100" do
        calc = ChildBenefitTaxCalculator.new({
          :adjusted_net_income => "60001",
          :children_count => "1",
          :year => "2012"
        })
        calc.owed[:benefit_claimed_amount].round(1).should == 1055.6
        calc.owed[:benefit_owed_amount].round(2).should == 243.6
      end

      it "calculates the corect amount for % charge of 99" do
        calc = ChildBenefitTaxCalculator.new({
          :adjusted_net_income => "59900",
          :children_count => "1",
          :year => "2012"
        })
        calc.owed[:benefit_owed_amount].round(2).should == 241.16
      end

      it "calculates the correct amount for income < 59900" do
        calc = ChildBenefitTaxCalculator.new({
          :adjusted_net_income => "54000",
          :children_count => "1",
          :year => "2012"
        })
        calc.owed[:benefit_owed_amount].round(2).should == 97.44
      end
    end # tax year 2012-13

    describe "for the tax year 2013-14" do
      it "calculates correctly for >60k earning" do
        calc = ChildBenefitTaxCalculator.new({
          :adjusted_net_income => "60001",
          :children_count => "1",
          :year => "2013"
        })
        calc.owed[:benefit_owed_amount].round(1).should == 1055.6
      end
      it "calculates correctly for >55.9k earning" do
        calc = ChildBenefitTaxCalculator.new({
          :adjusted_net_income => "59900",
          :children_count => "1",
          :year => "2013"
        })
        calc.owed[:benefit_owed_amount].round(1).should == 1045.0
      end
      it "calculates correctly for >50k earning" do
        calc = ChildBenefitTaxCalculator.new({
          :adjusted_net_income => "54000",
          :children_count => "1",
          :year => "2013"
        })
        calc.owed[:benefit_owed_amount].round(1).should == 422.2
      end
    end # tax year 2013-14
  end # no starting / stopping children

  describe "starting and stopping children" do
    describe "tax year 2012" do
      it "calculates correctly with starting children" do
        calc = ChildBenefitTaxCalculator.new({
          :adjusted_net_income => "61000",
          :starting_children => [{ :year => "2013", :month => "03", :day => "01" }],
          :year => "2012"
        })
        calc.owed[:benefit_owed_amount].round(1).should == 121.8
      end
    end # tax year 2012

    describe "tax year 2013" do
      it "calculates correctly for 60k income" do
        calc = ChildBenefitTaxCalculator.new({
          :adjusted_net_income => "61000",
          :starting_children => [{ :year => "2014", :month => "03", :day => "01" }],
          :year => "2013"
        })
        calc.owed[:benefit_owed_amount].round(1).should == 121.8
      end
    end # tax year 2013-14
  end # starting & stopping children
end
