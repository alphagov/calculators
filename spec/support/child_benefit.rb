RSpec::Matchers.define :contain_child_benefit_value do |text|
  match do |page|
    within ".results" do
      within :xpath, ".//div[contains(@class, 'results_estimate')][.//h3[.='Child Benefit received']]" do
        page.should have_content(text)
      end
    end
  end
end
