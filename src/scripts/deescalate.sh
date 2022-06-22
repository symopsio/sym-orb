#!/bin/bash


sudo apt-get update
sudo apt-get install gettext-base

REQUEST_SLUG=$(echo $REQUEST_SLUG | envsubst)

if [[ -z $RUN_ID ]]; then
  # No Run ID, check for Run Slug
  if [[ -n $REQUEST_SLUG ]]; then
    echo "Getting Run ID from $REQUEST_SLUG"
    RUN_ID=$(cat requests | jq --arg request_slug "$REQUEST_SLUG" '.[$request_slug].run_id')

    if [[ -n $RUN_ID ]]; then
      echo "De-escalating Run ID $RUN_ID"
    else
      echo "Did not find a Run ID for slug $REQUEST_SLUG"
      exit 1
    fi
  else
    echo "Missing argument: One of 'run_id' or 'request_slug' must be passed in."
    exit 1
  fi
else
  # Run ID exists, use the run_id
  echo "De-escalating $RUN_ID"
fi

REQUEST_BODY="$(jq --null-input \
  --argjson run_id "$RUN_ID" \
  '. + {
    "run_id": $run_id,
  }'
)"

curl -Ls -X POST "${SYM_API_URL}/events/deescalate" \
  --header "Authorization: Bearer ${SYM_JWT}" \
  --header "Content-Type: application/json" \
  --data "$REQUEST_BODY" | jq -r "."

if [ "$( jq 'has("error")' <<< $RESPONSE_BODY )" == "true" ]; then
  echo "Received an error when attempting to de-escalate!"
  echo $RESPONSE_BODY
  exit 1
fi
