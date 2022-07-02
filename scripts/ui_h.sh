#!/usr/bin/env bash

cd "$(dirname "$0")"

echo "count _UI_EXTERN"
curl -sL https://raw.githubusercontent.com/libui-ng/libui-ng/master/ui.h \
  | gcc -fpreprocessed -P -dD -E - \
  | grep -o _UI_EXTERN \
  | wc -l

curl -sL https://raw.githubusercontent.com/libui-ng/libui-ng/master/ui.h \
  | gcc -fpreprocessed -P -dD -E - \
  | grep -vP "^#" \
  | sed -z -e "s/\n//g" -e "s/;/\n/g" -e "s/\t/ /g" -e 's/  */ /g' \
  | grep "_UI_EXTERN" \
  | sed -e "s/^[ \t]*//" -e "s/[ \t]*$//" \
  | sed -e "s/^_UI_EXTERN //"


