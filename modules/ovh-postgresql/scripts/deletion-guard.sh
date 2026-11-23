#!/bin/sh
if [ "$1" = "true" ]; then
  printf '%s\n' "$2" >&2
  exit 1
fi
