#!/bin/bash

# pandoc install
wget https://github.com/jgm/pandoc/releases/download/2.19.2/pandoc-2.19.2-1-amd64.deb
sudo apt install -y ./pandoc-2.19.2-1-amd64.deb

# chromium install
sudo apt install -y chromium-browser
