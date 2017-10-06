Child Benefit tax calculator
===========

This calculator reports how much child benefit tax you are entitled during a tax year.

There is a cut-off date of 7 January 2013. This is the date [High Income Child Benefit Tax Charge](https://www.gov.uk/child-benefit-tax-charge/overview) came in effect.
This means that if the 2012 tax year is selected the calculator will only calculate the child benefit you are entitled to from 7 Jan 2013 to 5 Apr 2013, not for the entire tax year.


## Running the app

```
./startup.sh
```

To run the app with the live content store and static

```
./startup.sh --live
```

The only content in this app is [child-benefit-tax-calculator/main](http://calculators.dev.gov.uk/child-benefit-tax-calculator/main)

## Running tests

```
bundle exec rake spec
```

## Dependencies

- [publishing-api](https://github.com/alphagov/publishing-api): this app sends
  data to publishing-api to register URLs.
