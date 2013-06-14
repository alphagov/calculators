class ChildBenefitTaxController < ApplicationController
  def landing
  end

  def main
    unless params[:year]
      redirect_to :action => :landing
    end

    @calculator = ChildBenefitTaxCalculator.new(params)
    @show_new_child_form = params[:add_another_starting_child_submit] == "Add another child"
    @show_old_child_form = params[:add_another_stopping_child_submit] == "Add another child"

    @show_extra_income = (params[:commit] == "I don't know my net income" || params[:show_extra_income] == "true")

    # for adding a new starting child
    @start_child_show_starting_date = params[:does_have_starting_children] && params[:does_have_starting_children] == "Yes"

    # do we have a new starting child & need to show the field for their stopping date?
    @start_child_show_stopping_date = params[:starting_child_does_stop] && params[:starting_child_does_stop] == "Yes"

    # does the new start child not have a stopping date?
    @start_child_no_stopping_date = params[:starting_child_does_stop] && params[:starting_child_does_stop] == "No"

    # show the stopping date for a stopping child
    @stop_child_show_date = params[:does_have_stopping_children] && params[:does_have_stopping_children] == "Yes"
  end
end
