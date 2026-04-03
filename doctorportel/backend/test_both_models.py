import asyncio
import os
import httpx
from openai import AsyncOpenAI

NVIDIA_BASE_URL = "https://integrate.api.nvidia.com/v1"

PRIMARY_API_KEY = "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"
PRIMARY_MODEL = "moonshot/kimi-k2.5"

SECONDARY_API_KEY = "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"
SECONDARY_MODEL = "stepfun-ai/step-3.5-flash"

async def test_model(client, model_name):
    print(f"\n--- Testing model: {model_name} ---")
    try:
        response = await client.chat.completions.create(
            model=model_name,
            messages=[{"role": "user", "content": "Say hello"}],
            max_tokens=50,
        )
        print(f"Success! Response: {response.choices[0].message.content}")
        return True
    except Exception as e:
        print(f"Failed: {type(e).__name__} - {e}")
        return False

async def main():
    primary_client = AsyncOpenAI(base_url=NVIDIA_BASE_URL, api_key=PRIMARY_API_KEY, http_client=httpx.AsyncClient(timeout=15.0))
    secondary_client = AsyncOpenAI(base_url=NVIDIA_BASE_URL, api_key=SECONDARY_API_KEY, http_client=httpx.AsyncClient(timeout=15.0))

    await test_model(primary_client, PRIMARY_MODEL)
    await test_model(secondary_client, SECONDARY_MODEL)

if __name__ == "__main__":
    asyncio.run(main())
