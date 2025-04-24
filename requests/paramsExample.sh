#!/bin/bash

MISSING_PARAMS=()

[[ -z "$postId" ]] && MISSING_PARAMS+=("postId")
[[ -z "$id" ]] && MISSING_PARAMS+=("id")

if [[ ${#MISSING_PARAMS[@]} -gt 0 ]]; then
  echo "❌ Parameter missing: ${MISSING_PARAMS[*]}"
  exit 1
fi

URL="https://jsonplaceholder.typicode.com/comments?${URL_PARAMS}"

START_TIME=$(date +%s%N)

RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$URL" \
  -H "Content-Type: application/json")

END_TIME=$(date +%s%N)

DURATION=$(((END_TIME - START_TIME) / 1000000))

STATUS_CODE=$(echo "$RESPONSE" | tail -n1)
RESPONSE_BODY=$(echo "$RESPONSE" | sed '$d')

echo "GET - $URL - $STATUS_CODE - ${DURATION}ms"
echo
echo "$RESPONSE_BODY" | jq
