import type { ChatMessage } from '../types/chat';

const BACKEND_URL = (import.meta as any).env?.VITE_API_URL || 'http://localhost:8000';

export const sendChatMessage = async (
  message: string, 
  history: ChatMessage[] = [],
  images?: string[]
): Promise<ChatMessage> => {
  try {
    const res = await fetch(`${BACKEND_URL}/api/v1/chat/`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        message,
        context: { history },
        images: images || []
      })
    });

    if (!res.ok) throw new Error("Network response was not ok");

    const data = await res.json();
    
    return {
      id: crypto.randomUUID(),
      role: 'assistant',
      content: data.text || "Sorry, I couldn't understand that.",
      timestamp: new Date().toISOString(),
      action: data.action !== 'none' ? data.action : undefined,
      data_payload: data.payload || undefined
    };
  } catch (error) {
    console.error("Chat Error:", error);
    return {
      id: crypto.randomUUID(),
      role: 'assistant',
      content: "I'm having trouble connecting to the backend. Please ensure the server is running.",
      timestamp: new Date().toISOString()
    };
  }
};