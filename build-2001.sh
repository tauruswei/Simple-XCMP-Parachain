#!/usr/bin/env bash

# This script assumes that all pre-requisites are installed.
./target/release/parachain-collator build-spec --disable-default-bootnode > rococo-local-parachain-plain.json
sed -in-place -e 's#"para_id": 1000#"para_id": 2001#g' ./rococo-local-parachain-plain.json
sed -in-place -e 's#"parachainId": 1000#"parachainId": 2001#g' ./rococo-local-parachain-plain.json
./target/release/parachain-collator build-spec --chain rococo-local-parachain-plain.json --raw --disable-default-bootnode > rococo-local-parachain-2001-raw.json
./target/release/parachain-collator export-genesis-wasm --chain rococo-local-parachain-2001-raw.json > para-2001-wasm
./target/release/parachain-collator export-genesis-state --chain rococo-local-parachain-2001-raw.json > para-2001-genesis
