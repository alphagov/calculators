module EducationNavigationAbTestHelper
  include GovukAbTesting::RspecHelpers

  def sidebar
    Nokogiri::HTML.parse(response.body).at_css(".related-container")
  end

  def expect_normal_navigation
    expect_any_instance_of(GovukNavigationHelpers::NavigationHelper).to receive(:breadcrumbs)
    expect_any_instance_of(GovukNavigationHelpers::NavigationHelper).to receive(:related_items)
  end

  def expect_normal_navigation_with_no_related_items
    expect_any_instance_of(GovukNavigationHelpers::NavigationHelper).to receive(:breadcrumbs)
  end

  def expect_new_navigation
    expect_any_instance_of(GovukNavigationHelpers::NavigationHelper).to receive(:taxon_breadcrumbs)
    expect_any_instance_of(GovukNavigationHelpers::NavigationHelper).to receive(:taxonomy_sidebar)
  end
end
