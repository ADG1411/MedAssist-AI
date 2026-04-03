import ReactMarkdown from 'react-markdown';
import { Bot, User } from 'lucide-react';
import { cn } from '../../layouts/DashboardLayout';
import type { ChatMessage } from '../../types/chat';
import { AIResponseCard } from './AIResponseCard';

interface Props {
  message: ChatMessage;
}

export const MessageBubble = ({ message }: Props) => {
  const isBot = message.role === 'assistant';

  return (
    <div className={cn(
      "flex w-full mt-2 space-x-4 max-w-3xl mx-auto group",
      isBot ? "self-start" : "ml-auto justify-end"
    )}>
      {isBot && (
        <div className="flex-shrink-0 h-9 w-9 rounded-2xl bg-gradient-to-br from-indigo-500 to-cyan-400 flex items-center justify-center shadow-lg shadow-indigo-200 mt-1">
          <Bot className="h-5 w-5 text-white" />
        </div>
      )}

      <div className={cn(
        "flex flex-col space-y-2 text-[15px] max-w-[85%]",
        isBot ? "items-start" : "items-end"
      )}>
        <div className={cn(
          "px-5 py-3.5 leading-relaxed whitespace-pre-wrap shadow-sm",
          isBot 
            ? "bg-white text-slate-700 border border-slate-200/60 rounded-2xl rounded-tl-sm prose prose-slate max-w-none" 
            : "bg-slate-900 text-white rounded-2xl rounded-tr-sm"
        )}>
          {isBot ? (
            <div className="w-full">
              <ReactMarkdown>
                {message.content}
              </ReactMarkdown>
            </div>
          ) : (
            <span>{message.content}</span>
          )}
        </div>

        {isBot && message.data_payload && message.action && (
          <div className="w-full mt-3 animate-in slide-in-from-bottom-2 fade-in duration-300">
            <AIResponseCard action={message.action} payload={message.data_payload} />
          </div>
        )}
        
        <span className="text-[11px] text-slate-400 font-medium px-2 opacity-0 group-hover:opacity-100 transition-opacity">
          {new Date(message.timestamp).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
        </span>
      </div>

      {!isBot && (
        <div className="flex-shrink-0 h-9 w-9 rounded-2xl bg-slate-100 border border-slate-200 flex items-center justify-center mt-1 text-slate-600">
          <User className="h-4 w-4" />
        </div>
      )}
    </div>
  );
};