class ChildBenefitTaxController < ApplicationController
  
  before_filter :redirect_if_no_year, :except => :landing

  def landing
  end

  def process_form
    anchor = if params[:add_another_starting_child_submit].present?
      "add_new_starting_child"
    elsif params[:commit] == "I don't know my net income"
      "adjusted_income"
    elsif params[:add_another_stopping_child_submit].present?
      "add_new_stopping_child"
    elsif params[:commit] == "Estimate your tax charge"
      "results_box"
    else
      ""
    end

    redirect_obj = { :action => :main, :anchor => anchor }

    # params from the form
    # that need to be passed to the main method, through the redirect
    [:total_annual_income, :gross_pension_contributions, :net_pension_contributions, :trading_losses_self_employed, :gift_aid_donations, :adjusted_net_income, :starting_children, :stopping_children, :year, :children_count, :commit, :add_another_starting_child_submit, :add_another_stopping_child_submit, :does_have_starting_children, :starting_child_does_stop, :does_have_stopping_children].each do |name|
      redirect_obj[name] = params[name]
    end

    redirect_to(redirect_obj)
  end


  def main
    @calculator = ChildBenefitTaxCalculator.new(params)
  end

  private

  def redirect_if_no_year
    unless params[:year]
      redirect_to :action => :landing
    end
  end
end
