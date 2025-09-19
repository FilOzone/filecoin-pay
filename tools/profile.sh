#!/bin/bash

set -e

pushd ../localnet
bash ./reset.sh
source ./local_lotus.sh
popd

TOKEN_ADDRESS=0xe9ae74e0c182aab11bddb483227cc1f6600b3625
RAIL_ADDRESS=0xf6990c51dc94b36c5d5184bf60107efe99dde592

forge script -vvv -g 44000 --broadcast --chain-id $CHAIN_ID --sender $SENDER_ADDRESS --private-key $SENDER_KEY --rpc-url $API_URL/rpc/v1 --sig "createRail(address)" tools/Profile.s.sol:Profile $SENDER_ADDRESS
[[ "$(../forge-script-gas-report/forge_script_block_numbers ./broadcast/Profile.s.sol/$CHAIN_ID/createRail-latest.json | wc -l)" -eq 1 ]] || (echo possible nondeterminism detected && exit 1)
../forge-script-gas-report/forge_script_gas_report ./broadcast/Profile.s.sol/$CHAIN_ID/createRail-latest.json | tee .gas-profile

forge script -vvv -g 44000 --broadcast --chain-id $CHAIN_ID --sender $SENDER_ADDRESS --private-key $SENDER_KEY --rpc-url $API_URL/rpc/v1 --sig "settleRail(address,address,uint256)" tools/Profile.s.sol:Profile $SENDER_ADDRESS $RAIL_ADDRESS 1
[[ "$(../forge-script-gas-report/forge_script_block_numbers ./broadcast/Profile.s.sol/$CHAIN_ID/createRail-latest.json | wc -l)" -eq 1 ]] || (echo possible nondeterminism detected && exit 1)
../forge-script-gas-report/forge_script_gas_report ./broadcast/Profile.s.sol/$CHAIN_ID/settleRail-latest.json | tee -a .gas-profile

forge script -vvv -g 44000 --broadcast --chain-id $CHAIN_ID --sender $SENDER_ADDRESS --private-key $SENDER_KEY --rpc-url $API_URL/rpc/v1 --sig "terminateRail(address,address,uint256)" tools/Profile.s.sol:Profile $SENDER_ADDRESS $RAIL_ADDRESS 1
[[ "$(../forge-script-gas-report/forge_script_block_numbers ./broadcast/Profile.s.sol/$CHAIN_ID/createRail-latest.json | wc -l)" -eq 1 ]] || (echo possible nondeterminism detected && exit 1)
../forge-script-gas-report/forge_script_gas_report ./broadcast/Profile.s.sol/$CHAIN_ID/terminateRail-latest.json | tee -a .gas-profile
