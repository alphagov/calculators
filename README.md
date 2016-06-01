Calculators
===========

This is an application to contain custom-built calculators.  These will initially replace some smart-answers that have
outgrown the framework.

## Running the app

```
./startup.sh
```

The only content in this app is [child-benefit-tax-calculator](http://calculators.dev.gov.uk/child-benefit-tax-calculator)

## Running tests

```
bundle exec rake spec
```

## Deploying changes for Factcheck

When making bigger changes that need to be tested or fact-checked before they are deployed to GOV.UK you might want to deploy the branch with changes to [Heroku](https://www.heroku.com/home).

Start by creating a GitHub pull request with the changes you want to deploy.

Make a note of the pull request number and use the `startup_heroku.sh` script to deploy your changes to Heroku:

```bash
$ PR=<number-of-pull-request> ./startup_heroku.sh
```

This script will create and configure an app on Heroku, push the __current branch__ and open the child-benefit-tax-calculator Calculator in the browser.
