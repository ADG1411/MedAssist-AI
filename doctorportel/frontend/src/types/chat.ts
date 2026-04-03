export interface ChatMessage {
  id: string;
  role: 'user' | 'assistant';
  content: string;
  timestamp: string;
  action?: string;
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  data_payload?: any;
}