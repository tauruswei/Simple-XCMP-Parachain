#!/usr/bin/env bash

set -x
rm -rf /tmp/parachain1/bob
./target/release/parachain-collator \
	--bob \
	--collator \
	--force-authoring \
	--chain rococo-local-parachain-2001-raw.json \
	--base-path /tmp/parachain1/bob \
	--port 40334 \
	--ws-port 8845 \
	-- \
	--execution wasm \
	--chain ./rococo_local.json \
	--bootnodes /ip4/127.0.0.1/tcp/30333/p2p/12D3KooWChdwJ8DbTUeLha2XVwgtAwVmYznZZJdq2hskZbdXHbVr \
	--port 30344 \
	--ws-port 9978