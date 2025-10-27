#!/bin/bash

set -o pipefail
set -o nounset

if [ "$#" -lt 3 ]; then
        echo "Usage: $0 <target> <rpc> <pk>"
        echo "You can find your target on etherscan.io. Find the contract then review the creation transaction, look how many contrats were build."
fi
