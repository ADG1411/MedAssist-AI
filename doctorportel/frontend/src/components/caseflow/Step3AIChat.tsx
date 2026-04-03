import { useState, useRef, useEffect } from 'react';
import { Send, Bot, User, Sparkles, Zap } from 'lucide-react';
import { cn } from '../../layouts/DashboardLayout';
import type { CaseFlowState, ChatMessage } from '../../types/caseflow';

const fmtTime = () => new Date().toLocaleTimeString('en-IN', { hour: '2-digit', minute: '2-digit' });

const QUICK_ACTIONS = [
  'What is the patient age?',
  'Show past medical history',
  'What is the AI risk score?',
  'List known allergies',
  'What surgery is needed?',
  'Estimated treatment cost?',
];

/* ── AI response generator ─────────────────────────────────────────────────── */
function generateAIResponse(query: string, data: CaseFlowState): ChatMessage {
  const { patient } = data;
  const q = query.toLowerCase();

  let content = '';
  let type: ChatMessage['type'] = 'text';
  let cardData: Record<string, string> | undefined;

  if (q.includes('age') || q.includes('gender')) {
    type = 'card';
    content = `Patient demographics retrieved.`;
    cardData = { Age: `${patient.age} years`, Gender: patient.gender, 'Blood Group': patient.bloodGroup, DOB: patient.birthDate };
  } else if (q.includes('histor') || q.includes('past')) {
    content = `**Medical History for ${patient.name}:**\n${patient.medicalHistory.map(h => `• ${h}`).join('\n')}`;
  } else if (q.includes('risk') || q.includes('score') || q.includes('ai')) {
    type = 'card';
    content = `AI risk assessment complete.`;
    cardData = { 'AI Score': `${patient.aiScore}/100`, Level: patient.aiScore >= 76 ? 'High 🔴' : patient.aiScore >= 41 ? 'Medium 🟡' : 'Low 🟢', Urgency: patient.urgency, Source: patient.source };
  } else if (q.includes('allerg')) {
    content = patient.allergies.length > 0
      ? `⚠️ **Known Allergies:**\n${patient.allergies.map(a => `• ${a}`).join('\n')}\n\n*Please ensure medication compatibility before prescribing.*`
      : `✅ No known allergies documented for ${patient.name}.`;
  } else if (q.includes('surg') || q.includes('procedure')) {
    type = 'card';
    content = `Procedure details retrieved.`;
    cardData = { Procedure: patient.procedure, Urgency: patient.urgency, 'Est. Cost': `₹${(patient.costMin/1000).toFixed(0)}k – ${(patient.costMax/1000).toFixed(0)}k`, Status: patient.status };
  } else if (q.includes('cost') || q.includes('price') || q.includes('estimat')) {
    type = 'card';
    content = `Cost estimation for ${patient.procedure}:`;
    cardData = { 'Min Cost': `₹${patient.costMin.toLocaleString('en-IN')}`, 'Max Cost': `₹${patient.costMax.toLocaleString('en-IN')}`, 'Payment Status': data.visit.paymentStatus, Source: patient.source };
  } else if (q.includes('diagnos')) {
    content = `**Current Diagnosis:**\n${patient.diagnosis}\n\nProcedure recommended: ${patient.procedure}`;
  } else {
    content = `I've reviewed the case for **${patient.name}** (${patient.reqId}). Based on the clinical data:\n\n• Age: ${patient.age} yrs, ${patient.gender}\n• Procedure: ${patient.procedure}\n• AI Risk Score: ${patient.aiScore}/100\n\nIs there anything specific you'd like to know about this case?`;
  }

  return {
    id: Date.now().toString(),
    role: 'ai',
    content,
    timestamp: fmtTime(),
    type,
    cardData,
  };
}

/* ── Message Bubble ─────────────────────────────────────────────────────────── */
const MessageBubble = ({ msg }: { msg: ChatMessage }) => {
  const isAI = msg.role === 'ai';
  return (
    <div className={cn('flex gap-3 animate-in fade-in slide-in-from-bottom-2 duration-300', isAI ? 'items-start' : 'items-start flex-row-reverse')}>
      <div className={cn('w-8 h-8 rounded-full flex items-center justify-center shrink-0 shadow-sm', isAI ? 'bg-teal-500' : 'bg-slate-700')}>
        {isAI ? <Bot className="w-4 h-4 text-white" /> : <User className="w-4 h-4 text-white" />}
      </div>
      <div className={cn('max-w-[80%] space-y-1', isAI ? '' : 'items-end flex flex-col')}>
        {msg.type === 'card' && msg.cardData ? (
          <div className="bg-white border border-slate-200 rounded-2xl p-4 shadow-sm space-y-1 min-w-[220px]">
            <p className="text-[11px] font-bold text-teal-600 uppercase tracking-wider mb-2 flex items-center gap-1.5">
              <Zap className="w-3 h-3" /> Quick Data Card
            </p>
            {Object.entries(msg.cardData).map(([k, v]) => (
              <div key={k} className="flex items-center justify-between gap-4 py-1.5 border-b border-slate-50 last:border-0">
                <span className="text-[11px] font-bold text-slate-400 uppercase tracking-widest">{k}</span>
                <span className="text-[13px] font-black text-slate-800">{v}</span>
              </div>
            ))}
          </div>
        ) : (
          <div className={cn(
            'px-4 py-3 rounded-2xl text-[13px] font-medium leading-relaxed whitespace-pre-line',
            isAI ? 'bg-white border border-slate-200 text-slate-700 shadow-sm rounded-tl-sm' : 'bg-slate-800 text-white rounded-tr-sm'
          )}>
            {msg.content.split('**').map((part, i) =>
              i % 2 === 1 ? <strong key={i} className="font-black">{part}</strong> : part
            )}
          </div>
        )}
        <p className={cn('text-[10px] font-medium text-slate-400 px-1', isAI ? '' : 'text-right')}>{msg.timestamp}</p>
      </div>
    </div>
  );
};

