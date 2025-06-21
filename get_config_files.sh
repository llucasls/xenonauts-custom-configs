#!/bin/sh
dir="$1"
if test $# -eq 0; then
	printf NO_DIR
	exit 2;
fi

mkdir -p "${dir}"
if ! ls "${dir}"/*.yml >/dev/null 2>&1; then
	printf NO_YAML
	exit 1
fi

ls data/defaultconfig/00_header.yml "${dir}"/*.yml
