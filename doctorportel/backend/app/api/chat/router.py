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
    
    # â”€â”€ FORCED OFFLINE MODE â”€â”€
    if mode == "offline":
        local_context = get_full_context()
        sys_guardrails = (
            "IMPORTANT GUARDRAILS:\n"
            "1. You MUST ONLY discuss topics related to the medical ecosystem, health, patient care, doctors, and MedAssist.\n"
            "2. If the user asks about non-medical topics (e.g., 'What is the capital of India?', sports, general trivia), you MUST refuse to answer and state you only assist with health-related topics.\n"
            "3. If the user provides an invalid number or nonsensical input, inform them the input is invalid.\n"
        )
        text = await generate_with_context(
            user_message=f"{sys_guardrails}\nUser Message: {chat.message}",
            local_context=local_context,
            images=chat.images,
        )
        return ChatResponse(
            text=text or "I couldn't generate a response from the local data.",
            mode="offline",
        )
    
    # â”€â”€ FORCED ONLINE MODE â”€â”€
    if mode == "online":
        internet_results = search_web(chat.message, max_results=5)
        synthesis_prompt = (
            "CRITICAL GUARDRAILS: You are restricted to medical, healthcare, and patient-centric conversations ONLY. "
            "If the user query is outside this scope (e.g. asking for capitals, sports) or is an invalid number, "
            "respond that you only assist with medical ecosystem inquiries. Do NOT provide the answer to out-of-scope questions even if search results have it.\n\n"
            f"The doctor asked: '{chat.message}'.\n\n"
            f"Web search results:\n---\n{internet_results}\n---\n\n"
            "If the query is medical, write a helpful response based on the data. "
            "If it is NOT medical, just output a polite refusal."
        )
        text = await generate_text(synthesis_prompt, images=chat.images)
        return ChatResponse(
            text=text or "I couldn't find relevant information online.",
            mode="online",
        )
    
    # ── AUTO MODE: AI classifies intent ──
    # 🛑 1. LENGTH GUARDRAIL
    if len(chat.message.strip()) < 3:
        return ChatResponse(
            text="Please ask a complete medical question.",
            action=None,
            mode="auto"
        )
        
    # 🛑 2. AI CLASSIFIER (STRICT)
    is_med_prompt = (
        "You are a strict classifier.\n"
        "ONLY answer:\n"
        "YES -> if question is medical/health related\n"
        "NO -> if not\n"
        "No explanation.\n\n"
        f"Question: {chat.message}"
    )
    is_med_check = await generate_text(is_med_prompt)
    if "no" in (is_med_check or "").lower():
        return ChatResponse(
            text="⚠ I am a medical AI. Please ask health-related questions only.",
            action=None,
            mode="auto"
        )

    # 🚀 3. MAIN AI WITH HARD RESTRICTION
    system_prompt_intent = (
        "You are MedAssist AI.\n\n"
        "STRICT RULES:\n"
        "- Only answer medical/health questions\n"
        "- If question is not medical → REFUSE\n\n"
        "Refusal format:\n"
        "\"I'm a medical assistant. I can only answer health-related questions.\"\n\n"
        "DO NOT answer anything outside healthcare.\n\n"
        "Analyze the user intent into one of the following actions:\n"
        "'show_appointments', 'show_critical', 'generate_prescription', 'show_history', "
        "'show_summary', 'search_web', 'local_data', or 'none'.\n\n"
        "Return a JSON object with:\n"
        "- 'text': A conversational reply (If out-of-scope, strictly decline here without answering).\n"
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

    # â”€â”€ Handle Web Search â”€â”€
    if action == "search_web" and aiResponse.get("search_query"):
        search_query = aiResponse.get("search_query")

        internet_results = search_web(search_query)

        synthesis_prompt = (
            "CRITICAL GUARDRAILS: You are restricted to medical, healthcare, and patient-centric conversations ONLY. "
            "If the user's query is outside this scope or is an invalid number/gibberish, "
            "you MUST decline answering. Do NOT provide the answer to their out-of-scope question, even if the web search results contain it.\n\n"
            f"The user asked: '{chat.message}'.\n\n"
            f"Web search results:\n---\n{internet_results}\n---\n\n"
            "If the query is primarily medical, write a helpful response based on the data, citing sources and keeping it professional. "
            "If it is NOT medical, strictly output ONLY this exact phrase: 'I am a medical assistant. I can only assist you with health, medical ecosystem, and patient-related queries.'"
        )
        final_answer = await generate_text(synthesis_prompt, images=chat.images)
        text = final_answer
        action = "none"
        return ChatResponse(text=text, action=None, payload=None, mode="online")
    
    # â”€â”€ Handle Local Data Queries â”€â”€
    if action == "local_data" or action in ("show_appointments", "show_critical", "show_history", "show_summary"):
        patient_name = aiResponse.get("patient_name")
        
        if patient_name:
            local_context = get_patient_by_name(patient_name)
        elif action == "show_appointments":
            local_context = get_appointment_context()
        else:
            local_context = get_full_context()
        
        sys_guardrails = (
            "IMPORTANT GUARDRAIL: You are restricted entirely to healthcare, patient data, and medical ecosystem contexts. "
            "If the user asks an unrelated general question or inputs invalid data/numbers, gently decline to answer and offer health assistance."
        )

        enriched_text = await generate_with_context(
            user_message=f"{sys_guardrails}\nUser Message: {chat.message}",
            context_data=local_context
        )
        text = enriched_text
    
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
        "CRITICAL GUARDRAILS: You are a medical AI assistant restricted to medical, healthcare, and patient-centric conversations ONLY. "
        "If the user's query is outside this scope (e.g., asking for capitals, sports) or is an invalid number, "
        "you MUST decline answering. Do NOT provide the answer to out-of-scope questions even if the search results have it. "
        f"The doctor asked: '{req.query}'.\n\n" 
        f"Web search results:\n---\n{internet_results}\n---\n\n"
        "If the query is medical, write a helpful, structured response based on this data, citing sources, and being professional. "
        "If it is NOT medical, output a polite refusal stating you only assist with the health ecosystem."
    )





class ValidateRequest(BaseModel):
    message: str

class ValidateResponse(BaseModel):
    isMedical: str

@router.post("/validate", response_model=ValidateResponse)
async def validate_query(req: ValidateRequest):
    """Live typing validation endpoint to check if query is medical."""
    if len(req.message.strip()) < 3:
        return ValidateResponse(isMedical="YES") # Allow short inputs during typing

    classification_prompt = (
        "You are a strict classifier.\n"
        "ONLY answer:\n"
        "YES -> if question is medical/health related\n"
        "NO -> if not\n"
        "No explanation.\n\n"
        f"Question: {req.message}"
    )
    is_med_check = await generate_text(classification_prompt)
    if "no" in (is_med_check or "").lower():
        return ValidateResponse(isMedical="NO")
    return ValidateResponse(isMedical="YES")
