require 'spec_helper'
require 'gds_api/test_helpers/content_api'
require 'webmock/rspec'

describe ChildBenefitTaxController do
  include GdsApi::TestHelpers::ContentApi

  before(:each) do
    @artefact_data = artefact_for_slug('child-benefit-tax-calculator')
    stub_request(:get, "http://contentapi.dev.gov.uk/child-benefit-tax-calculator.json").
      with(:headers => {'Accept'=>'application/json', 'Accept-Encoding'=>'gzip, deflate',
                        'Content-Type'=>'application/json', 'User-Agent'=>'GDS Api Client v. 7.2.0'}).
        to_return(:status => 200, :body => JSON.dump(@artefact_data), :headers => {})
    
    content_api_has_an_artefact("child-benefit-tax-calculator", @artefact_data)
  end

  describe "slimmer headers" do
    it "should populate slimmer header with the child benefit tax calculator artefact" do
      get 'main'
      @response.headers["X-Slimmer-Artefact"].should == JSON.dump(@artefact_data)
    end
    it "should set the artefact format in the slimmer headers" do
      get 'main'
      @response.headers["X-Slimmer-Format"].should == @artefact_data['format']
    end
  end

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
      assigns(:adjusted_net_income_calculator).calculate_adjusted_net_income.should == 0
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
      response.should redirect_to(:action => :main, :anchor => "results")
    end
  end

end
