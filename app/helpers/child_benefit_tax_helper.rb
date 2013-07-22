# encoding: utf-8
module ChildBenefitTaxHelper
 
  def t_for_year(year, key)
    t "child_benefit_tax_calculator.year_#{year}.#{key}"
  end

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

  def tax_year_label(years)
    "#{years.first.year}/#{years.last.strftime("%y")}"
  end
end
