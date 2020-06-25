require_relative "../test_helper"
require "gds_api/content_store"

class ChildBenefitTaxControllerTest < ActionController::TestCase
  context "with a simple content store response" do
    context "GET main" do
      setup do
        Services.stubs(:content_store).returns(stub(:content_item => {}))
      end

      should "create a calculator using params" do
        get :main, params: { year: "2013" }
        assert_response :success
        assert_equal 2013, assigns(:calculator).tax_year
        assert_equal 0, assigns(:adjusted_net_income_calculator).calculate_adjusted_net_income
      end

      should "run calculator validations" do
        get :main, params: { results: "Get your estimate" }
        assert_response :success
        assert assigns(:calculator).errors.key?(:tax_year)
      end
    end

    context "GET process_form" do
      setup do
        Services.stubs(:content_store).returns(stub(:content_item => {}))
      end

      should "place a 'starting_children' anchor onto the redirected response" do
        route_params = { params: { children: "Update" } }
        # rubocop:disable Rails/HttpPositionalArguments
        get :process_form, route_params
        # rubocop:enable Rails/HttpPositionalArguments
        assert_redirected_to(action: :main, anchor: "children")
      end

      should "place an 'adjusted_income' anchor onto the redirected response" do
        route_params = { params: { adjusted_income: "I don't know my adjusted net income" } }
        # rubocop:disable Rails/HttpPositionalArguments
        get :process_form, route_params
        # rubocop:enable Rails/HttpPositionalArguments
        assert_redirected_to(action: :main, anchor: "adjusted_income")
      end

      should "place an 'results' anchor onto the redirected response" do
        route_params = { results: "Get your estimate" }
        get :process_form, params: route_params
        assert_redirected_to(action: :main, params: route_params, anchor: "results")
      end
    end

    context "with content store returning a forbidden response" do
      setup do
        stub_request(:get, "#{Plek.find('content-store')}/content/child-benefit-tax-calculator/main")
          .to_return(status: 403, headers: {})
      end
  
      should "should return 403 status" do
        get :main, params: { year: "2013" }
  
        assert_response(403)
      end
    end
  end
end
