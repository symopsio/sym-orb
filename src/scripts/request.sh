#!/bin/bash

sudo apt-get update
sudo apt-get install gettext-base
echo "========================================================================"
FLOW_SRN=$(echo $FLOW_SRN | envsubst)
FLOW_INPUTS=$(echo $FLOW_INPUTS | envsubst)
CONTEXT=$(echo $CONTEXT | envsubst)
REQUEST_SLUG=$(echo $REQUEST_SLUG | envsubst)

REQUEST_BODY="$(jq --null-input \
  --arg flow_srn "$FLOW_SRN" \
  --argjson flow_inputs "$FLOW_INPUTS" \
  --argjson context "$CONTEXT" \
  '{
    "flow_srn": $flow_srn,
    "flow_inputs": $flow_inputs,
    "context": $context
  }'
)"

echo "Request body:"
echo $REQUEST_BODY

RESPONSE_BODY=$(curl -Ls -X POST "${SYM_API_URL}/events/request" \
  --header "Authorization: Bearer ${SYM_JWT}" \
  --header "Content-Type:application/json" \
  --data "$REQUEST_BODY"
)

if [ "$( jq 'has("error")' <<< $RESPONSE_BODY )" == "true" ]; then
  echo "Received an error when attempting to make a request!"
  echo $RESPONSE_BODY
  exit 1
fi

if [[ -n $REQUEST_SLUG ]]; then
  echo "Response: $RESPONSE_BODY"
  echo "Saving response body to $REQUEST_SLUG"
  if [[ ! -f requests ]]; then
    echo "{}" > requests
  fi

  jq \
  --arg request_slug "$REQUEST_SLUG" \
  --argjson response_body "$RESPONSE_BODY" \
  '.+={($request_slug): $response_body}' requests > requests.tmp

  mv requests.tmp requests
fi
