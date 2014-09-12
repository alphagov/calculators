(function () {
  "use strict";

  var root = this,
    $ = root.jQuery;
  if (typeof root.GOVUK === 'undefined') { root.GOVUK = {}; }

  var calculator = {
    childrenCountInput: $("#children_count"),
    childrenContainer: $("fieldset#children"),

    setEventHandlers: function () {
      calculator.childrenCountInput.on('change', calculator.updateChildrenFields);
    },
    updateChildrenFields: function () {
      var numStartingChildren = calculator.childrenCountInput.val(),
        childFields = calculator.childrenContainer.find('> div.child'),
        numChildFields = childFields.size(),
        numNewFields = numStartingChildren - numChildFields;

      if (numStartingChildren < 1 || numStartingChildren > 10) {
        return false;
      }

      if (numNewFields < 0) {
        childFields.slice(numNewFields).remove();
      } else if (numNewFields > 0) {
        for (var i = 0; i < numNewFields; i++) {
          var newChildIndex = numChildFields + i;
          calculator.appendChildField(newChildIndex);
        }
      }
    },
    appendChildField: function (index) {
      var newChild = calculator.childFieldToClone().clone();

      newChild.find('.child-number').text(index+1);
      newChild.find('select').each( function() {
        $(this).attr('id', calculator.replaceIndex(index, $(this).attr('id')));
        $(this).attr('name', calculator.replaceIndex(index, $(this).attr('name')));
        $(this).val('');
      });
      newChild.find('label').each( function() {
        $(this).attr('for', calculator.replaceIndex(index, $(this).attr('for')));
      });

      newChild.appendTo(calculator.childrenContainer);
    },
    childFieldToClone: function () {
      // Always clone the first field so that we don't have to guess
      // the index (it will always be zero)
      return calculator.childrenContainer.find("> div.child").first();
    },
    replaceIndex: function (index, str) {
      return str.replace("0", index);
    }
  };

  root.GOVUK.childBenefitTaxCalculator = calculator;
  GOVUK.childBenefitTaxCalculator.setEventHandlers();
}).call(this);
