import asyncio
import os
import httpx
from openai import AsyncOpenAI

NVIDIA_BASE_URL = "https://integrate.api.nvidia.com/v1"
SECONDARY_API_KEY = "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"

client = AsyncOpenAI(
    base_url=NVIDIA_BASE_URL,
    api_key=SECONDARY_API_KEY,
    http_client=httpx.AsyncClient(timeout=10.0),
)

async def test_model(model_name):
    print(f"\nTesting model: {model_name}")
    try:
        response = await client.chat.completions.create(
            model=model_name,
            messages=[{"role": "user", "content": "Say hello"}],
            max_tokens=10,
        )
        print(f"Success! Response: {response.choices[0].message.content}")
        return True
    except Exception as e:
        print(f"Failed: {type(e).__name__} - {e}")
        return False

async def main():
    models_to_test = [
        "stepfun-ai/step-3.5-flash",
        "nvidia/step-3.5-flash",
    ]
    for m in models_to_test:
        if await test_model(m):
            break

if __name__ == "__main__":
    asyncio.run(main())
