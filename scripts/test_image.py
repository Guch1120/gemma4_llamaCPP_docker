#!/usr/bin/env python3
import base64
import mimetypes
import sys
from pathlib import Path
from openai import OpenAI

if len(sys.argv) != 2:
    print("Usage: python3 scripts/test_image.py /path/to/image.jpg", file=sys.stderr)
    sys.exit(1)

image_path = Path(sys.argv[1])
if not image_path.exists():
    raise FileNotFoundError(image_path)

mime = mimetypes.guess_type(image_path.name)[0] or "image/jpeg"
b64 = base64.b64encode(image_path.read_bytes()).decode("utf-8")

client = OpenAI(base_url="http://localhost:8080/v1", api_key="dummy")

resp = client.chat.completions.create(
    model="local-gemma4-e4b",
    messages=[
        {
            "role": "user",
            "content": [
                {"type": "image_url", "image_url": {"url": f"data:{mime};base64,{b64}"}},
                {"type": "text", "text": "この画像に何が写っているか、日本語で簡潔に説明して。"},
            ],
        }
    ],
    max_tokens=256,
    temperature=0.2,
)

print(resp.choices[0].message.content)
