#!/bin/bash

in="resume.md"
out_dir="output"
out_html="index.html"
out_pdf="Clark_Winters-resume.pdf"

custom_dir="custom"

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

for dir in $(ls custom)
do
  custom_dir="custom/${dir}"
  resume_in="${custom_dir}/resume.md"
  resume_out_dir="${out_dir}/${dir}"
  resume_out_pdf="${resume_out_dir}/${out_pdf}"
  resume_out_html="${resume_out_dir}/${out_html}"
  cover_letter="${custom_dir}/cover_letter.pdf"

  mkdir -p ${resume_out_dir}
  rm -rf ${resume_out_dir}/*
  cp -R assets ${resume_out_dir}/

  pandoc ${resume_in} -f markdown -t html -s -o ${resume_out_html} -c assets/style.css
  [ $? -eq 0 ] && echo "${timestamp}: ${resume_out_html} built successfully" || ( echo "${timestamp}: html build failed" && exit $? )

  chromium --headless --print-to-pdf-no-header --disable-pdf-tagging --print-to-pdf=${resume_out_pdf} ${resume_out_html}
  [ $? -eq 0 ] && echo "${timestamp}: ${resume_out_pdf} built successfully" || ( echo "${timestamp}: pdf build failed" && exit $? )

  # rm -f ${resume_out_html}

  if [ -f "${cover_letter}" ]; then
    cp ${cover_letter} ${resume_out_dir}/
  fi
done