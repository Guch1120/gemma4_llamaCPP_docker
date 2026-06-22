# Gemma 4 E4B QAT GGUF + llama.cpp MTP Docker server

## Official image path

```bash
docker compose -f docker-compose.official.yml up -d
```

## Self-build fallback

```bash
docker compose -f docker-compose.build.yml build
docker compose -f docker-compose.build.yml up -d
```

## With UI

```bash
docker compose -f docker-compose.official.yml --profile ui up -d
# Open http://localhost:3000
```

## Test text

```bash
curl http://localhost:8080/v1/chat/completions \
  -H 'Content-Type: application/json' \
  -d '{"messages":[{"role":"user","content":"こんにちは。短く自己紹介して。"}],"max_tokens":128}' | jq
```

## Test image

```bash
python3 -m pip install openai
python3 test_image_request.py ./sample.jpg
```
