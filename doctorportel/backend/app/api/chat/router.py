from fastapi import APIRouter
from pydantic import BaseModel
from typing import Optional, Dict, Any, List

router = APIRouter()

class ChatMessage(BaseModel):
    message: str
    context: Optional[Dict[str, Any]] = None
    images: Optional[List[str]] = None

class ChatResponse(BaseModel):
    text: str
    action: Optional[str] = None
    payload: Optional[Any] = None

from app.services.ai_service import generate_json, generate_text
from app.services.search_service import search_web
import json

@router.post("/", response_model=ChatResponse)
async def process_chat_message(chat: ChatMessage):
    """
    Process incoming chat messages using Moonshot AI to classify intent and
    return smart text and structured payloads for the Doctor portal UI.
    """
    
    system_prompt_intent = (
        "You are an AI assistant integrated into a Doctor's Portal. "
        "The user will ask you something related to their medical practice: viewing appointments, "
        "checking critical cases, generating prescriptions, checking patient history, or getting a daily summary. "
        "If they ask a general medical/knowledge question or ask you to fetch data from the internet, classify as 'search_web'. "
        "Classify the intent into one of the following actions: "
        "'show_appointments', 'show_critical', 'generate_prescription', 'show_history', 'show_summary', 'search_web', or 'none'.\n\n"
        "Return a JSON object with: \n"
        "- 'text': A conversational, professional reply (leave empty if 'search_web', or explain what you will search).\n"
        "- 'action': The selected action string (or null if 'none').\n"
        "- 'search_query': If intent is 'search_web', provide a short optimal web search query for DuckDuckGo. null otherwise.\n"
        "- 'payload': Appropriate mock data (array or object) related to the action if an action is selected, or null.\n"
        "Ensure the JSON is strictly structured."
    )
    
    prompt = f"Message: {chat.message}\nContext: {json.dumps(chat.context) if chat.context else '{}'}"
    
    aiResponse = await generate_json(prompt, system_prompt_intent, images=chat.images)
    
    if "error" in aiResponse:
         return ChatResponse(
            text="I'm having trouble connecting to my cognitive services right now. How else can I assist?",
        )
        
    action = aiResponse.get("action")
    text = aiResponse.get("text", "")
    
    # Handle Web Search Logic
    if action == "search_web" and aiResponse.get("search_query"):
        search_query = aiResponse.get("search_query")
        
        # 1. Fetch internet data
        internet_results = search_web(search_query)
        
        # 2. Re-summarize with LLM
        synthesis_prompt = (
            f"You are a medical AI assistant. The user asked: '{chat.message}'.\n\n"
            f"I fetched the following data from the internet for you:\n---\n{internet_results}\n---\n\n"
            "Write a helpful, structured response directly addressing the user's question based on this data. "
            "Cite sources appropriately and keep it professional. Do not use JSON."
        )
        final_answer = await generate_text(synthesis_prompt, images=chat.images)
        text = final_answer
        action = "none" # We just return the text, no frontend UI component needed for web search
    
    return ChatResponse(
        text=text if text else "I can help you fetch patient records, schedule appointments, or generate prescriptions.",
        action=action if action != 'none' else None,
        payload=aiResponse.get("payload")
    )


