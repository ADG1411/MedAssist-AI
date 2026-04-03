import asyncio
import sys
import os

# Add the app directory to sys.path
sys.path.append(os.path.join(os.getcwd(), 'doctorportel', 'backend'))

from app.services.ai_service import generate_text

async def main():
    print("Testing AI Fallback Service...")
    prompt = "Hello, can you give me a very brief medical advice for a common cold?"
    
    print("\nAttempting generation...")
    result = await generate_text(prompt)
    
    print("\nResult:")
    print("-" * 50)
    print(result)
    print("-" * 50)

if __name__ == "__main__":
    asyncio.run(main())
