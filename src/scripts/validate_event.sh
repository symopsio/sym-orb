#!/bin/bash
set -o pipefail
set -e

if [ $EUID = 0 ]; then export SUDO=""; else # Check if we are root
  export SUDO="sudo";
fi

if ! command -v envsubst >/dev/null 2>&1; then
  $SUDO apt-get -qq -y update
  $SUDO apt-get -qq -y install gettext-base
fi

REQUEST_SLUG=$(echo $REQUEST_SLUG | envsubst)

if [[ -z $EVENT_ID ]]; then
  # No Event ID, check for Request Slug and Event Name
  if [[ -n $REQUEST_SLUG && -n $EVENT_NAME ]]; then
    echo "Getting Event ID from $REQUEST_SLUG for event $EVENT_NAME"

    if [ "$EVENT_NAME" = "deescalate" ]; then
        file_name="deescalates.json"
    elif [ "$EVENT_NAME" = "request" ]; then
        file_name="requests.json"
    else
      echo "$EVENT_NAME is not a valid event name. Valid names: 'deescalate', 'request'"
      exit 1
    fi

    EVENT_ID=$(</tmp/workspace/sym/$file_name jq -r --arg request_slug "$REQUEST_SLUG" '.[$request_slug].event_id')

    if [[ -z $EVENT_ID ]]; then
      echo "Did not find an Event ID for slug $REQUEST_SLUG and event $EVENT_NAME"
      exit 1
    fi
  else
    echo "Missing argument: 'event_id' or both 'request_slug' and 'event_name' must be passed in."
    exit 1
  fi
fi

attempt=0
while [ "$attempt" -lt "$EVENT_STATUS_POLL_MAX_ATTEMPTS" ]
do
  echo "Polling Event Status for Event ID $EVENT_ID"

  response=$(curl --fail-with-body -Ls -X GET "${SYM_API_URL}/events/${EVENT_ID}" \
    --header "Authorization: Bearer ${SYM_JWT}" \
    --header "Content-Type: application/json") || exit_code=$?

  if [[ -n $exit_code ]]; then
    echo "Sym API request failed!"
    echo "Response: ${response}"
    exit 1
  fi

  event_status=$(echo $response | jq -r ".status")

  if [ "$event_status" = "success" ]; then
    echo "Received status 'success' for Event ID $EVENT_ID"
    exit 0
  elif [ "$event_status" = "error" ]; then
    echo "Received status 'error' Event ID $EVENT_ID"
    exit 1
  fi

  echo [ "$event_status" = "success" ]
  echo "Received status '$event_status' for Event ID $EVENT_ID"
  sleep "$EVENT_STATUS_POLL_INTERVAL"

  attempt=$((attempt + 1))
done

echo "Reached maximum number of event polling attempts $EVENT_STATUS_POLL_MAX_ATTEMPTS with an interval of $EVENT_STATUS_POLL_INTERVAL"

if [[ "$EVENT_FAIL_ON_VERIFY_TIMEOUT" = "1" ]]; then
  exit 1
fi
