module ApplicationHelper
  def step(num, text)
    "<span class=\"step step-#{num}\">#{text}</span>".html_safe
  end

  def current_path_without_query_string
    request.original_fullpath.split("?", 2).first
  end

  def form_errors
    errors = []

    @calculator.starting_children.map(&:errors).map(&:messages).map(&:values).flatten.uniq.each do |message|
      errors << {
        text: message,
        href: "#children_heading",
      }
    end
    @calculator.errors.each do |key, message|
      errors << {
        text: message,
        href: "##{key}",
      }
    end

    errors
  end

  def children_select_options(selected)
    Array(1..10).map do |num|
      {
        text: num,
        value: num,
        selected: num == selected,
      }
    end
  end

  def q2_radio_options
    ChildBenefitTaxCalculator::TAX_YEARS.keys.map do |year|
      {
        value: year,
        text: "#{year} to #{year.to_i + 1}",
        checked: @calculator.tax_year == year.to_i,
      }
    end
  end

  def q3_radio_options
    %w[yes no].map do |option|
      {
        value: option,
        text: option.capitalize,
        checked: @calculator.is_part_year_claim == option,
        conditional: q3_conditional_content(option),
      }
    end
  end

  def day_options(selected)
    days = Array(1..31).map do |number|
      format_date(number, :day, selected)
    end
    days.unshift(text: "", value: "")
  end

  def month_options(selected)
    months = Array(1..12).map do |number|
      format_date(number, :month, selected)
    end
    months.unshift(text: "", value: "")
  end

  def year_options(selected)
    start_year = ChildBenefitTaxCalculator::START_YEAR - 1
    end_year = ChildBenefitTaxCalculator::END_YEAR

    years = Array(start_year..end_year).map do |number|
      format_date(number, :year, selected)
    end
    years.unshift(text: "", value: "")
  end

private

  def q3_conditional_content(option)
    if option == "yes"
      render "child_benefit_tax/part_tax_year_conditional"
    end
  end

  def format_date(number, type, selected)
    selected = selected ? Date.parse(selected.to_s).send(type) : nil
    {
      text: type.eql?(:month) ? Date::MONTHNAMES[number] : number,
      value: number,
      selected: number == selected,
    }
  end
end
