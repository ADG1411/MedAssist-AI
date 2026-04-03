import asyncio
from openai import AsyncOpenAI

NVIDIA_API_KEY = "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"
NVIDIA_BASE_URL = "https://integrate.api.nvidia.com/v1"
MODEL_NAME = "meta/llama-3.1-70b-instruct" 

client = AsyncOpenAI(
    base_url=NVIDIA_BASE_URL,
    api_key=NVIDIA_API_KEY,
    timeout=5.0
)

async def test():
    try:
        response = await client.chat.completions.create(
            model=MODEL_NAME,
            messages=[{"role": "user", "content": "Hello"}],
            max_tokens=10
        )
        print("Success:")
        print(response)
    except Exception as e:
        print("Error:", str(e))

asyncio.run(test())
