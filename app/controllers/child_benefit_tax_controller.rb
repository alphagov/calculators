class ChildBenefitTaxController < ApplicationController
  def landing
  end

  def process_form
    redirect_if_no_year

    anchor = ""
    if params[:add_another_starting_child_submit].present?
      anchor = "add_new_starting_child"
    elsif params[:commit] == "I don't know my adjusted net income"
      anchor = "adjusted_income"
    elsif params[:add_another_stopping_child_submit].present?
      anchor = "add_new_stopping_child"
    elsif params[:commit] == "Estimate your tax charge"
      anchor = "results_box"
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
    redirect_if_no_year

    @calculator = ChildBenefitTaxCalculator.new(params)
    @show_new_child_form = params[:add_another_starting_child_submit] == "Add another child"
    @show_old_child_form = params[:add_another_stopping_child_submit] == "Add another child"

    @show_extra_income = (params[:commit] == "I don't know my adjusted net income" || params[:show_extra_income] == "true")

    # TODO: do these vars get used?
    # for adding a new starting child
    @start_child_show_starting_date = params[:does_have_starting_children] && params[:does_have_starting_children] == "Yes"

    # do we have a new starting child & need to show the field for their stopping date?
    @start_child_show_stopping_date = params[:starting_child_does_stop] && params[:starting_child_does_stop] == "Yes"

    # does the new start child not have a stopping date?
    @start_child_no_stopping_date = params[:starting_child_does_stop] && params[:starting_child_does_stop] == "No"

    # show the stopping date for a stopping child
    @stop_child_show_date = params[:does_have_stopping_children] && params[:does_have_stopping_children] == "Yes"
  end

  private
  def redirect_if_no_year
    unless params[:year]
      redirect_to :action => :landing
    end
  end
end
