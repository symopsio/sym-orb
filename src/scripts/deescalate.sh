#!/bin/bash
set -o pipefail
set -e

if [[ -z $RUN_ID ]]; then
  # No Run ID, check for Request Slug
  if [[ -n $REQUEST_SLUG ]]; then
    echo "Getting Run ID from $REQUEST_SLUG"
    RUN_ID=$(<requests jq -r --arg request_slug "$REQUEST_SLUG" '.[$request_slug].run_id')

    if [[ -z $RUN_ID ]]; then
      echo "Did not find a Run ID for slug $REQUEST_SLUG"
      exit 1
    fi
  else
    echo "Missing argument: One of 'run_id' or 'request_slug' must be passed in."
    exit 1
  fi
fi

echo "De-escalating $RUN_ID"

REQUEST_BODY="$(jq --null-input \
  --arg run_id "$RUN_ID" \
  '. + {
    "run_id": $run_id,
  }'
)"

response=$(curl --fail-with-body -Ls -X POST "${SYM_API_URL}/events/deescalate" \
  --header "Authorization: Bearer ${SYM_JWT}" \
  --header "Content-Type: application/json" \
  --data "$REQUEST_BODY") || exit_code=$?

if [[ -n $exit_code ]]; then
  echo "Sym API request failed!"
  echo "Response: ${response}"
  exit 1
fi
