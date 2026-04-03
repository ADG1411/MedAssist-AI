import json
import logging
import asyncio
from openai import AsyncOpenAI
import os
import httpx

logger = logging.getLogger(__name__)

# NVIDIA Build Configurations
NVIDIA_BASE_URL = "https://integrate.api.nvidia.com/v1"

# Primary Model: Step-3.5-Flash (from StepFun)
API_KEY = "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"
MODEL_NAME = "stepfun-ai/step-3.5-flash"

client = AsyncOpenAI(
    base_url=NVIDIA_BASE_URL,
    api_key=API_KEY,
    http_client=httpx.AsyncClient(timeout=30.0)
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


async def _call_with_retry(messages, temperature: float, max_tokens: int, retries: int = 1):
    """Call the AI model with automatic retry on failure."""
    last_error = None
    for attempt in range(retries + 1):
        try:
            response = await client.chat.completions.create(
                model=MODEL_NAME,
                messages=messages,
                temperature=temperature,
                max_tokens=max_tokens,
            )
            content = response.choices[0].message.content
            return content
        except Exception as e:
            last_error = e
            if attempt < retries:
                logger.warning(f"AI call attempt {attempt + 1} failed: {e}. Retrying...")
                await asyncio.sleep(1)
            else:
                logger.error(f"AI model ({MODEL_NAME}) failed after {retries + 1} attempts: {e}")
    raise last_error


async def generate_text(prompt: str, system_prompt: str = "You are a helpful AI medical assistant.", temperature: float = 0.7, images: list[str] = None) -> str:
    """Generate text using Step-3.5-Flash model with retry logic."""
    messages = _build_messages(prompt, system_prompt, images)
    
    try:
        content = await _call_with_retry(messages, temperature, 1024)
        if content:
            return content.strip()
        return ""
    except Exception as e:
        return f"Error connecting to AI service: {str(e)}"


async def generate_json(prompt: str, system_prompt: str = "You are a helpful AI assistant. Always return pure JSON.", temperature: float = 0.5, images: list[str] = None) -> dict:
    """Generate JSON response using Step-3.5-Flash with retry logic."""
    full_system_prompt = system_prompt + "\nRespond ONLY with valid JSON without markdown formatting like ```json ... ```."
    messages = _build_messages(prompt, full_system_prompt, images)
    
    content = ""
    
    try:
        content = await _call_with_retry(messages, temperature, 2048)
        if content is None:
            content = "{}"
        content = content.strip()
    except Exception as e:
        return {"error": str(e)}

    # Clean up JSON formatting
    if content.startswith("```json"):
        content = content[7:]
    if content.startswith("```"):
        content = content[3:]
    if content.endswith("```"):
        content = content[:-3]
        
    try:
        if not content:
            return {}
        return json.loads(content.strip())
    except Exception as e:
        logger.error(f"JSON Parse Error: {e}. Content: {content[:100]}...")
        return {"error": "Invalid JSON format", "raw_content": content}


async def generate_with_context(
    user_message: str,
    local_context: str = "",
    system_prompt: str = "You are an expert AI medical assistant integrated into a Doctor Portal.",
    temperature: float = 0.7,
    images: list[str] = None
) -> str:
    """
    Generate a response with injected local data context (offline mode).
    The local_context string contains patient records, appointment info, etc.
    from the data_context_service.
    """
    full_prompt = (
        f"LOCAL DATABASE CONTEXT:\n"
        f"---\n{local_context}\n---\n\n"
        f"Doctor's Question: {user_message}\n\n"
        f"Answer the doctor's question using the local database context above. "
        f"Be precise, professional, and reference specific patient data when relevant. "
        f"If the data doesn't contain the answer, say so clearly."
    )
    
    return await generate_text(full_prompt, system_prompt, temperature, images)
