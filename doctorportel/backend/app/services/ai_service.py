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

def _build_messages(prompt: str, system_prompt: str, images: list[str] = None):
    messages = [
        {"role": "system", "content": system_prompt}
    ]
    if images and len(images) > 0:
        content_array = [{"type": "text", "text": prompt}]
        for b64 in images:
            content_array.append({
                "type": "image_url",
                "image_url": {"url": b64}
            })
        messages.append({"role": "user", "content": content_array})
    else:
        messages.append({"role": "user", "content": prompt})
    return messages

async def generate_text(prompt: str, system_prompt: str = "You are a helpful AI medical assistant.", temperature: float = 0.7, images: list[str] = None) -> str:
    """
    Generate text using NVIDIA Moonshot kimi-k2.5 model
    """
    try:
        response = await client.chat.completions.create(
            model=MODEL_NAME,
            messages=_build_messages(prompt, system_prompt, images),
            temperature=temperature,
            max_tokens=1024,
        )
        return response.choices[0].message.content.strip()
    except Exception as e:
        logger.error(f"Error calling NVIDIA API: {e}")
        return f"Error connecting to AI service: {str(e)}"

async def generate_json(prompt: str, system_prompt: str = "You are a helpful AI assistant. Always return pure JSON.", temperature: float = 0.5, images: list[str] = None) -> dict:
    """
    Generate JSON response from NVIDIA model
    """
    system_prompt += "\nRespond ONLY with valid JSON without markdown formatting like ```json ... ```."
    try:
        response = await client.chat.completions.create(
            model=MODEL_NAME,
            messages=_build_messages(prompt, system_prompt, images),
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

