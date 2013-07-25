GOVUK = GOVUK || {};
GOVUK.ChildBenefitTaxCalculator = (function(){
  $("#children_count").on('change', function(e){
    $("#child_benefit_tax_calculator").submit();
  });
})();
