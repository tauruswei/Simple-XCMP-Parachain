# Simple-XCMP-Parachain

This is a  project for learning exploring blockchain runtime development with
[Substrate](https://substrate.dev/),  [Cumulus Parachain](https://github.com/paritytech/cumulus) and the
[FRAME](https://substrate.dev/docs/en/knowledgebase/runtime/frame).

This project implements a simple  XCMP protocol between two parachains where one parachain makes pallet call of another parachain.


## pallet-counter Design
This pallet defines a simple logic to set , increment and make xcm calls. Same pallet is used on both the parachain for testing xcmp functionality.

Requirements
- Follow Below steps to set up Relay Node and Parachain Node
- Only sudo user can make pallet call
- Build HRMP channel between( Parachain(2000) , Parachain(2001))

### Pallet Calls
- `set_counter(origin, para, value)`

set_counter method takes paraid and value as input and makes set_counter_value() pallet call of Parachain(paraID) by sending xcm message.

- `increment_counter(origin,para)`

increment_counter method takes paraId and makes increment_counter_value() pallet call of Parachain(ParaId) by sending xcm message.

### Storages
- `Counter: StorageValue => u32`

### Events
- `CounterSet(ParaId, u32)`
- `CounterIncremented(ParaId)`

### Errors
- `ErrorSettingCounter`
- `ErrorIncrementingCounter`
### Step1 Building the relay Chain node.

```sh
# Clone the Polkadot Repository
$ git clone -b release-v0.9.16  https://github.com/tauruswei/polkadot.git

# Build the relay chain Node
$ cargo build --release

# Check if the help page prints to ensure the node is built correctly
$ ./target/release/polkadot --help

```
### Step2 Building the parachain collector.
```
# 使用 build-2000.sh 脚本，可以跳过 step5 和 step6
bash build-2000.sh
```

你也可以手动编译 parachain-collector

```sh
# Clone the Polkadot Repository
$ git clone -b polkadot-0.9.16-test https://github.com/tauruswei/Simple-XCMP-Parachain.git

# Build the relay chain Node
$ cargo build --release

# Check if the help page prints to ensure the node is built correctly
$ ./target/release/parachain-collator --help

```

### Step3 Generate relay chain spec file.
There must be minimum 2 validator for 1 parachain. In this project we will be using two parachains , so therefore we will require 3 validator nodes
Check here to learn more [here](https://docs.substrate.io/v3/runtime/chain-specs/).
```sh
./target/release/polkadot build-spec \
--chain rococo-local \
--raw \
--disable-default-bootnode \
> rococo_local.json
```

### Step4 Start relay node with 3 validator： Alice, Bob and Charlie
```
bash start-alice.sh
bash start-bob.sh
bash start-chalie.sh
```
You can also manually start each of the three nodes：Alice, Bob and Charlie
- Alice
```sh
./target/release/polkadot \
--alice \
--validator \
--base-path /tmp/relay-alice \
--chain ./rococo_local.json \
--port 30333 \
--ws-port 9944
```

- Bob
```sh
./target/release/polkadot \
--bob \
--validator \
--base-path /tmp/relay-bob \
--chain ./rococo_local.json \
--bootnodes /ip4/127.0.0.1/tcp/30333/p2p/12D3KooWKYpSaYz9ByVsLFSq8rfqNbP5Zbad4i6FBT8MKuFd1Ez7 \
--port 30334 \
--ws-port 9945
```

- Charlie
```sh
./target/release/polkadot \
--charlie \
--validator \
--base-path /tmp/relay-charlie \
--chain ./rococo_local.json \
--bootnodes /ip4/127.0.0.1/tcp/30333/p2p/12D3KooWKYpSaYz9ByVsLFSq8rfqNbP5Zbad4i6FBT8MKuFd1Ez7 \
--port 30335 \
--ws-port 9946

```

### Step5 Configure Parachain for Relay chain （Para ID = 2000）

- Generate Plain spec with:
```sh
./target/release/parachain-collator build-spec --disable-default-bootnode > rococo-local-parachain-plain.json
```

- Update Para ID in Plain Spec file
```rust
	// --snip--
		"para_id": 2000, // <--- your already registered ID
		// --snip--
			"parachainInfo": {
				"parachainId": 2000 // <--- your already registered ID
	},
	// --snip--
```

- Generate Raw spec file from Plain Spec file
```sh
./target/release/parachain-collator build-spec --chain rococo-local-parachain-plain.json --raw --disable-default-bootnode > rococo-local-parachain-2000-raw.json
```

- Generate Wasm runtime blob
```sh
./target/release/parachain-collator export-genesis-wasm --chain rococo-local-parachain-2000-raw.json > para-2000-wasm
```

- Generate Parachain Genesis State (hex encoded)
```sh
./target/release/parachain-collator export-genesis-state --chain rococo-local-parachain-2000-raw.json > para-2000-genesis
```

### Step6 Configure Parachain for Relay chain and （Para ID = 2001）
```
./target/release/parachain-collator build-spec --disable-default-bootnode > rococo-local-parachain-plain.json
sed -in-place -e 's#"para_id": 1000#"para_id": 2001#g' ./rococo-local-parachain-plain.json
sed -in-place -e 's#"parachainId": 1000#"parachainId": 2001#g' ./rococo-local-parachain-plain.json
./target/release/parachain-collator build-spec --chain rococo-local-parachain-plain.json --raw --disable-default-bootnode > rococo-local-parachain-2001-raw.json
./target/release/parachain-collator export-genesis-wasm --chain rococo-local-parachain-2001-raw.json > para-2001-wasm
./target/release/parachain-collator export-genesis-state --chain rococo-local-parachain-2001-raw.json > para-2001-genesis
```

### Step7 Start parachain 2000
方式一：
```sh
bash start-2000.sh 
```
方式二：
```
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
```

### Step8 Start parachain 2001
方式一：
```sh
bash start-2001.sh 
```
方式二：
```
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
```
### Step 9 Experience cross-chain 
Resure Parachain ID using [Polkadot-js](https://polkadot.js.org/apps/?rpc=ws%3A%2F%2F127.0.0.1%3A9944#/parachains/parathreads)

Parachain ids start with 2000

参考：https://zhuanlan.zhihu.com/p/402627766
