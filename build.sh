#!/bin/bash

in="resume.md"
out_dir="output"
out_html="index.html"
out_pdf="resume.pdf"

if [[ ${ENV} != "ci" ]]; then
  echo "local build"
  # out_dir="/usr/local/var/www/resume"
fi

out="${out_dir}/${out_html}"
timestamp=$(date)

mkdir -p ${out_dir}
rm -rf ${out_dir}/*
cp -R assets ${out_dir}/

pandoc ${in} -f markdown -t html -s -o ${out} -c assets/style.css

[ $? -eq 0 ] && echo "${timestamp}: ${out} built successfully" || ( echo "${timestamp}: html build failed" && exit $? )

in=${out}
out="${out_dir}/${out_pdf}"

chromium --headless --print-to-pdf-no-header --disable-pdf-tagging --print-to-pdf=${out} ${in}

[ $? -eq 0 ] && echo "${timestamp}: ${out} built successfully" || ( echo "${timestamp}: pdf build failed" && exit $? )
