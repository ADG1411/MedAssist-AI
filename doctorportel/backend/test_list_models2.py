import asyncio
import httpx

NVIDIA_BASE_URL = "https://integrate.api.nvidia.com/v1"
SECONDARY_API_KEY = "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"

async def main():
    async with httpx.AsyncClient() as client:
        request = await client.get(
            f"{NVIDIA_BASE_URL}/models",
            headers={"Authorization": f"Bearer {SECONDARY_API_KEY}"}
        )
        try:
            data = request.json()
            if "data" in data:
                models = [m["id"] for m in data["data"]]
                step_models = [m for m in models if "step" in m.lower()]
                kimi_models = [m for m in models if "kimi" in m.lower() or "moonshot" in m.lower()]
                print("Step Models:", step_models)
                print("Kimi Models:", kimi_models)
        except Exception as e:
            print("Failed:", e)

if __name__ == "__main__":
    asyncio.run(main())
