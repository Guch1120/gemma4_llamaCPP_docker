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




# Gemma 4 E4B QAT GGUF + NVIDIA Driver 535 向け llama.cpp server
このプロジェクトは、Docker 上で `unsloth/gemma-4-E4B-it-qat-GGUF` 用の `llama-server` を起動します。
MTP による投機的デコーディングと画像入力に対応しています。

## 対象とする制約
- NVIDIA Driver 535
- CUDA 12.x のみ対応。CUDA 13 イメージは使用しない
- Docker コンテナランタイム
- サーバ用途を優先し、可視化は任意
- OpenAI 互換の `/v1/chat/completions` 経由で画像入力を行う

## 推奨手順: 公式イメージを使う
```bash
cp .env.example .env
mkdir -p cache models
docker compose up -d
```
ログを確認する:
```bash
docker logs -f llama-gemma4-e4b
```
テキストリクエスト:
```bash
sudo apt-get install -y jq
./scripts/test_text.sh
```
画像リクエスト:
```python3
python3 -m pip install openai
python3 scripts/test_image.py ./sample.jpg
```
## 任意の UI
```bash
docker compose --profile ui up -d
```

以下を開く:
```bash
http://localhost:3000
```
## フォールバック: ローカルで CUDA 12.2 ビルド
公式イメージが Gemma 4 E2B/E4B の MTP に対して古すぎる場合、または CUDA のマイナーバージョン互換性で失敗する場合は、これを使用します。
```bash
docker compose -f docker-compose.build.yml build
docker compose -f docker-compose.build.yml up -d
```
RTX 30xx および 40xx の場合、デフォルトの CUDA アーキテクチャは `86;89` です。
GPU が異なる場合は、`docker-compose.build.yml` 内の `CMAKE_CUDA_ARCHITECTURES` を編集してください。

## 重要なエラー
以下のような表示が出た場合:
`unknown model architecture: gemma4-assistant`<br>
使用している `llama.cpp` が古すぎます。<br>
フォールバック用のビルドファイルを使用してください。

以下のような表示が出た場合:
```
cudaErrorCallRequiresNewerDriver
cudaErrorUnsupportedPtxVersion
```
ランタイムが Driver 535 で対応していない CUDA 機能、または PTX を使用しています。<br>
CUDA 12.2 のフォールバックビルドを使用するか、NVIDIA ドライバを更新してください。