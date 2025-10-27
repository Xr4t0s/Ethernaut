#!/bin/bash

set -u pipefail

for i in {1162..65553}; do
	res="$(cast keccak256 $i)"
	if [ res == "0x0000000000000000000000000000000000000000000000000000000000000000" ];then
		echo "$res found !"
		exit 1
	fi
done