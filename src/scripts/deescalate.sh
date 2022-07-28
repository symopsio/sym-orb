#!/bin/bash
set -o pipefail
set -e

if [[ $EUID == 0 ]]; then export SUDO=""; else # Check if we are root
  export SUDO="sudo";
fi

if ! command -v envsubst >/dev/null 2>&1; then
  $SUDO apt-get -qq -y update
  $SUDO apt-get -qq -y install gettext-base
fi

REQUEST_SLUG=$(echo $REQUEST_SLUG | envsubst)

if [[ -z $RUN_ID ]]; then
  # No Run ID, check for Request Slug
  if [[ -n $REQUEST_SLUG ]]; then
    echo "Getting Run ID from $REQUEST_SLUG"
    RUN_ID=$(</tmp/workspace/sym/requests.json jq -r --arg request_slug "$REQUEST_SLUG" '.[$request_slug].run_id')

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
