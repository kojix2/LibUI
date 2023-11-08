#!/usr/bin/env bash

cd "$(dirname "$0")"

delta <(./ui_ffi.rb) <(./ui_h.rb)
# diff <(./ui_ffi.rb) <(./ui_h.rb)
