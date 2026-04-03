import asyncio
import httpx
import json

NVIDIA_BASE_URL = "https://integrate.api.nvidia.com/v1"
SECONDARY_API_KEY = "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"

async def main():
    async with httpx.AsyncClient() as client:
        # Check /v1/models to see what's available
        request = await client.get(
            f"{NVIDIA_BASE_URL}/models",
            headers={"Authorization": f"Bearer {SECONDARY_API_KEY}"}
        )
        print("Status code:", request.status_code)
        try:
            data = request.json()
            # print first 20 model ids
            if "data" in data:
                models = [m["id"] for m in data["data"]]
                print("Models available:", models[:20])
                print("Total models:", len(models))
                
                # Check for step and kimi
                step_models = [m for m in models if "step" in m.lower()]
                kimi_models = [m for m in models if "kimi" in m.lower() or "moonshot" in m.lower()]
                
                print("\nStep Models:", step_models)
                print("Kimi Models:", kimi_models)
            else:
                print(data)
        except Exception as e:
            print("Failed to get or parse models:", e)
            print(request.text)

if __name__ == "__main__":
    asyncio.run(main())
