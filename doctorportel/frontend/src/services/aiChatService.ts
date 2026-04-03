import type { ChatMessage } from '../types/chat';

/**
 * AI Chat Service
 * Uses the Vite proxy (/api → localhost:8000) so it works in dev and production.
 */

type SearchMode = 'auto' | 'offline' | 'online';

export const sendChatMessage = async (
  message: string, 
  history: ChatMessage[] = [],
  images?: string[],
  searchMode: SearchMode = 'auto'
): Promise<ChatMessage> => {
  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), 20000); // 20s timeout

  const doFetch = async (attempt: number): Promise<ChatMessage> => {
    try {
      const res = await fetch(`/api/v1/chat/`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          message,
          context: { history: history.slice(-10) }, // last 10 messages for context
          images: images || [],
          search_mode: searchMode,
        }),
        signal: controller.signal,
      });

      clearTimeout(timeoutId);

      if (!res.ok) throw new Error(`Server responded with ${res.status}`);

      const data = await res.json();
      
      return {
        id: crypto.randomUUID(),
        role: 'assistant',
        content: data.text || "Sorry, I couldn't understand that.",
        timestamp: new Date().toISOString(),
        action: data.action !== 'none' ? data.action : undefined,
        data_payload: data.payload || undefined,
      };
    } catch (error: any) {
      // Retry once on network error (not abort)
      if (attempt === 0 && error.name !== 'AbortError') {
        console.warn("Chat request failed, retrying...", error);
        await new Promise(r => setTimeout(r, 1000));
        return doFetch(1);
      }

      clearTimeout(timeoutId);
      console.error("Chat Error:", error);
      
      const errorMsg = error.name === 'AbortError'
        ? "The request timed out. The AI server might be busy. Please try again."
        : "I'm having trouble connecting to the backend. Please ensure the server is running.";

      return {
        id: crypto.randomUUID(),
        role: 'assistant',
        content: errorMsg,
        timestamp: new Date().toISOString(),
      };
    }
  };

  return doFetch(0);
};


export const searchOnline = async (query: string): Promise<{ text: string; sources: string[] }> => {
  try {
    const res = await fetch(`/api/v1/chat/search`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ query }),
    });

    if (!res.ok) throw new Error(`Server responded with ${res.status}`);

    const data = await res.json();
    return {
      text: data.text || "No results found.",
      sources: data.sources || [],
    };
  } catch (error) {
    console.error("Search Error:", error);
    return {
      text: "Failed to search the internet. Please check your connection.",
      sources: [],
    };
  }
};