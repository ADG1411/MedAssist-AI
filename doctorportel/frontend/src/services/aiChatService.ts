import type { ChatMessage } from '../types/chat';

/**
 * AI Chat Service — Direct NIM API integration
 * No Python backend required. Calls NVIDIA NIM API directly.
 */

type SearchMode = 'auto' | 'offline' | 'online';

const NIM_BASE_URL = '/nim-api';
const NIM_API_KEY = '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';
const MODEL = 'stepfun-ai/step-3.5-flash';

const SYSTEM_PROMPT = `You are Dr. AI Co-Pilot, an expert clinical AI assistant integrated into a Doctor Portal (MedAssist AI).

You help doctors with:
- Patient case analysis & differential diagnosis
- Prescription drafting & drug interaction checks
- Clinical schedule management & workflow optimization
- Medical knowledge queries & evidence-based recommendations
- Lab report interpretation & follow-up planning

Communication style:
- Professional, precise medical language
- Reference evidence-based medicine
- Structure complex answers with headers and bullet points
- Always mention when something requires in-person clinical judgment
- Use markdown formatting for clarity`;

export const sendChatMessage = async (
  message: string,
  history: ChatMessage[] = [],
  images?: string[],
  _searchMode: SearchMode = 'auto'
): Promise<ChatMessage> => {
  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), 25000);

  try {
    // Build message array with history context
    const messages: Array<{ role: string; content: string | any[] }> = [
      { role: 'system', content: SYSTEM_PROMPT },
    ];

    // Add last 8 messages as conversation context
    const recentHistory = history.slice(-8);
    for (const msg of recentHistory) {
      messages.push({
        role: msg.role === 'user' ? 'user' : 'assistant',
        content: msg.content,
      });
    }

    // Current user message
    if (images && images.length > 0) {
      const contentArray: any[] = [{ type: 'text', text: message }];
      for (const b64 of images) {
        contentArray.push({
          type: 'image_url',
          image_url: { url: b64 },
        });
      }
      messages.push({ role: 'user', content: contentArray });
    } else {
      messages.push({ role: 'user', content: message });
    }

    const response = await fetch(`${NIM_BASE_URL}/chat/completions`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${NIM_API_KEY}`,
      },
      body: JSON.stringify({
        model: MODEL,
        messages,
        temperature: 0.7,
        max_tokens: 4096,
      }),
      signal: controller.signal,
    });

    clearTimeout(timeoutId);

    if (!response.ok) {
      const errText = await response.text().catch(() => '');
      throw new Error(`NIM API error ${response.status}: ${errText.substring(0, 200)}`);
    }

    const data = await response.json();
    const content = data.choices?.[0]?.message?.content || "I couldn't generate a response. Please try again.";

    return {
      id: crypto.randomUUID(),
      role: 'assistant',
      content,
      timestamp: new Date().toISOString(),
    };
  } catch (error: any) {
    clearTimeout(timeoutId);
    console.error('AI Chat Error:', error);

    const errorMsg =
      error.name === 'AbortError'
        ? 'The request timed out. The AI model might be busy — please try again in a moment.'
        : `AI service error: ${error.message || 'Unknown error'}. Please try again.`;

    return {
      id: crypto.randomUUID(),
      role: 'assistant',
      content: errorMsg,
      timestamp: new Date().toISOString(),
    };
  }
};

export const searchOnline = async (
  query: string
): Promise<{ text: string; sources: string[] }> => {
  try {
    const response = await fetch(`${NIM_BASE_URL}/chat/completions`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${NIM_API_KEY}`,
      },
      body: JSON.stringify({
        model: MODEL,
        messages: [
          {
            role: 'system',
            content:
              'You are a medical search assistant. Provide evidence-based answers with source references where possible. Format with markdown.',
          },
          { role: 'user', content: `Medical search query: ${query}` },
        ],
        temperature: 0.4,
        max_tokens: 2048,
      }),
    });

    if (!response.ok) throw new Error(`Search failed: ${response.status}`);

    const data = await response.json();
    const text = data.choices?.[0]?.message?.content || 'No results found.';

    return { text, sources: [] };
  } catch (error) {
    console.error('Search Error:', error);
    return {
      text: 'Failed to search. Please check your connection.',
      sources: [],
    };
  }
};