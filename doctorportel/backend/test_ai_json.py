import asyncio
import os
import sys

sys.path.append(os.path.join(os.getcwd(), 'doctorportel', 'backend'))
from app.services.ai_service import generate_json

async def main():
    print("Testing generate_json...")
    sys_prompt = "You are a clinical assistant. Return EXACTLY 3 insights."
    prompt = "Practice Data: 12 patients today, mostly flu."
    try:
        res = await generate_json(prompt, sys_prompt)
        print("Success! JSON Output:", res)
    except Exception as e:
        print("Failed:", e)

if __name__ == "__main__":
    asyncio.run(main())
