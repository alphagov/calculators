require 'spec_helper'

describe ChildBenefitTaxCalculator do
  it "uses the adjusted net income if it's passed in" do
    calc = ChildBenefitTaxCalculator.new({
      :adjusted_net_income=> 20
    })
    calc.adjusted_net_income.should == 20
  end

  it "isnt valid if enough detail is not supplied" do
    # nothing given
    ChildBenefitTaxCalculator.new.can_calculate?.should == false
    # no tax_year
    ChildBenefitTaxCalculator.new({
      :adjusted_net_income => "500000"
    }).can_calculate?.should == false
    # no children
    ChildBenefitTaxCalculator.new({
      :adjusted_net_income => "500000",
      :year => "2012"
    }).can_calculate?.should == false
  end

  it "is valid if given enough detail" do
    ChildBenefitTaxCalculator.new({
      :adjusted_net_income => "500000",
      :year => "2012",
      :children_count => 2
    }).can_calculate?.should == true
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

  describe "calculating percentage tax charge" do
    it "should be 0.0 for an income of 50099" do
      ChildBenefitTaxCalculator.new({
        :adjusted_net_income => "50099",
        :year => "2012",
        :children_count => 2
      }).percent_tax_charge.should == 0.0
    end
    it "should be 1.0 for an income of 50199" do
      ChildBenefitTaxCalculator.new({
        :adjusted_net_income => "50199",
        :year => "2012",
        :children_count => 2
      }).percent_tax_charge.should == 1.0
    end
    it "should be 2.0 for an income of 50200" do
      ChildBenefitTaxCalculator.new({
        :adjusted_net_income => "50200",
        :year => "2012",
        :children_count => 2
      }).percent_tax_charge.should == 2.0
    end
    it "should be 40.0 for an income of 54013" do
      ChildBenefitTaxCalculator.new({
        :adjusted_net_income => "54013",
        :year => "2012",
        :children_count => 2
      }).percent_tax_charge.should == 40.0
    end
    it "should be 40.0 for an income of 54089" do
      ChildBenefitTaxCalculator.new({
        :adjusted_net_income => "54089",
        :year => "2012",
        :children_count => 2
      }).percent_tax_charge.should == 40.0
    end
    it "should be 99.0 for an income of 60000" do
      ChildBenefitTaxCalculator.new({
        :adjusted_net_income => "60000",
        :year => "2012",
        :children_count => 2
      }).percent_tax_charge.should == 99.0
    end
    it "should be 100.0 for an income of 60000" do
      ChildBenefitTaxCalculator.new({
        :adjusted_net_income => "60001",
        :year => "2012",
        :children_count => 2
      }).percent_tax_charge.should == 100.0
    end
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
          :starting_children => {
            "1" => {
              :start => { :year => "2013", :month => "03", :day => "01" },
              :stop => { :year => "", :month => "", :day => ""},
              :no_stop => true
            }
          },
          :year => "2012"
        })
        calc.owed[:benefit_owed_amount].round(1).should == 121.8
      end

      it "doesn't tax before Jan 7th 2013" do
        calc = ChildBenefitTaxCalculator.new({
          :adjusted_net_income => "61000",
          :starting_children => {
            "1" => {
              :start => { :year => "2012", :month => "05", :day => "01" },
              :stop => { :year => "", :month => "", :day => ""},
              :no_stop => true
            }
          },
          :year => "2012"
        })
        # child from 01/05/12 -> 05/04/13
        # 11 months = 44 weeks
        calc.owed[:benefit_claimed_amount].round(1).should == 994.7
        # should only pay from Jan 7th (13 weeks * 20.3)
        calc.owed[:benefit_owed_amount].round(1).should == 263.9
      end

      it "correctly calculates weeks for a child who started & stopped in tax year" do
        calc = ChildBenefitTaxCalculator.new({
          :adjusted_net_income => "61000",
          :starting_children => {
            "1" => {
            :start => { :year => "2013", :month => "02", :day => "01" },
            :stop => { :year => "2013", :month => "03", :day => "01" }
            }
          },
          :year => "2012"
        })
        #child from 01/02 to 01/03 => 5 weeks * 20.3
        calc.owed[:benefit_owed_amount].round(1).should == 101.5
      end
    end # tax year 2012

    describe "tax year 2013" do
      it "calculates correctly for 60k income" do
        calc = ChildBenefitTaxCalculator.new({
          :adjusted_net_income => "61000",
          :starting_children => {
            "1" => {
            :start => { :year => "2014", :month => "03", :day => "01" },
            :stop => { :year => "", :month => "", :day => ""},
            :no_stop => true
            }
          },
          :year => "2013"
        })
        # starting child for 6 weeks
        calc.owed[:benefit_owed_amount].round(1).should == 121.8
      end

      it "calculates correctly for 60k income with starting & stopping children" do
        calc = ChildBenefitTaxCalculator.new({
          :adjusted_net_income => "61000",
          :starting_children => {
           "1" => {
            :start => { :year => "2014", :month => "03", :day => "01" },
            :stop => { :year => "", :month => "", :day => ""},
            :no_stop => true
           }
          },
          :stopping_children => [{ :year => "2013", :month => "05", :day => "01" }],
          :year => "2013"
        })
        # starting child for 6 weeks
        # stopping child for 4 weeks
        # only 1 child at a time == 20.3*10
        calc.owed[:benefit_owed_amount].round(1).should == 203
      end
    end # tax year 2013-14

  end # starting & stopping children
end
