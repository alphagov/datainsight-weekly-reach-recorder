#!/bin/bash
set -e

bundle install --path "${HOME}/bundles/${JOB_NAME}"
bundle exec rake ci:setup:rspec spec --trace
