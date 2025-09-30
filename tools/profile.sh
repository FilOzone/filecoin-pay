#!/bin/bash

set -e

pushd ../localnet
bash ./reset.sh
source ./local_lotus.sh
popd

TOKEN_ADDRESS=0xe9ae74e0c182aab11bddb483227cc1f6600b3625
RAIL_ADDRESS=0xf6990c51dc94b36c5d5184bf60107efe99dde592

run() {
    forge script -vvv --broadcast --skip-simulation --chain-id $CHAIN_ID --sender $SENDER_ADDRESS --private-key $SENDER_KEY --rpc-url $API_URL/rpc/v1 --sig $1 tools/Profile.s.sol:Profile ${@:2}
}

report() {
    [[ "$(../forge-script-gas-report/forge_script_block_numbers ./broadcast/Profile.s.sol/$CHAIN_ID/$2-latest.json | wc -l)" -eq $1 ]] || (echo possible nondeterminism detected && exit 1)
    ../forge-script-gas-report/forge_script_gas_report ./broadcast/Profile.s.sol/$CHAIN_ID/$2-latest.json | tee -a .gas-profile
}
rm -f .gas-profile

run "createRail(address)" $SENDER_ADDRESS
report 621 createRail

run "settleRail(address,address,uint256)" $SENDER_ADDRESS $RAIL_ADDRESS 1
report 1 settleRail

run "terminateRail(address,address,uint256)" $SENDER_ADDRESS $RAIL_ADDRESS 1
report 1 terminateRail

run "endAuction(address,address,uint256)" $SENDER_ADDRESS $RAIL_ADDRESS 1
report 1 endAuction
