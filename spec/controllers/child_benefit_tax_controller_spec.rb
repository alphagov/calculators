require "spec_helper"

describe ChildBenefitTaxController, :type => :controller do

  describe "slimmer headers" do
    context "when the artefact exists" do
      before :each do
        @artefact_data = artefact_for_slug('child-benefit-tax-calculator')
        content_api_has_an_artefact("child-benefit-tax-calculator", @artefact_data)
      end

      it "should populate slimmer header with the child benefit tax calculator artefact" do
        get 'main'
        expect(JSON.parse(@response.headers["X-Slimmer-Artefact"])).to eq(@artefact_data)
      end

      it "should set the artefact format in the slimmer headers" do
        get 'main'
        expect(@response.headers["X-Slimmer-Format"]).to eq("calculator")
      end
    end

    context "when the artefact doesn't exist" do
      before :each do
        content_api_does_not_have_an_artefact("child-benefit-tax-calculator")
      end

      it "should return success" do
        get 'main'
        expect(response).to be_success
      end
    end
  end

  describe "GET 'landing'" do
    it "returns http success" do
      get 'landing'
      expect(response).to be_success
    end
  end

  describe "GET main" do
    it "should create a calculator using params" do
      get 'main', { :year => '2013' }
      expect(response).to be_success
      expect(assigns(:calculator).tax_year).to eq(2013)
      expect(assigns(:adjusted_net_income_calculator).calculate_adjusted_net_income).to eq(0)
    end
    it "should run calculator validations" do
      get 'main', { :results => "Get your estimate" }
      expect(response).to be_success
      expect(assigns(:calculator).errors.has_key?(:tax_year)).to eq(true)
    end
  end

  describe "GET process_form" do
    it "should place a 'starting_children' anchor onto the redirected response" do
      route_params = { children: "Update" }
      get "process_form", route_params
      expect(response).to redirect_to(action: :main, anchor: "children")
    end
    it "should place an 'adjusted_income' anchor onto the redirected response" do
      route_params = { adjusted_income: "I don't know my adjusted net income" }
      get "process_form", route_params
      expect(response).to redirect_to(action: :main, anchor: "adjusted_income")
    end
    it "should place an 'results' anchor onto the redirected response" do
      route_params = { results: "Get your estimate" }
      get "process_form", route_params
      expect(response).to redirect_to(action: :main, params: route_params, anchor: "results")
    end
  end

end
