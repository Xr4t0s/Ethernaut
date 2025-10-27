#!/bin/bash

set -u pipefail 

if [ "$#" -lt 4 ];then
	exit 1
fi

for i in {1..200};do
	cast send $TARGET 
