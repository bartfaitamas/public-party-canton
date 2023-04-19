#!/usr/bin/env bash
PARTICIPANT_NAME=$1
PARTICIPANT_USER=$2

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ROOT_DIR=$SCRIPT_DIR/..
cd $ROOT_DIR

PARTICIPANT_DIR=config/$PARTICIPANT_NAME
PARTICIPANT_ID=$(jq -r ".party_participants | to_entries | .[] | select(.key | startswith(\"${PARTICIPANT_NAME}:\")) | .key" ${PARTICIPANT_DIR}/participant-config.json)

CLAIM=$(echo -n "{\"aud\":\"https://daml.com/jwt/aud/participant/${PARTICIPANT_ID}\",\"sub\":\"${PARTICIPANT_USER}\"}" | base64 -w0 | sed s/\+/-/g |sed 's/\//_/g' |  sed -E s/=+$//)
HEADER=$(echo -n '{"alg":"RS256","typ":"JWT"}' | base64 -w0 | sed s/\+/-/g | sed 's/\//_/g' | sed -E s/=+$//)
SIGNATURE=$(echo -n "${HEADER}.${CLAIM}" |  openssl dgst -sha256 -sign "config/${PARTICIPANT_NAME}/api.key" -binary | base64 -w0 | sed s/\+/-/g | sed 's/\//_/g' | sed -E s/=+$//)

echo "${HEADER}.${CLAIM}.${SIGNATURE}" > ${PARTICIPANT_USER}.jwt
