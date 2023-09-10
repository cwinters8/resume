#!/bin/bash

md="resume.md"
out_dir="output"
out_html="index.html"
out_pdf="Clark_Winters-resume.pdf"

custom_dir="custom"
is_ci=false

if [[ ${ENV} != "ci" ]]; then
  echo "local build"
else
  is_ci=true
fi

function build {
  local in=$1
  local out_dir=output/$2
  local out="${out_dir}/${out_html}"
  local timestamp=$(date)
  
  mkdir -p ${out_dir}
  rm -rf ${out_dir}/*
  
  cp -R assets ${out_dir}/
  
  pandoc ${in} -f markdown -t html -s -o ${out} -c assets/style.css

  [ $? -eq 0 ] && echo "${timestamp}: ${out} built successfully" || ( echo "${timestamp}: html build failed" && exit $? )

  in=${out}
  out="${out_dir}/${out_pdf}"

  chromium --headless --print-to-pdf-no-header --disable-pdf-tagging --print-to-pdf=${out} ${in}

  [ $? -eq 0 ] && echo "${timestamp}: ${out} built successfully" || ( echo "${timestamp}: pdf build failed" && exit $? )
}

if [ $1 == "-a" ]; then
  build ./${md} 
fi



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

  if $is_ci; then
    rm -f ${resume_out_html} ${resume_out_pdf}
  fi

  if [ -f "${cover_letter}" ]; then
    cp ${cover_letter} ${resume_out_dir}/
  fi
done