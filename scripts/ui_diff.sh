#!/usr/bin/env bash

cd "$(dirname "$0")"

delta <(./ui_h.sh) <(./ui_ffi.sh)
# diff <(./ui_h.sh) <(./ui_ffi.sh)
