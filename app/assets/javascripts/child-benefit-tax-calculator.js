GOVUK = GOVUK || {};
GOVUK.ChildBenefitTaxCalculator = (function(){
  $("#children_count").on('change', function(e){
console.log("foo")
  	$("#child_benefit_tax_calculator").submit();
  });
})();