/* ── Step 3 – AI Assistant ──────────────────────────────────────────────────── */
export const Step3AIChat = ({ data, onMessagesChange }: { data: CaseFlowState; onMessagesChange: (msgs: ChatMessage[]) => void }) => {
  const [messages, setMessages] = useState<ChatMessage[]>(
    data.chatMessages.length > 0 ? data.chatMessages : [
      {
        id: '0', role: 'ai', timestamp: fmtTime(), type: 'text',
        content: `Hello, Doctor! 👋 I'm SanjivaniAI, ready to assist with the case for **${data.patient.name}** (${data.patient.reqId}).\n\nYou can ask me about patient history, risk assessment, procedures, allergies, or any clinical queries. Try a quick action below!`,
      },
    ]
  );
  const [input, setInput]     = useState('');
  const [typing, setTyping]   = useState(false);
  const bottomRef             = useRef<HTMLDivElement>(null);

  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages, typing]);

  const sendMessage = async (text: string) => {
    if (!text.trim()) return;
    const userMsg: ChatMessage = { id: Date.now().toString(), role: 'doctor', content: text, timestamp: fmtTime() };
    const updated = [...messages, userMsg];
    setMessages(updated);
    setInput('');
    setTyping(true);

    await new Promise(r => setTimeout(r, 900 + Math.random() * 600));

    const aiMsg = generateAIResponse(text, data);
    const final = [...updated, aiMsg];
    setMessages(final);
    onMessagesChange(final);
    setTyping(false);
  };

  return (
    <div className="flex flex-col h-[calc(100vh-360px)] min-h-[460px] bg-slate-50 rounded-2xl border border-slate-200 overflow-hidden animate-in fade-in slide-in-from-bottom-4 duration-300">

      {/* Header */}
      <div className="flex items-center gap-3 px-4 py-3 bg-white border-b border-slate-200 shrink-0">
        <div className="w-9 h-9 bg-teal-500 rounded-xl flex items-center justify-center shadow-sm shadow-teal-500/30">
          <Bot className="w-5 h-5 text-white" />
        </div>
        <div>
          <p className="font-black text-slate-800 text-[14px] leading-tight">SanjivaniAI Assistant</p>
          <p className="text-[11px] text-teal-500 font-bold flex items-center gap-1">
            <span className="w-1.5 h-1.5 bg-teal-400 rounded-full animate-pulse" /> Online · Case #{data.patient.reqId}
          </p>
        </div>
        <div className="ml-auto flex items-center gap-1.5 text-[11px] font-bold text-indigo-600 bg-indigo-50 border border-indigo-100 px-2.5 py-1 rounded-lg">
          <Sparkles className="w-3 h-3" /> AI Powered
        </div>
      </div>

      {/* Messages */}
      <div className="flex-1 overflow-y-auto custom-scrollbar p-4 space-y-4">
        {messages.map(msg => <MessageBubble key={msg.id} msg={msg} />)}
        {typing && (
          <div className="flex gap-3 items-start animate-in fade-in duration-200">
            <div className="w-8 h-8 rounded-full bg-teal-500 flex items-center justify-center shadow-sm">
              <Bot className="w-4 h-4 text-white" />
            </div>
            <div className="bg-white border border-slate-200 rounded-2xl rounded-tl-sm px-4 py-3 shadow-sm">
              <div className="flex gap-1.5 items-center h-4">
                {[0,1,2].map(i => (
                  <div key={i} className="w-2 h-2 bg-teal-400 rounded-full animate-bounce" style={{ animationDelay: `${i * 150}ms` }} />
                ))}
              </div>
            </div>
          </div>
        )}
        <div ref={bottomRef} />
      </div>

      {/* Quick Actions */}
      <div className="flex items-center gap-2 px-4 py-2 overflow-x-auto hide-scrollbar shrink-0 border-t border-slate-100 bg-white">
        {QUICK_ACTIONS.map(q => (
          <button key={q} onClick={() => sendMessage(q)}
            className="flex items-center gap-1.5 text-[11px] font-bold text-teal-600 bg-teal-50 border border-teal-100 px-3 py-1.5 rounded-xl whitespace-nowrap hover:bg-teal-100 transition-colors shrink-0">
            <Zap className="w-3 h-3" />{q}
          </button>
        ))}
      </div>

      {/* Input */}
      <div className="flex items-center gap-3 px-4 py-3 bg-white border-t border-slate-200 shrink-0">
        <input
          value={input}
          onChange={e => setInput(e.target.value)}
          onKeyDown={e => e.key === 'Enter' && !e.shiftKey && sendMessage(input)}
          placeholder="Ask about the patient…"
          className="flex-1 bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-[13px] font-medium outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-colors placeholder:text-slate-400"
        />
        <button
          onClick={() => sendMessage(input)}
          disabled={!input.trim() || typing}
          className="w-9 h-9 flex items-center justify-center bg-teal-500 hover:bg-teal-600 disabled:opacity-40 text-white rounded-xl transition-all active:scale-95 shadow-sm shadow-teal-500/30 shrink-0"
        >
          <Send className="w-4 h-4" />
        </button>
      </div>
    </div>
  );
};
