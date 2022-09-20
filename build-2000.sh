#!/usr/bin/env bash

# This script assumes that all pre-requisites are installed.
cargo clean
cargo cache --autoclean
cargo update
cargo update -p ctor --precise 0.1.22
cargo update -p syn --precise 1.0.96
cargo build --release

./target/release/parachain-collator build-spec --disable-default-bootnode > rococo-local-parachain-plain.json
sed -in-place -e 's#"para_id": 1000#"para_id": 2000#g' ./rococo-local-parachain-plain.json
sed -in-place -e 's#"parachainId": 1000#"parachainId": 2000#g' ./rococo-local-parachain-plain.json
./target/release/parachain-collator build-spec --chain rococo-local-parachain-plain.json --raw --disable-default-bootnode > rococo-local-parachain-2000-raw.json
./target/release/parachain-collator export-genesis-wasm --chain rococo-local-parachain-2000-raw.json > para-2000-wasm
./target/release/parachain-collator export-genesis-state --chain rococo-local-parachain-2000-raw.json > para-2000-genesis

./target/release/parachain-collator build-spec --disable-default-bootnode > rococo-local-parachain-plain.json
sed -in-place -e 's#"para_id": 1000#"para_id": 2001#g' ./rococo-local-parachain-plain.json
sed -in-place -e 's#"parachainId": 1000#"parachainId": 2001#g' ./rococo-local-parachain-plain.json
./target/release/parachain-collator build-spec --chain rococo-local-parachain-plain.json --raw --disable-default-bootnode > rococo-local-parachain-2001-raw.json
./target/release/parachain-collator export-genesis-wasm --chain rococo-local-parachain-2001-raw.json > para-2001-wasm
./target/release/parachain-collator export-genesis-state --chain rococo-local-parachain-2001-raw.json > para-2001-genesis
