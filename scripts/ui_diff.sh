#!/usr/bin/env bash

cd "$(dirname "$0")"

delta <(./ui_ffi.sh) <(./ui_h.sh)
# diff <(./ui_ffi.sh) <(./ui_h.sh)
