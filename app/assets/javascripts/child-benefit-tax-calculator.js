(function () {
  'use strict'

  var root = this
  var $ = root.jQuery
  if (typeof root.GOVUK === 'undefined') { root.GOVUK = {} }

  var calculator = {
    partYearChildrenCountInput: $('#part_year_children_count'),
    childrenContainer: $('#children-template'),

    setEventHandlers: function () {
      calculator.partYearChildrenCountInput.on('change', calculator.updateChildrenFields)
    },

    updateChildrenFields: function () {
      var numStartingChildren = calculator.partYearChildrenCountInput.val()
      var childFields = calculator.childrenContainer.find('.js-child')
      var numChildFields = childFields.size()
      var numNewFields = numStartingChildren - numChildFields

      if (numStartingChildren < 1 || numStartingChildren > 10) {
        return false
      }

      if (numNewFields < 0) {
        childFields.slice(numNewFields).remove()
      } else if (numNewFields > 0) {
        for (var i = 0; i < numNewFields; i++) {
          var newChildIndex = numChildFields + i
          calculator.appendChildField(newChildIndex)
        }
      }
    },
    appendChildField: function (index) {
      var newChild = calculator.childFieldToClone().clone()

      newChild.find('.js-child-number').text(index + 1)
      newChild.find('.govuk-form-group').removeClass('govuk-form-group--error')
      newChild.find('.govuk-error-message').remove()
      newChild.find('select').each(function () {
        $(this).attr('id', calculator.replaceIndex(index, $(this).attr('id')))
        $(this).attr('name', calculator.replaceIndex(index, $(this).attr('name')))
        $(this).attr('aria-describedby', '')
        $(this).removeClass('govuk-select--error')
        $(this).val('')
      })
      newChild.find('label').each(function () {
        $(this).attr('for', calculator.replaceIndex(index, $(this).attr('for')))
      })

      newChild.appendTo(calculator.childrenContainer)
    },
    childFieldToClone: function () {
      // Always clone the first field so that we don't have to guess
      // the index (it will always be zero)
      return calculator.childrenContainer.find('.js-child').first()
    },
    replaceIndex: function (index, str) {
      return str.replace('0', index)
    }
  }

  root.GOVUK.childBenefitTaxCalculator = calculator
  GOVUK.childBenefitTaxCalculator.setEventHandlers()
}).call(this)
