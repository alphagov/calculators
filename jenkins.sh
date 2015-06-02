#!/bin/bash -x
set -e

export RAILS_ENV=test
export GOVUK_APP_DOMAIN=dev.gov.uk

git clean -fdx
bundle install --path "${HOME}/bundles/${JOB_NAME}" --deployment

bundle exec rake

bundle exec rake assets:precompile
