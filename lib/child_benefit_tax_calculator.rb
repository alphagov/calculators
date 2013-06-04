class ChildBenefitTaxCalculator
  attr_accessor :total_annual_income, :children_count, :starting_children, :stopping_children

  def initialize(params)
    @total_annual_income = params[:total_annual_income].to_i
    gross_pension_contributions = params[:gross_pension_contributions].to_i
    net_pension_contributions = params[:net_pension_contributions].to_i
    trading_losses_self_employed = params[:trading_losses_self_employed].to_i
    gift_aid_donations = params[:gift_aid_donations].to_i
    @starting_children = params[:starting_children] || []
    @stopping_children = params[:stopping_children] || []

    if @total_annual_income == 0
      @total_annual_income = gross_pension_contributions + net_pension_contributions + trading_losses_self_employed + gift_aid_donations
    end

    @children_count = params[:children_count].to_i
  end

  def owed
    @total_annual_income * 0.1 * @children_count
  end

end
