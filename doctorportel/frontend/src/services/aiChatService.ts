import type { ChatMessage } from '../types/chat';

export const sendChatMessage = async (
  message: string, 
  _history: ChatMessage[] = []
): Promise<ChatMessage> => {
  // Mocking the AI Assistant responses based on keywords in the message
  // This ensures the frontend features work smoothly without needing a backend.
  
  return new Promise((resolve) => {
    setTimeout(() => {
      const msg = message.toLowerCase();
      let response: ChatMessage = {
        id: crypto.randomUUID(),
        role: 'assistant',
        content: "I am your Doctor Portal AI Assistant. I can help you fetch patient records, schedule appointments, generate prescriptions, or analyze reports. How can I assist you today?",
        timestamp: new Date().toISOString()
      };

      if (msg.includes('appointment') || msg.includes('schedule')) {
        response = {
          ...response,
          content: "Here are your appointments for today. You have 4 patients lined up.",
          action: "show_appointments",
          data_payload: [
            { id: "1", patient: "Emma Watson", time: "10:00 AM", status: "Waiting" },
            { id: "2", patient: "John Doe", time: "11:30 AM", status: "In Progress" },
            { id: "3", patient: "Sarah Smith", time: "02:00 PM", status: "Confirmed" },
            { id: "4", patient: "Michael Brown", time: "04:15 PM", status: "Confirmed" }
          ]
        };
      } else if (msg.includes('critical') || msg.includes('alert') || msg.includes('sos')) {
        response = {
          ...response,
          content: "I found 1 active critical case requiring immediate attention.",
          action: "show_critical",
          data_payload: [
            { id: "101", patient: "Michael Johnson", condition: "Severe Chest Pain", status: "Critical" }
          ]
        };
      } else if (msg.includes('prescription')) {
        response = {
          ...response,
          content: "I've generated a draft prescription for the patient based on common protocols.",
          action: "generate_prescription",
          data_payload: {
            diagnosis: "Viral Fever",
            medicines: [
              { name: "Paracetamol 500mg", dosage: "1 tablet", frequency: "Every 8 hours", duration: "3 days" },
              { name: "Vitamin C", dosage: "1 tablet", frequency: "Once daily", duration: "5 days" }
            ]
          }
        };
      } else if (msg.includes('history') || msg.includes('suresh')) {
        response = {
          ...response,
          content: "Here is the timeline and patient history for Suresh Patel.",
          action: "show_history",
          data_payload: {
            patient: "Suresh Patel",
            history: [
              { date: "2026-01-15", event: "Diagnosed with Type 2 Diabetes" },
              { date: "2026-03-10", event: "Routine Blood Test - HB1Ac normal" }
            ]
          }
        };
      }

      resolve(response);
    }, 1200); // simulate network delay
  });
};