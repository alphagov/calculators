# encoding: UTF-8
require 'spec_helper'

describe ChildBenefitTaxCalculator do
  it "uses the adjusted net income if it's passed in" do
    calc = ChildBenefitTaxCalculator.new({
      :adjusted_net_income=> "20"
    })
    calc.adjusted_net_income.should == 20
  end

  it "isnt valid if enough detail is not supplied" do
    # nothing given
    ChildBenefitTaxCalculator.new.can_calculate?.should == false
  end

  it "is valid if given enough detail" do
    ChildBenefitTaxCalculator.new({
      :year => "2012", :children_count => "1",
      :starting_children => { "0" => { :start => { :year => "2011", :month => "01", :day => "01" } } }
    }).can_calculate?.should == true
  end

  it "parses integers from various formats of numerical input" do
    calc = ChildBenefitTaxCalculator.new({
      :adjusted_net_income => "£100,900"
    })
    calc.adjusted_net_income.should == 100900
  end

  describe "input validation" do
    before(:each) do
      @calc = ChildBenefitTaxCalculator.new(:children_count => "1")
      @calc.valid?
    end
    it "should contain errors for year if none is given" do
      @calc.errors.has_key?(:tax_year).should == true
    end
    it "should contain errors for year if outside of tax years range" do
      @calc = ChildBenefitTaxCalculator.new(:year => "2010")
      @calc.valid?
      @calc.errors.should have_key(:tax_year)
    end
    it "should validate dates provided for children" do
      @calc.starting_children.first.errors.has_key?(:start_date).should == true
      @calc.starting_children << StartingChild.new(:start => {:year => "2012", :month => "02", :day => "01"},
                                                   :stop => {:year => "2012", :month => "01", :day => "01"})
      @calc.valid?
      @calc.starting_children.second.errors.has_key?(:end_date).should == true
    end
    it "should contain an error on starting child if all outside of tax year" do
      @calc = ChildBenefitTaxCalculator.new(:year => "2013", :children_count => "1", :starting_children => {
        "0" => {
          :start => { :year => "2011", :month => "01", :day => "01" },
          :stop => { :year => "2012", :month => "01", :day => "01" }
        }
      })
      @calc.valid?
      @calc.starting_children.first.errors.should have_key(:end_date)
    end

    it "can't calculate if there are any errors" do
      @calc = ChildBenefitTaxCalculator.new(:year => "2013", :children_count => "1", :starting_children => {
        "0" => {
          :start => { :year => "2011", :month => "01", :day => "01" },
          :stop => { :year => "2012", :month => "01", :day => "01" }
        }
      })
      @calc.valid?

      @calc.can_calculate?.should be_false
    end
    it "should be valid on starting child when some inside the tax year" do
      @calc = ChildBenefitTaxCalculator.new(:year => "2013", :children_count => "3", :starting_children => {
        "0" => {
          :start => { :year => "2011", :month => "01", :day => "01" },
          :stop => { :year => "2012", :month => "01", :day => "01" }
        },
        "1" => {
          :start => { :year => "2013", :month => "01", :day => "01" },
          :stop => { :year => "2014", :month => "01", :day => "01" }
        },
        "2" => {
          :start => { :year => "2013", :month => "01", :day => "01" }
        }
      })
      @calc.valid?
      @calc.should_not have_errors
      @calc.starting_children.first.errors.should be_empty
    end
    describe "has_errors?" do
      it "should be true if the calculator has errors" do
        @calc.starting_children << StartingChild.new(:start => {:year => "2012", :month => "02", :day => "01"})
        @calc.has_errors?.should == true
        @calc.errors.size.should == 1
      end
      it "should be true if any starting children have errors" do
        calc = ChildBenefitTaxCalculator.new(:year => "2012", :children_count => "1")
        calc.valid?
        calc.errors.should be_empty
        #puts calc.starting_children.first.errors.full_messages
        calc.has_errors?.should == true
      end
      it "should be false if the tax year and starting date are valid" do
        ChildBenefitTaxCalculator.new(:year => "2012", :children_count => "1", :starting_children => {
          "0" => { :start => { :year => "2012", :month => "01", :day => "07" } }
        }).has_errors?.should == false
      end
    end
  end

  describe "calculating benefits received" do
    it "should give the total amount of benefits received for a full tax year" do
      ChildBenefitTaxCalculator.new({
        :year => "2012",
        :children_count => "1",
        :starting_children => {
          "0" => {
            :start => { :year => "2011", :month => "02", :day => "01" },
            :stop => { :year => "2013", :month => "05", :day => "01" }
          }
        }
      }).benefits_claimed_amount.round(2).should == 263.9
    end
    it "should give the total amount of benefits received for a full tax year" do
      ChildBenefitTaxCalculator.new({
        :year => "2013",
        :children_count => "1",
        :starting_children => {
          "0" => {
            :start => { :year => "2012", :month => "02", :day => "01" },
            :stop => { :year => "2014", :month => "05", :day => "01" }
          }
        }
      }).benefits_claimed_amount.round(2).should == 1055.6
    end
    it "should give the total amount of benefits received for a partial tax year" do
      ChildBenefitTaxCalculator.new({
        :year => "2012",
        :children_count => "1",
        :starting_children => {
          "0" => {
            :start => { :year => "2012", :month => "06", :day => "01" },
            :stop => { :year => "2013", :month => "06", :day => "01" }
          }
        }
      }).benefits_claimed_amount.round(2).should == 263.9
    end
    it "should give the total amount of benefits received for a partial tax year with more than one child" do
      ChildBenefitTaxCalculator.new({
        :year => "2012",
        :children_count => "2",
        :starting_children => {
          "0" => {
            :start => { :year => "2012", :month => "06", :day => "01" },
            :stop => { :year => "2013", :month => "06", :day => "01" }
          },
          "1" => { :start => { :year => "2012", :month => "05", :day => "01" },
            :stop => { :year => "2013", :month => "07", :day => "25" }
          }
        }
      }).benefits_claimed_amount.round(2).should == 438.1
    end
  end

  describe "calculating adjusted net income" do
    it "should use the adjusted_net_income parameter when none of the calculation params are used" do
      ChildBenefitTaxCalculator.new({
        :adjusted_net_income => "50099",
        :other_income => "0",
        :year => "2012",
        :children_count => 2
      }).adjusted_net_income.should == 50099
    end

    it "should calculate the adjusted net income with the relevant params" do
      ChildBenefitTaxCalculator.new({
        :gross_income => "£68000",
        :other_income => "£2000",
        :pensions => "£2000",
        :property => "£1000",
        :non_employment_income => "£1000",
        :pension_contributions_from_pay => "£2000",
        :gift_aid_donations => "£1000",
        :retirement_annuities => "£1000",
        :cycle_scheme => "£800",
        :childcare => "£1500",
        :year => "2012",
        :children_count => 2
      }).adjusted_net_income.should == 67450
    end

    it "should ignore the adjusted_net_income parameter when using the calculation form params" do
      ChildBenefitTaxCalculator.new({
        :adjusted_net_income => "£65,000",
        :gross_income => "£68000",
        :other_income => "£2000",
        :pensions => "£2000",
        :property => "£1000",
        :non_employment_income => "£1000",
        :pension_contributions_from_pay => "£2000",
        :gift_aid_donations => "£1000",
        :retirement_annuities => "£1000",
        :cycle_scheme => "£800",
        :childcare => "£1500",
        :year => "2012",
        :children_count => 2
      }).adjusted_net_income.should == 67450
    end
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
    describe "below the income threshold" do
      it "should be true for incomes under the threshold" do
        ChildBenefitTaxCalculator.new({
          :adjusted_net_income => "49999",
          :children_count => 1,
          :starting_children => {
            "0" => { :start => { :year => "2011", :month => "01", :day => "01" } }
          },
          :year => "2012"
        }).nothing_owed?.should == true
      end
      it "should be true for incomes over the threshold" do
        ChildBenefitTaxCalculator.new({
          :adjusted_net_income => "50100",
          :children_count => 1,
          :starting_children => {
            "0" => { :start => { :year => "2011", :month => "01", :day => "01" } }
          },
          :year => "2012"
        }).nothing_owed?.should == false
      end
    end

    describe "for the tax year 2012-13" do
      it "calculates the correct amount owed for % charge of 100" do
        ChildBenefitTaxCalculator.new({
          :adjusted_net_income => "60001",
          :starting_children => {
            "0" => { :start => { :year => "2011", :month => "01", :day => "01" } }
          },
          :year => "2012"
        }).tax_estimate.round(2).should == 263
      end

      it "calculates the corect amount for % charge of 99" do
        ChildBenefitTaxCalculator.new({
          :adjusted_net_income => "59900",
          :children_count => 1,
          :starting_children => {
            "0" => { :start => { :year => "2011", :month => "01", :day => "01" } }
          },
          :year => "2012"
        }).tax_estimate.round(2).should == 261
      end

      it "calculates the correct amount for income < 59900" do
        ChildBenefitTaxCalculator.new({
          :adjusted_net_income => "54000",
          :children_count => 1,
          :starting_children => {
            "0" => { :start => { :year => "2011", :month => "01", :day => "01" } }
          },
          :year => "2012"
        }).tax_estimate.round(2).should == 105
      end
    end # tax year 2012-13

    describe "for the tax year 2013-14" do
      it "calculates correctly for >60k earning" do
        calc = ChildBenefitTaxCalculator.new({
          :adjusted_net_income => "60001",
          :children_count => 1,
          :starting_children => {
            "0" => { :start => { :year => "2013", :month => "01", :day => "01" } }
          },
          :year => "2013"
        })
        calc.tax_estimate.round(1).should == 1055
      end
      it "calculates correctly for >55.9k earning" do
        calc = ChildBenefitTaxCalculator.new({
          :adjusted_net_income => "59900",
          :children_count => 1,
          :starting_children => {
            "0" => { :start => { :year => "2013", :month => "01", :day => "01" } }
          },
          :year => "2013"
        })
        calc.tax_estimate.round(1).should == 1045
      end
      it "calculates correctly for >50k earning" do
        calc = ChildBenefitTaxCalculator.new({
          :adjusted_net_income => "54000",
          :children_count => "1",
          :starting_children => {
            "0" => { :start => { :year => "2011", :month => "01", :day => "01" },
              :stop => { :year => "", :month => "", :day => ""} }
          },
          :year => "2013"
        })
        calc.tax_estimate.round(1).should == 422
      end
    end # tax year 2013-14
  end # no starting / stopping children

  describe "starting and stopping children" do
    describe "tax year 2012" do
      it "calculates correctly with starting children" do
        calc = ChildBenefitTaxCalculator.new({
          :adjusted_net_income => "61000",
          :children_count => 1,
          :starting_children => {
            "0" => {
              :start => { :year => "2013", :month => "03", :day => "01" },
              :stop => { :year => "", :month => "", :day => ""}
            }
          },
          :year => "2012"
        })
        calc.tax_estimate.round(1).should == 101
      end

      it "doesn't tax before Jan 7th 2013" do
        calc = ChildBenefitTaxCalculator.new({
          :adjusted_net_income => "61000",
          :children_count => 1,
          :starting_children => {
            "0" => {
              :start => { :year => "2012", :month => "05", :day => "01" },
              :stop => { :year => "", :month => "", :day => ""}
            }
          },
          :year => "2012"
        })
        calc.tax_estimate.round(1).should == 263
      end

      it "correctly calculates weeks for a child who started & stopped in tax year" do
        calc = ChildBenefitTaxCalculator.new({
          :adjusted_net_income => "61000",
          :children_count => 1,
          :starting_children => {
            "0" => {
              :start => { :year => "2013", :month => "02", :day => "01" },
              :stop => { :year => "2013", :month => "03", :day => "01" }
            }
          },
          :year => "2012"
        })
        #child from 01/02 to 01/03 => 5 weeks * 20.3
        calc.tax_estimate.round(1).should == 81
      end

      it "has children in taxable period when children claimed for after 7th January" do
        calc = ChildBenefitTaxCalculator.new({
          :children_count => 3,
          :starting_children => {
            "0" => {
              :start => { :year => "2011", :month => "02", :day => "01" },
              :stop => { :year => "2013", :month => "01", :day => "15" }
            },
            "1" => {
              :start => { :year => "2011", :month => "02", :day => "01" },
              :stop => { :year => "2013", :month => "05", :day => "01" }
            },
            "2" => {
              :start => { :year => "2011", :month => "02", :day => "01" }
            }
          },
          :year => "2012"
        })
        calc.children_in_taxable_period?.should be_true
      end

      it "does not have any children in taxable period when stop dates all before 7th Jan 2013" do
        calc = ChildBenefitTaxCalculator.new({
          :children_count => 3,
          :starting_children => {
            "0" => {
              :start => { :year => "2011", :month => "02", :day => "01" },
              :stop => { :year => "2013", :month => "01", :day => "05" }
            },
            "1" => {
              :start => { :year => "2011", :month => "02", :day => "01" },
              :stop => { :year => "2012", :month => "12", :day => "01" }
            },
            "2" => {
              :start => { :year => "2011", :month => "02", :day => "01" },
              :stop => { :year => "2013", :month => "01", :day => "02" }
            }
          },
          :year => "2012"
        })
        calc.children_in_taxable_period?.should be_false
      end
    end # tax year 2012

    describe "tax year 2013" do
      it "calculates correctly for 60k income" do
        calc = ChildBenefitTaxCalculator.new({
          :adjusted_net_income => "61000",
          :children_count => 1,
          :starting_children => {
            "0" => {
              :start => { :year => "2014", :month => "02", :day => "22" },
              :stop => { :year => "", :month => "", :day => ""}
            }
          },
          :year => "2013"
        })
        # starting child for 5 weeks
        calc.tax_estimate.round(1).should == 101
      end
    end # tax year 2013-14
  end # starting & stopping children

  describe "HMRC test scenarios" do
    it "should calculate and estimate scenario 1" do
      ChildBenefitTaxCalculator.new({:year => "2012", :children_count => 1, :starting_children => {
        "0" => {
          :start => {:day => '07', :month => '01', :year => '2013'},
          :stop => {:day => '05', :month => '04', :year => '2013'}
        }
      }}).benefits_claimed_amount.round(2).should == 263.90

      ChildBenefitTaxCalculator.new({:year => "2012", :children_count => 2, :starting_children => {
        "0" => {
          :start => {:day => '07', :month => '01', :year => '2013'},
          :stop => {:day => '05', :month => '04', :year => '2013'}
        },
        "1" => {
          :start => {:day => '07', :month => '01', :year => '2013'},
          :stop => {:day => '23', :month => '03', :year => '2013'}
        }
      }}).benefits_claimed_amount.round(2).should == 411.30

      calc = ChildBenefitTaxCalculator.new({
        :adjusted_net_income => "£65,000", :year => "2012", :children_count => 3, :starting_children => {
          "0" => {
            :start => {:day => '07', :month => '01', :year => '2013'},
            :stop => {:day => '05', :month => '04', :year => '2013'}
          },
          "1" => {
            :start => {:day => '07', :month => '01', :year => '2013'},
            :stop => {:day => '23', :month => '03', :year => '2013'}
          },
          "2" => {
            :start => {:day => '14', :month => '02', :year => '2013'},
            :stop => {:day => '05', :month => '04', :year => '2013'}
          }
      }})

      calc.benefits_claimed_amount.round(2).should == 505.10
      calc.tax_estimate.round(2).should == 505
    end
    it "should calculate and estimate scenario 2" do
      calc = ChildBenefitTaxCalculator.new({
        :adjusted_net_income => "£50,150", :year => "2012", :children_count => 2, :starting_children => {
          "0" => {
            :start => {:day => '07', :month => '01', :year => '2013'},
            :stop => {:day => '05', :month => '04', :year => '2013'}
          },
          "1" => {
            :start => {:day => '07', :month => '01', :year => '2013'},
            :stop => {:day => '05', :month => '04', :year => '2013'}
          }
      }})

      calc.benefits_claimed_amount.round(2).should == 438.10
      calc.tax_estimate.round(2).should == 4
    end
    it "should calculate and estimate scenario 3" do
      calc = ChildBenefitTaxCalculator.new({
        :adjusted_net_income => "£50,499", :year => "2012", :children_count => 2, :starting_children => {
          "0" => {
            :start => {:day => '07', :month => '01', :year => '2013'},
            :stop => {:day => '05', :month => '04', :year => '2013'}
          },
          "1" => {
            :start => {:day => '07', :month => '01', :year => '2013'},
            :stop => {:day => '05', :month => '04', :year => '2013'}
          }
      }})

      calc.benefits_claimed_amount.round(2).should == 438.10
      calc.tax_estimate.round(2).should == 17
    end
    it "should calculate and estimate scenario 4" do
      calc = ChildBenefitTaxCalculator.new({
        :adjusted_net_income => "£60,000", :year => "2012", :children_count => 2, :starting_children => {
          "0" => {
            :start => {:day => '07', :month => '01', :year => '2013'},
            :stop => {:day => '05', :month => '04', :year => '2013'}
          },
          "1" => {
            :start => {:day => '07', :month => '01', :year => '2013'},
            :stop => {:day => '05', :month => '04', :year => '2013'}
          }
      }})

      calc.benefits_claimed_amount.round(2).should == 438.10
      calc.tax_estimate.round(2).should == 433
    end
    it "should calculate and estimate scenario 5" do
      calc = ChildBenefitTaxCalculator.new({
        :adjusted_net_income => "£57,175", :year => "2012", :children_count => 2, :starting_children => {
          "0" => {
            :start => {:day => '07', :month => '01', :year => '2013'},
            :stop => {:day => '05', :month => '04', :year => '2013'}
          },
          "1" => {
            :start => {:day => '07', :month => '01', :year => '2013'},
            :stop => {:day => '05', :month => '04', :year => '2013'}
          }
      }})

      calc.benefits_claimed_amount.round(2).should == 438.10
      calc.tax_estimate.round(2).should == 311
    end
    it "should calculate and estimate scenario 5 with an ANI of 55k" do
      calc = ChildBenefitTaxCalculator.new({
        :adjusted_net_income => "£55,000", :year => "2012", :children_count => 2, :starting_children => {
          "0" => {
            :start => {:day => '07', :month => '01', :year => '2013'},
            :stop => {:day => '05', :month => '04', :year => '2013'}
          },
          "1" => {
            :start => {:day => '07', :month => '01', :year => '2013'},
            :stop => {:day => '05', :month => '04', :year => '2013'}
          }
      }})

      calc.benefits_claimed_amount.round(2).should == 438.10
      calc.tax_estimate.round(2).should == 219
    end
  end
end
