#!/usr/bin/env bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ROOT_DIR=$SCRIPT_DIR/..
cd $ROOT_DIR


REFERENCE_READER=$(jq -r ".party_participants | to_entries | .[] | select(.key | startswith(\"referenceDataReader:\")) | .key" config/traderOne/participant-config.json)
CENTRAL_ADMIN=$(jq -r ".party_participants | to_entries | .[] | select(.key | startswith(\"centralAdmin:\")) | .key" config/traderOne/participant-config.json)
PARTICIPANT_ADMIN=$(jq -r ".party_participants | to_entries | .[] | select(.key | startswith(\"traderOneAdmin:\")) | .key" config/traderOne/participant-config.json)

PARTIES_FILE=$(mktemp)
echo "{\"participantAdmin\":\"${PARTICIPANT_ADMIN}\",\"centralAdmin\":\"${CENTRAL_ADMIN}\",\"referenceDataReader\":\"${REFERENCE_READER}\"}" > $PARTIES_FILE

echo "Creating a trade...."

daml script \
     --ledger-host localhost --ledger-port 5021 \
     --access-token-file traderOneAdminUser.jwt \
     --dar .daml/dist/public-party-0.0.1.dar \
     --input-file $PARTIES_FILE \
     --script-name ParticipantAdmin:createTrade

echo "Creating a trade2...."

daml script \
     --ledger-host localhost --ledger-port 5021 \
     --access-token-file traderOneAdminUser.jwt \
     --dar .daml/dist/public-party-0.0.1.dar \
     --input-file $PARTIES_FILE \
     --script-name ParticipantAdmin:createTrade2

echo "Creating a trade, but it will fail....."

daml script \
     --ledger-host localhost --ledger-port 5021 \
     --access-token-file traderOneAdminUser.jwt \
     --dar .daml/dist/public-party-0.0.1.dar \
     --input-file $PARTIES_FILE \
     --script-name ParticipantAdmin:createTradeFail

rm $PARTIES_FILE
