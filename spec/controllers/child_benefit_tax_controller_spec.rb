require "spec_helper"
require "gds_api/content_store"

describe ChildBenefitTaxController, type: :controller do
  # Force the tests to render the views
  # Works around https://github.com/alphagov/slimmer/issues/170
  render_views

  describe "with a simple content store response" do
    before(:each) do
      expect_any_instance_of(GdsApi::ContentStore).to receive(:content_item).and_return({})
    end

    describe "GET main" do
      it "should create a calculator using params" do
        get :main, params: { year: "2013" }
        expect(response).to be_successful
        expect(assigns(:calculator).tax_year).to eq(2013)
        expect(assigns(:adjusted_net_income_calculator).calculate_adjusted_net_income).to eq(0)
      end
      it "should run calculator validations" do
        get :main, params: { results: "Get your estimate" }
        expect(response).to be_successful
        expect(assigns(:calculator).errors.has_key?(:tax_year)).to eq(true)
      end
    end

    describe "GET process_form" do
      it "should place a 'starting_children' anchor onto the redirected response" do
        route_params = { params: { children: "Update" } }
        get :process_form, route_params
        expect(response).to redirect_to(action: :main, anchor: "children")
      end
      it "should place an 'adjusted_income' anchor onto the redirected response" do
        route_params = { params: { adjusted_income: "I don't know my adjusted net income" } }
        get :process_form, route_params
        expect(response).to redirect_to(action: :main, anchor: "adjusted_income")
      end
      it "should place an 'results' anchor onto the redirected response" do
        route_params = { results: "Get your estimate" }
        get :process_form, params: route_params
        expect(response).to redirect_to(action: :main, params: route_params, anchor: "results")
      end
    end
  end

  describe "with content store returning a forbidden response" do
    before(:each) do
      stub_request(:get, "#{Plek.find('content-store')}/content/child-benefit-tax-calculator/main").
        to_return(status: 403, headers: {})
    end

    it "should return 403 status" do
      get :main, params: { year: "2013" }

      expect(response.status).to eq 403
    end
  end
end
