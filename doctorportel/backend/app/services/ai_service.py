import json
import logging
from openai import AsyncOpenAI
import os

logger = logging.getLogger(__name__)

# Hardcoded API Key for hackathon phase as requested
NVIDIA_API_KEY = "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"
NVIDIA_BASE_URL = "https://integrate.api.nvidia.com/v1"
MODEL_NAME = "moonshotai/kimi-k2.5" # Make sure this matches the API model name

client = AsyncOpenAI(
    base_url=NVIDIA_BASE_URL,
    api_key=NVIDIA_API_KEY
)

async def generate_text(prompt: str, system_prompt: str = "You are a helpful AI medical assistant.", temperature: float = 0.7) -> str:
    """
    Generate text using NVIDIA Moonshot kimi-k2.5 model
    """
    try:
        response = await client.chat.completions.create(
            model=MODEL_NAME,
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": prompt}
            ],
            temperature=temperature,
            max_tokens=1024,
        )
        return response.choices[0].message.content.strip()
    except Exception as e:
        logger.error(f"Error calling NVIDIA API: {e}")
        return f"Error connecting to AI service: {str(e)}"

async def generate_json(prompt: str, system_prompt: str = "You are a helpful AI assistant. Always return pure JSON.", temperature: float = 0.5) -> dict:
    """
    Generate JSON response from NVIDIA model
    """
    system_prompt += "\nRespond ONLY with valid JSON without markdown formatting like ```json ... ```."
    try:
        response = await client.chat.completions.create(
            model=MODEL_NAME,
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": prompt}
            ],
            temperature=temperature,
            max_tokens=2048,
        )
        content = response.choices[0].message.content.strip()
        
        # Clean up any potential markdown formatting
        if content.startswith("```json"):
            content = content[7:]
        if content.startswith("```"):
            content = content[3:]
        if content.endswith("```"):
            content = content[:-3]
            
        return json.loads(content.strip())
    except Exception as e:
        logger.error(f"Error generating JSON with NVIDIA API: {e}")
        return {"error": str(e), "raw_content": locals().get("content", "")}

