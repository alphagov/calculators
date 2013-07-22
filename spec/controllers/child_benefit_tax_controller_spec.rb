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
  end

  describe "GET process_form" do
    it "should place an 'adjusted_income' anchor onto the redirected response" do
      route_params = { :year => "2013", :commit => "I don't know my adjusted net income" }
      get 'process_form', route_params
      response.should redirect_to(:action => :main, :params => route_params, :anchor => "adjusted_income")
    end
    it "should place an 'results_box' anchor onto the redirected response" do
      route_params = { :year => "2013", :commit => "Get your estimate" }
      get 'process_form', route_params
      response.should redirect_to(:action => :main, :params => route_params, :anchor => "results_box")
    end
  end

end
