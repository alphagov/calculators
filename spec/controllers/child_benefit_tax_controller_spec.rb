require "spec_helper"
require 'gds_api/content_store'

describe ChildBenefitTaxController, type: :controller do
  include EducationNavigationAbTestHelper

  # Force the tests to render the views
  # Works around https://github.com/alphagov/slimmer/issues/170
  render_views

  describe "with a simple content store response" do
    before(:each) do
      expect_any_instance_of(GdsApi::ContentStore).to receive(:content_item).and_return({})
    end

    describe "GET 'landing'" do
      it "returns http success" do
        get 'landing'
        expect(response).to be_success
      end
    end

    describe "GET main" do
      it "should create a calculator using params" do
        get 'main', year: '2013'
        expect(response).to be_success
        expect(assigns(:calculator).tax_year).to eq(2013)
        expect(assigns(:adjusted_net_income_calculator).calculate_adjusted_net_income).to eq(0)
      end
      it "should run calculator validations" do
        get 'main', results: "Get your estimate"
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

  describe "A/B testing" do
    describe "content not tagged to a taxon" do
      before(:each) do
        expect_any_instance_of(GdsApi::ContentStore).to receive(:content_item).and_return(
          'links' => {
            'taxons' => [],
          },
        )
      end

      %w[A B].each do |variant|
        it "should not affect the landing page with the #{variant} variant" do
          setup_ab_variant('EducationNavigation', variant)
          expect_normal_navigation
          get :landing
          assert_response_not_modified_for_ab_test('EducationNavigation')
        end

        it "should not affect the main page with the #{variant} variant" do
          setup_ab_variant('EducationNavigation', variant)
          expect_normal_navigation_with_no_related_items
          get :main
          assert_response_not_modified_for_ab_test('EducationNavigation')
        end
      end
    end

    describe "content tagged to a taxon" do
      before(:each) do
        expect_any_instance_of(GdsApi::ContentStore).to receive(:content_item).and_return(
          'links' => {
            'taxons' => [
              {
                'base_path' => '/taxon',
                'title' => 'Taxon',
              },
            ],
          },
        )
      end

      it "should show normal navigation on the landing page by default" do
        expect_normal_navigation
        get :landing
      end

      it "should show normal navigation on the landing page for the 'A' version" do
        expect_normal_navigation
        with_variant EducationNavigation: "A" do
          get :landing
        end
      end

      it "should show new navigation on the landing page for the 'B' version" do
        expect_new_navigation
        with_variant EducationNavigation: "B" do
          get :landing
        end
      end

      it "should show normal navigation on the main page by default" do
        expect_normal_navigation_with_no_related_items
        get :main
      end

      it "should show normal navigation on the main page for the 'A' version" do
        expect_normal_navigation_with_no_related_items
        with_variant EducationNavigation: "A" do
          get :main
        end
      end

      it "should show new navigation on the main page for the 'B' version" do
        expect_new_navigation
        with_variant EducationNavigation: "B" do
          get :main
        end
      end
    end
  end
end
