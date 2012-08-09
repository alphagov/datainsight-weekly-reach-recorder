#!/usr/bin/env bash
PROJECT_NAME="datainsight-weekly-visits-recorder"

ANSI_RED="\033[31m"
ANSI_RESET="\033[0m"

git diff-index --quiet HEAD
case $? in
  0)
    bundle package
    hash=$(git log --pretty=format:'%h' -n 1)
    zip -x vendor/ruby/\* -x \*.zip -x tmp\* -x .git\* -r $PROJECT_NAME-$hash *
    echo $hash
  ;;
  1)
    echo -e "${ANSI_RED}You have uncommitted changes${ANSI_RESET}"
  ;;
esac
