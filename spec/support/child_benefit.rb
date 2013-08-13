RSpec::Matchers::define :child_benefit_value_is do |text|
  match do |page|
    within ".results" do
      within :xpath, ".//div[contains(@class, 'results_estimate')][.//h2[.='Child Benefit received']]" do
        page.should have_content(value)
      end
    end
  end
end
