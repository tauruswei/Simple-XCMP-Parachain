#!/usr/bin/env bash

set -x
rm -rf /tmp/parachain1/alice
./target/release/parachain-collator \
	--alice \
	--collator \
	--force-authoring \
	--chain rococo-local-parachain-2000-raw.json \
	--base-path /tmp/parachain1/alice \
	--port 40333 \
	--ws-port 8844 \
	-- \
	--execution wasm \
	--chain ./rococo_local.json \
	--bootnodes /ip4/127.0.0.1/tcp/30333/p2p/12D3KooWChdwJ8DbTUeLha2XVwgtAwVmYznZZJdq2hskZbdXHbVr \
	--port 30343 \
	--ws-port 9977