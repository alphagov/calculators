class ChildBenefitTaxController < ApplicationController

  before_filter :setup_slimmer

  CALC_PARAM_KEYS = [:adjusted_net_income, :children_count, :starting_children, :year] +
    AdjustedNetIncomeCalculator::PARAM_KEYS

  def landing
  end

  def process_form

    redirect_hash = { :action => :main }
  
    [:children, :adjusted_income, :results].each do |anchor|
      redirect_hash.merge!(:anchor => anchor.to_s) if params[anchor]
    end

    CALC_PARAM_KEYS.each do |name|
      redirect_hash[name] = params[name]
    end

    redirect_to(redirect_hash)
  end

  def main
    @calculator = ChildBenefitTaxCalculator.new(params)
    @adjusted_net_income_calculator = @calculator.adjusted_net_income_calculator
  end

  protected

  def setup_slimmer
    artefact = fetch_artefact('child-benefit-tax-calculator')
    set_slimmer_artefact_headers(artefact)
  end

end
