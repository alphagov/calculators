# encoding: utf-8
module ChildBenefitTaxHelper
  
  def show_extra_income?
    params[:commit] == "I don't know my adjusted net income" or params[:show_extra_income] == "true"
  end

  def show_new_child_form?
    params[:add_another_starting_child_submit] == "Add another child"
  end

  def show_old_child_form?
    params[:add_another_stopping_child_submit] == "Add another child"
  end

  def start_child_show_stopping_date?
    params[:does_have_starting_children].present? and params[:does_have_starting_children] == "Yes"
  end

  def stop_child_show_date?
    params[:does_have_stopping_children].present? and params[:does_have_stopping_children] == "Yes"
  end

end
