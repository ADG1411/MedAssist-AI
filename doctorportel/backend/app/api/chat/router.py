from fastapi import APIRouter
from pydantic import BaseModel
from typing import Optional, Dict, Any, List

router = APIRouter()

class ChatMessage(BaseModel):
    message: str
    context: Optional[Dict[str, Any]] = None
    images: Optional[List[str]] = None
    search_mode: Optional[str] = "auto"  # "auto" | "offline" | "online"

class ChatResponse(BaseModel):
    text: str
    action: Optional[str] = None
    payload: Optional[Any] = None
    mode: Optional[str] = None  # tells frontend which mode was used

class SearchRequest(BaseModel):
    query: str

class SearchResponse(BaseModel):
    text: str
    sources: Optional[List[str]] = None

from app.services.ai_service import generate_json, generate_text, generate_with_context
from app.services.search_service import search_web
from app.services.data_context_service import (
    get_full_context,
    get_patient_context,
    get_patient_by_name,
    get_appointment_context,
)
import json


@router.post("/", response_model=ChatResponse)
async def process_chat_message(chat: ChatMessage):
    """
    Process incoming chat messages with intelligent offline/online routing.
    
    Modes:
    - "auto": AI classifies intent and decides whether to use local data or web search
    - "offline": Force use of local patient/appointment data only
    - "online": Force web search for the query
    """
    
    mode = chat.search_mode or "auto"
    
    # ── FORCED OFFLINE MODE ──
    if mode == "offline":
        local_context = get_full_context()
        text = await generate_with_context(
            user_message=chat.message,
            local_context=local_context,
            images=chat.images,
        )
        return ChatResponse(
            text=text or "I couldn't generate a response from the local data.",
            mode="offline",
        )
    
    # ── FORCED ONLINE MODE ──
    if mode == "online":
        internet_results = search_web(chat.message, max_results=5)
        synthesis_prompt = (
            f"You are a medical AI assistant. The doctor asked: '{chat.message}'.\n\n"
            f"Web search results:\n---\n{internet_results}\n---\n\n"
            "Write a helpful, structured response based on this data. "
            "Cite sources. Keep it professional and medically accurate."
        )
        text = await generate_text(synthesis_prompt, images=chat.images)
        return ChatResponse(
            text=text or "I couldn't find relevant information online.",
            mode="online",
        )
    
    # ── AUTO MODE: AI classifies intent ──
    system_prompt_intent = (
        "You are an AI assistant integrated into a Doctor's Portal. "
        "The user will ask you something related to their medical practice: viewing appointments, "
        "checking critical cases, generating prescriptions, checking patient history, or getting a daily summary. "
        "If they ask a general medical/knowledge question or ask you to fetch data from the internet, classify as 'search_web'. "
        "If they ask about their own patients, appointments, schedule, or practice data, classify as 'local_data'. "
        "Classify the intent into one of the following actions: "
        "'show_appointments', 'show_critical', 'generate_prescription', 'show_history', "
        "'show_summary', 'search_web', 'local_data', or 'none'.\n\n"
        "Return a JSON object with:\n"
        "- 'text': A conversational, professional reply.\n"
        "- 'action': The selected action string (or null if 'none').\n"
        "- 'search_query': If intent is 'search_web', provide a short optimal web search query. null otherwise.\n"
        "- 'patient_name': If the user asks about a specific patient, extract their name. null otherwise.\n"
        "- 'payload': Appropriate mock data (array or object) related to the action, or null.\n"
        "Ensure the JSON is strictly structured."
    )
    
    prompt = f"Message: {chat.message}\nContext: {json.dumps(chat.context) if chat.context else '{}'}"
    
    aiResponse = await generate_json(prompt, system_prompt_intent, images=chat.images)
    
    if "error" in aiResponse:
        return ChatResponse(
            text="I'm having trouble connecting to my cognitive services right now. How else can I assist?",
            mode="auto",
        )
        
    action = aiResponse.get("action")
    text = aiResponse.get("text", "")
    
    # ── Handle Web Search ──
    if action == "search_web" and aiResponse.get("search_query"):
        search_query = aiResponse.get("search_query")
        internet_results = search_web(search_query)
        
        synthesis_prompt = (
            f"You are a medical AI assistant. The user asked: '{chat.message}'.\n\n"
            f"I fetched the following data from the internet:\n---\n{internet_results}\n---\n\n"
            "Write a helpful, structured response directly addressing the user's question based on this data. "
            "Cite sources appropriately and keep it professional. Do not use JSON."
        )
        final_answer = await generate_text(synthesis_prompt, images=chat.images)
        text = final_answer
        action = "none"
        return ChatResponse(text=text, action=None, payload=None, mode="online")
    
    # ── Handle Local Data Queries ──
    if action == "local_data" or action in ("show_appointments", "show_critical", "show_history", "show_summary"):
        patient_name = aiResponse.get("patient_name")
        
        if patient_name:
            local_context = get_patient_by_name(patient_name)
        elif action == "show_appointments":
            local_context = get_appointment_context()
        else:
            local_context = get_full_context()
        
        enriched_text = await generate_with_context(
            user_message=chat.message,
            local_context=local_context,
            images=chat.images,
        )
        
        return ChatResponse(
            text=enriched_text or text,
            action=action if action not in ("local_data", "none") else None,
            payload=aiResponse.get("payload"),
            mode="offline",
        )
    
    return ChatResponse(
        text=text if text else "I can help you fetch patient records, schedule appointments, or generate prescriptions.",
        action=action if action != "none" else None,
        payload=aiResponse.get("payload"),
        mode="auto",
    )


@router.post("/search", response_model=SearchResponse)
async def search_online(req: SearchRequest):
    """Explicit web search endpoint for the AI assistant's online mode."""
    internet_results = search_web(req.query, max_results=5)
    
    synthesis_prompt = (
        f"You are a medical AI assistant. The doctor asked: '{req.query}'.\n\n"
        f"Web search results:\n---\n{internet_results}\n---\n\n"
        "Write a helpful, structured response based on this data. "
        "Cite sources. Be professional and medically accurate."
    )
    text = await generate_text(synthesis_prompt)
    
    return SearchResponse(
        text=text or "I couldn't find relevant information.",
        sources=[line.split("(")[1].split(")")[0] for line in internet_results.split("\n\n") if "(" in line][:5]
    )
