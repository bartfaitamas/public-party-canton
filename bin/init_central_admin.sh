#!/usr/bin/env bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ROOT_DIR=$SCRIPT_DIR/..
cd $ROOT_DIR


REFERENCE_READER=$(jq -r ".party_participants | to_entries | .[] | select(.key | startswith(\"referenceDataReader:\")) | .key" config/central/participant-config.json)
CENTRAL_ADMIN=$(jq -r ".party_participants | to_entries | .[] | select(.key | startswith(\"centralAdmin:\")) | .key" config/central/participant-config.json)

PARTIES_FILE=$(mktemp)
echo "{\"centralAdmin\":\"${CENTRAL_ADMIN}\",\"referenceDataReader\":\"${REFERENCE_READER}\"}" > $PARTIES_FILE

daml script \
     --ledger-host localhost --ledger-port 5011 \
     --access-token-file centralAdminUser.jwt \
     --dar .daml/dist/public-party-0.0.1.dar \
     --input-file $PARTIES_FILE \
     --script-name CentralAdmin:initCentralAdmin

daml script \
     --ledger-host localhost --ledger-port 5011 \
     --access-token-file centralAdminUser.jwt \
     --dar .daml/dist/public-party-0.0.1.dar \
     --input-file $PARTIES_FILE \
     --script-name CentralAdmin:createReferenceData

rm $PARTIES_FILE
