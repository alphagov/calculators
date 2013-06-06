class ChildBenefitTaxController < ApplicationController
  def landing
  end

  def main
    unless params[:year]
      redirect_to :action => :landing
    end

    @calculator = ChildBenefitTaxCalculator.new(params)
    @show_new_child_form = params[:commit] == "Add a new starting child"
    @show_old_child_form = params[:commit] == "Add a new stopping child"
  end
end
