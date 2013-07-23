class ChildBenefitTaxController < ApplicationController
  
  def landing
  end

  def process_form
    anchor = case params[:commit]
      when "Update"
        "starting_children"
      when "I don't know my adjusted net income"
        "adjusted_income"
      when "Get your estimate"
        "results_box"
      else
        ""
      end

    redirect_obj = { :action => :main, :anchor => anchor }

    # params from the form
    # that need to be passed to the main method, through the redirect
    [:total_annual_income, :gross_pension_contributions, :net_pension_contributions,
     :trading_losses_self_employed, :gift_aid_donations, :adjusted_net_income,
     :children_count, :starting_children, :year, :commit].each do |name|
      redirect_obj[name] = params[name]
    end

    redirect_to(redirect_obj)
  end


  def main
    @calculator = ChildBenefitTaxCalculator.new(params)
  end

end
