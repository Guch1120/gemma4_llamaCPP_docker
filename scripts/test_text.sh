#!/usr/bin/env bash
set -euo pipefail
curl -s http://localhost:8080/v1/chat/completions \
  -H 'Content-Type: application/json' \
  -d '{
    "messages": [
      {"role": "user", "content": "日本語で短く自己紹介して。"}
    ],
    "max_tokens": 128,
    "temperature": 0.2
  }' | jq .
