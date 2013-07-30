require 'spec_helper'

describe ChildBenefitTaxController do

  describe "GET 'landing'" do
    it "returns http success" do
      get 'landing'
      response.should be_success
    end
  end

  describe "GET main" do
    it "should create a calculator using params" do
      get 'main', { :year => '2013' }
      response.should be_success
      assigns(:calculator).tax_year.should == 2013
    end
    it "should run calculator validations" do
      get 'main', { :results => "Get your estimate" }
      response.should be_success
      assigns(:calculator).errors.full_messages.first.should == "Tax year is not included in the list"
    end
  end

  describe "GET process_form" do
    it "should place a 'starting_children' anchor onto the redirected response" do
      route_params = { :children => "Update" }
      get 'process_form', route_params
      response.should redirect_to(:action => :main, :anchor => "children")
    end
    it "should place an 'adjusted_income' anchor onto the redirected response" do
      route_params = { :adjusted_income => "I don't know my adjusted net income" }
      get 'process_form', route_params
      response.should redirect_to(:action => :main, :anchor => "adjusted_income")
    end
    it "should place an 'results' anchor onto the redirected response" do
      route_params = { :results => "Get your estimate" }
      get 'process_form', route_params
      response.should redirect_to(:action => :main, :params => route_params, :anchor => "results")
    end
  end

end
