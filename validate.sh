#!/bin/bash

echo "path: ${PATH}"

args="--headless --dump-dom github.com"

which google-chrome
[ $? -eq 0 ] && echo "chrome found at $(which google-chrome)" && google-chrome ${args} && echo "headless chrome runs :)" && exit 0
if [ $? -eq 0 ]; then
  echo "chrome found at $(which google-chrome)"
  google-chrome ${args} && echo "headless chrome runs :)" && exit 0
  echo "headless chrome failed to run :("
  exit 1
fi

echo "google-chrome not found. trying google-chrome-stable..."

which google-chrome-stable
if [ $? -eq 0 ]; then
  echo "chrome found at $(which google-chrome-stable)"
  google-chrome-stable ${args} && echo "headless chrome runs :)" && exit 0
  echo "headless chrome failed to run :("
  exit 1
fi

echo "chrome not found :("
exit 1
