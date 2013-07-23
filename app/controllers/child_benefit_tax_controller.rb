class ChildBenefitTaxController < ApplicationController

  FORM_PARAM_KEYS = [:total_annual_income, :gross_pension_contributions, :net_pension_contributions,
     :trading_losses_self_employed, :gift_aid_donations, :adjusted_net_income,
     :children_count, :starting_children, :year]

  def landing
  end

  def process_form

    redirect_hash = { :action => :main }
  
    [:children, :adjusted_income, :results].each do |anchor|
      redirect_hash.merge!(:anchor => anchor.to_s) if params[anchor]
    end

    FORM_PARAM_KEYS.each do |name|
      redirect_hash[name] = params[name]
    end

    redirect_to(redirect_hash)
  end


  def main
    @calculator = ChildBenefitTaxCalculator.new(params)
  end

end
