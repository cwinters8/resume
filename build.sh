#!/bin/bash

in="resume.md"
out_dir="output"
out_html="resume.html"
out_pdf="resume.pdf"

out="${out_dir}/${out_html}"
timestamp=$(date)

mkdir -p ${out_dir}
cp -R assets ${out_dir}/

pandoc ${in} -f markdown -t html -s -o ${out} -c assets/style.css

[ $? -eq 0 ] && echo "${timestamp}: ${out} built successfully" || ( echo "${timestamp}: html build failed" && exit $? )

[ ${ENV} == "ci" ] && ( echo "can't create pdf in ci yet. stopping here" && exit 0 ) || echo "not ci. continuing to pdf printing"

in=${out}
out="${out_dir}/${out_pdf}"

chromium --headless --print-to-pdf=${out} ${in}

[ $? -eq 0 ] && echo "${timestamp}: ${out} built successfully" || ( echo "${timestamp}: pdf build failed" && exit $? )
