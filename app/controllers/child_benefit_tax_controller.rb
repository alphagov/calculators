class ChildBenefitTaxController < ApplicationController
  before_action :fetch_content_item
  before_action :set_up_education_navigation_ab_testing
  before_action :setup_navigation_helpers

  CALC_PARAM_KEYS = [:adjusted_net_income, :children_count, :starting_children, :year, :results, :part_year_children_count] +
    AdjustedNetIncomeCalculator::PARAM_KEYS

  def process_form
    redirect_hash = { action: :main }

    [:children, :adjusted_income, :results].each do |anchor|
      redirect_hash.merge!(anchor: anchor.to_s) if params[anchor]
    end

    CALC_PARAM_KEYS.each do |name|
      redirect_hash[name] = params[name]
    end

    redirect_to(redirect_hash)
  end

  def main
    @calculator = ChildBenefitTaxCalculator.new(params)
    @adjusted_net_income_calculator = @calculator.adjusted_net_income_calculator
    @calculator.valid? if params[:results]
  end

protected

  def fetch_content_item
    @content_item = Services.content_store.content_item("/child-benefit-tax-calculator/main").to_hash
    # Remove the organisations from the content item - this will prevent the
    # govuk:analytics:organisations meta tag from being generated until there is
    # a better way of doing this.
    if @content_item["links"]
      @content_item["links"].delete("organisations")
    end
  end

  def setup_navigation_helpers
    @navigation_helpers = GovukNavigationHelpers::NavigationHelper.new(@content_item)
    section_name = @content_item.dig("links", "parent", 0, "links", "parent", 0, "title")
    if section_name
      @meta_section = section_name.downcase
    end

    if @education_navigation_ab_test.should_present_new_navigation_view?
      @breadcrumbs = @navigation_helpers.taxon_breadcrumbs
    else
      @breadcrumbs = @navigation_helpers.breadcrumbs
    end
  end

  def set_up_education_navigation_ab_testing
    @education_navigation_ab_test = EducationNavigationAbTestRequest.new(
      request: request,
      content_item: @content_item,
    )

    return unless @education_navigation_ab_test.ab_test_applies?

    @education_navigation_ab_test.set_response_vary_header(response)

    # Setting a variant on a request is a type of Rails Dark Magic that will
    # use a convention to automagically load an alternative partial, view or
    # layout.  For example, if I set a variant of :new_navigation and we render
    # a partial called _breadcrumbs.html.erb then Rails will attempt to load
    # _breadcrumbs.html+new_navigation.erb instead. If this file doesn't exist,
    # then it falls back to _breadcrumbs.html.erb.  See:
    # http://edgeguides.rubyonrails.org/4_1_release_notes.html#action-pack-variants
    if @education_navigation_ab_test.should_present_new_navigation_view?
      request.variant = :new_navigation
    end
  end
end
