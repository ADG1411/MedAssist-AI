from fastapi import APIRouter
from pydantic import BaseModel
from typing import Optional, Dict, Any, List

router = APIRouter()

class ChatMessage(BaseModel):
    message: str
    context: Optional[Dict[str, Any]] = None

class ChatResponse(BaseModel):
    text: str
    action: Optional[str] = None
    payload: Optional[Any] = None

from app.services.ai_service import generate_json
import json

@router.post("/", response_model=ChatResponse)
async def process_chat_message(chat: ChatMessage):
    """
    Process incoming chat messages using Moonshot AI to classify intent and
    return smart text and structured payloads for the Doctor portal UI.
    """
    
    system_prompt = (
        "You are an AI assistant integrated into a Doctor's Portal. "
        "The user will ask you something related to their medical practice: viewing appointments, "
        "checking critical cases, generating prescriptions, checking patient history, or getting a daily summary. "
        "Classify the intent into one of the following actions: "
        "'show_appointments', 'show_critical', 'generate_prescription', 'show_history', 'show_summary', or 'none'.\n\n"
        "Return a JSON object with: \n"
        "- 'text': A conversational, professional reply.\n"
        "- 'action': The selected action string (or null if 'none').\n"
        "- 'payload': Appropriate mock data (array or object) related to the action if an action is selected, or null.\n"
        "Ensure the JSON is strictly structured."
    )
    
    prompt = f"Message: {chat.message}\nContext: {json.dumps(chat.context) if chat.context else '{}'}"
    
    aiResponse = await generate_json(prompt, system_prompt)
    if "error" in aiResponse:
         return ChatResponse(
            text="I'm having trouble connecting to my cognitive services right now. How else can I assist?",
        )
    
    return ChatResponse(
        text=aiResponse.get("text", "I can help you fetch patient records, schedule appointments, or generate prescriptions."),
        action=aiResponse.get("action"),
        payload=aiResponse.get("payload")
    )

