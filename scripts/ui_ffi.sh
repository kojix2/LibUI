#!/usr/bin/env bash

cd "$(dirname "$0")"

echo "count try_extern"
cat ../lib/libui/ffi.rb \
  | grep -v "def try_extern" \
  | grep -o "try_extern" \
  | wc -l

cat ../lib/libui/ffi.rb \
  | grep "try_extern" \
  | grep -v "def try_extern" \
  | sed -e "s/^[ \t]*//" -e "s/[ \t]*$//" \
  | sed -e "s/try_extern '//" -e "s/'$//"
