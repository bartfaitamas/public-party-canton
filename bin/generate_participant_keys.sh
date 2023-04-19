#!/usr/bin/env bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ROOT_DIR=$SCRIPT_DIR/..
cd $ROOT_DIR

openssl req -nodes -new -x509 -keyout "config/central/api.key" -out "config/central/api.crt"
openssl req -nodes -new -x509 -keyout "config/traderOne/api.key" -out "config/traderOne/api.crt"
