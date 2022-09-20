#!/usr/bin/env bash

# This script assumes that all pre-requisites are installed.
cargo clean
cargo cache --autoclean
cargo update
cargo update -p ctor --precise 0.1.22
cargo update -p syn --precise 1.0.96
cargo build --release