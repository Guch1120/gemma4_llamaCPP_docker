import base64
import mimetypes
import sys
from openai import OpenAI

if len(sys.argv) < 2:
    print("usage: python3 test_image_request.py /path/to/image.jpg")
    raise SystemExit(1)

image_path = sys.argv[1]
mime = mimetypes.guess_type(image_path)[0] or "image/jpeg"
with open(image_path, "rb") as f:
    b64 = base64.b64encode(f.read()).decode("utf-8")

client = OpenAI(base_url="http://localhost:8080/v1", api_key="none")
resp = client.chat.completions.create(
    model="gemma4-e4b",
    messages=[
        {
            "role": "user",
            "content": [
                {"type": "text", "text": "この画像に写っているものを日本語で説明して。"},
                {"type": "image_url", "image_url": {"url": f"data:{mime};base64,{b64}"}},
            ],
        }
    ],
    max_tokens=512,
)

print(resp.choices[0].message.content)
