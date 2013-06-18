require 'spec_helper'

describe ChildBenefitTaxHelper do
  
  describe "show_extra_income?" do
    it "should be true or false depending on params" do
      show_extra_income?.should == false
      params[:show_extra_income] = "false"
      show_extra_income?.should == false
      params[:commit] = "I know what you've got for xmas"
      show_extra_income?.should == false

      params[:show_extra_income] = "true"
      show_extra_income?.should == true
      params[:commit] = "I don't know my net income"
      show_extra_income?.should == true
    end
  end

  describe "show_new_child_form?" do
    it "should be true or false depending on params" do
      show_new_child_form?.should == false
      params[:add_another_starting_child_submit] = "Add another child"
      show_new_child_form?.should == true
    end
  end

end
