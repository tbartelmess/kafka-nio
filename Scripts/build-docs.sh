#! /usr/bin/env sh

# run jazzy
if ! command -v jazzy > /dev/null; then
  gem install jazzy
fi

jazzy --clean \
      --author 'Thomas Bartelmess' \
      --author_url https://github.com/tbartelmess/kafka-nio \
      --github_url https://github.com/tbartelmess/kafka-nio \
      --theme fullwidth
