#!/bin/bash
set -e

bundle install --path "${HOME}/bundles/${JOB_NAME}"
RACK_ENV=test bundle exec rake db:migrate
bundle exec rake ci:setup:rspec spec --trace
