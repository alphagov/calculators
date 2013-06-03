class ChildBenefitTaxController < ApplicationController
  def landing
    @calculator = ChildBenefitTaxCalculator.new(params)
    @show_new_child_form = params[:commit] == "Add a new starting child"
    @show_old_child_form = params[:commit] == "Add a new stopping child"

    if params[:commit] == "Go"
      @calculator = ChildBenefitTaxCalculator.new(params)
    end
  end
end
