#!/bin/bash

RPC="$1"
HACK="$2"
KEY="$3"

for i in {1..10}; do
block="$(cast block-number -r $RPC)"
cast send $HACK "pwn()" -r $RPC --private-key $KEY
sleep 12
done
