#!/bin/bash

out_dir="output"
out_html="index.html"
out_pdf="resume.pdf"

custom_dir="custom"
is_ci=false

if [[ ${ENV} != "ci" ]]; then
  echo "local build"
else
  is_ci=true
fi

function resume {
  if [ -z $1 ] || [ -z $2 ]; then
    echo "two arguments are required."
    echo "Usage: $0 input_directory_path output_directory_name"
    echo "Example: $0 ./ main"
    return 2
  fi
  local in=$1/resume.md
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

function cover {
  if [ -z $1 ] || [ -z $2 ]; then
    echo "two arguments are required."
    echo "Usage: $0 input_directory_path output_directory_name"
    echo "Example: $0 ./custom/Acme Acme"
  fi
  local in=$1/cover_letter.pdf
  local out_dir=output/$2

  if [ -f $in ]; then
    mkdir -p $out_dir
    cp $in $out_dir/
  fi
}

case $1 in
  main)
    resume ./ main
    ;;
  -a)
    resume ./ main

    for dir in $(ls custom)
    do
      custom_dir="custom/${dir}"

      resume $custom_dir $dir
      cover $custom_dir $dir
    done
    ;;
  *)
    for target in "$@"
    do
      if [ $target == "main" ]; then
        resume ./ main
      else
        custom_dir=custom/$target
        resume $custom_dir $target
        cover $custom_dir $target
      fi
    done
    ;;
esac

if $is_ci; then
  rm -f $out_dir/**/$out_html $out_dir/**/$out_pdf
fi
