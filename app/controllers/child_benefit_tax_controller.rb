class ChildBenefitTaxController < ApplicationController
  def landing
  end

  def main
    unless params[:year]
      redirect_to :action => :landing
    end

    @calculator = ChildBenefitTaxCalculator.new(params)
    @show_new_child_form = params[:commit] == "Add another child"
    @show_old_child_form = params[:commit] == "Add a new stopping child"
    @show_extra_income = (params[:commit] == "I don't know my net income" || params[:show_extra_income] == "true")

    @start_child_show_starting_date = params[:does_have_starting_children] && params[:does_have_starting_children] == "Yes"

    @start_child_show_stopping_date = params[:starting_child_does_stop] && params[:starting_child_does_stop] == "Yes"

    @start_child_no_stopping_date = params[:starting_child_does_stop] && params[:starting_child_does_stop] == "No"

    @stop_child_show_date = params[:does_have_stopping_children] && params[:does_have_stopping_children] == "Yes"
  end
end
