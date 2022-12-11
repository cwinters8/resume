#!/bin/bash

out_dir="output"
out_file="resume.html"
css_file="style.css"

out="${out_dir}/${out_file}"
result="$(date): "

mkdir -p ${out_dir}
cp style.css ${out_dir}/

pandoc resume.md -f markdown -t html -s -o ${out} -c style.css

[ $? -eq 0 ] && result+="${out} built successfully" || result+="html build failed"

echo $result
