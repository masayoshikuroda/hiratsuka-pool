#!/bin/bash

PDF_FILE=$1
#echo ${PDF_FILE}

TARGET_DATE=$2
#echo ${TARGET_DATE}

pdftotext -f 1 -l 1 -layout ${PDF_FILE} - | head -n 37 | tail -n 31 | grep "${TARGET_DATE}" | sed "s/${TARGET_DATE}/-/g" | cut -d '-' -f 2 | sed "s/^[ ]*//g" | cut -c 4- | tr -d '※' | tr -d ' '
