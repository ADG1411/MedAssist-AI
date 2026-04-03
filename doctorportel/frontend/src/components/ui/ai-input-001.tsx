"use client";

import React, { useState, useRef, useEffect } from "react";
import { motion, AnimatePresence } from "motion/react";
import {
  Plus,
  Globe,
  ChevronDown,
  Send,
  Image as ImageIcon,
  FileText,
  Layers,
  Sparkles,
  Cpu,
  Zap,
  X,
} from "lucide-react";
import { LuBrain } from "react-icons/lu";
import { PiLightbulbFilament } from "react-icons/pi";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";

export interface Message {
  id: string;
  text?: string;
  sender: "user" | "ai";
  [key: string]: any;
}

interface Model {
  id: string;
  name: string;
  icon: React.ReactNode;
}

export interface Suggestion {
  id: string;
  label: string;
  sub: string;
  icon: React.ReactNode;
}

interface AIInputProps {
  messages?: Message[];
  renderMessage?: (msg: Message) => React.ReactNode;
  onSendMessage?: (text: string, modelId: string) => void;
  models?: Model[];
  suggestions?: Suggestion[];
  placeholder?: string;
  isLoading?: boolean;
}

const DEFAULT_MODELS: Model[] = [
  {
    id: "gpt-4o",
    name: "GPT-4o",
    icon: <PiLightbulbFilament className="h-4 w-4" />,
  },
  {
    id: "claude-3-5",
    name: "Claude 3.5 Sonnet",
    icon: <Sparkles className="h-4 w-4" />,
  },
  { id: "gemini-pro", name: "Gemini Pro", icon: <Cpu className="h-4 w-4" /> },
  { id: "llama-3-1", name: "Llama 3.1", icon: <Zap className="h-4 w-4" /> },
];

export const AiInput: React.FC<AIInputProps> = ({
  messages = [],
  renderMessage,
  onSendMessage = () => {},
  models = DEFAULT_MODELS,
  suggestions = [],
  placeholder = "Ask anything...",
  isLoading = false,
}) => {
  const hasMessages = messages.length > 0;
  const scrollRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (scrollRef.current) {
      scrollRef.current.scrollTop = scrollRef.current.scrollHeight;
    }
  }, [messages]);

  return (
    <div className="relative flex h-full w-full flex-col overflow-hidden bg-white">
      <MessageList messages={messages} scrollRef={scrollRef} isLoading={isLoading} renderMessage={renderMessage} />

      <ChatInput
        models={models}
        suggestions={suggestions}
        placeholder={placeholder}
        hasMessages={hasMessages}
        onSend={onSendMessage}
      />
    </div>
  );
};

const MessageList = ({
  messages,
  scrollRef,
  isLoading,
  renderMessage,
}: {
  messages: Message[];
  scrollRef: React.RefObject<HTMLDivElement | null>;
  isLoading?: boolean;
  renderMessage?: (msg: Message) => React.ReactNode;
}) => {
  if (!messages.length) return null;

  return (
    <div
      ref={scrollRef}
      className="z-10 flex w-full flex-1 flex-col items-center overflow-y-auto overflow-x-hidden pt-6 sm:pt-10 scrollbar-thin scrollbar-thumb-slate-200"
      style={{ scrollbarGutter: 'stable' }}
    >
      <div className="flex w-full max-w-3xl flex-col gap-4 px-3 pb-6 sm:px-4 sm:pb-10">
        <AnimatePresence initial={false}>
          {messages.map((msg) => (
            <motion.div
              key={msg.id}
              initial={{ opacity: 0, y: 10, scale: 0.95 }}
              animate={{ opacity: 1, y: 0, scale: 1 }}
              className="w-full"
            >
              {renderMessage ? (
                renderMessage(msg)
              ) : (
                <div className={`flex ${msg.sender === "user" ? "justify-end" : "justify-start"}`}>
                  <div
                    className={`max-w-[85%] rounded-2xl border px-3 py-2 text-sm font-medium shadow-sm sm:max-w-[80%] sm:px-4 sm:text-[15px] ${
                      msg.sender === "user"
                        ? "rounded-tr-none border-neutral-900 bg-neutral-900 text-white dark:border-neutral-700 dark:bg-neutral-800"
                        : "rounded-tl-none border-neutral-200 bg-white text-neutral-800 dark:border-neutral-800 dark:bg-neutral-900 dark:text-neutral-200"
                    }`}
                  >
                    {msg.text}
                  </div>
                </div>
              )}
            </motion.div>
          ))}
          {isLoading && (
            <motion.div
              initial={{ opacity: 0, y: 10, scale: 0.95 }}
              animate={{ opacity: 1, y: 0, scale: 1 }}
              className="flex justify-start"
            >
              <div className="bg-white/80 backdrop-blur-md px-4 py-2.5 rounded-tl-none rounded-2xl border border-slate-200/50 shadow-sm flex items-center gap-2 max-w-[85%] sm:max-w-[80%]">
                 <div className="w-1.5 h-1.5 bg-indigo-500 rounded-full animate-bounce [animation-delay:-0.3s]"></div>
                 <div className="w-1.5 h-1.5 bg-indigo-500 rounded-full animate-bounce [animation-delay:-0.15s]"></div>
                 <div className="w-1.5 h-1.5 bg-indigo-500 rounded-full animate-bounce"></div>
                 <span className="text-[11px] font-bold text-slate-500 ml-1 italic tracking-wide">AI is thinking...</span>
              </div>
            </motion.div>
          )}
        </AnimatePresence>
      </div>
    </div>
  );
};

const ChatInput = ({
  models,
  suggestions = [],
  hasMessages,
  placeholder,
  onSend,
}: {
  models: Model[];
  suggestions: Suggestion[];
  hasMessages: boolean;
  placeholder: string;
  onSend: (text: string, modelId: string) => void;
}) => {
  const [inputValue, setInputValue] = useState("");
  const [selectedModel, setSelectedModel] = useState(models[0]);
  const [isSearchActive, setIsSearchActive] = useState(false);
  const [isDeepMindActive, setIsDeepMindActive] = useState(false);
  const [attachments, setAttachments] = useState<File[]>([]);
  const [showAppsModal, setShowAppsModal] = useState(false);

  const imageInputRef = useRef<HTMLInputElement>(null);
  const docInputRef = useRef<HTMLInputElement>(null);

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files) {
      setAttachments(prev => [...prev, ...Array.from(e.target.files!)]);
    }
    // reset input
    e.target.value = '';
  };

  const textAreaRef = useRef<HTMLTextAreaElement>(null);

  useEffect(() => {
    if (textAreaRef.current) {
      textAreaRef.current.style.height = "auto";
      textAreaRef.current.style.height = `${textAreaRef.current.scrollHeight}px`;
    }
  }, [inputValue]);

  const handleSend = () => {
    if (!inputValue.trim() && attachments.length === 0) return;
    onSend(inputValue || "Sending attachments...", selectedModel.id);
    setInputValue("");
    setAttachments([]);
  };

  return (
    <motion.div
      layout
      transition={{ type: "spring", stiffness: 200, damping: 25 }}
      className={`z-20 flex w-full flex-col justify-center items-center px-3 py-4 sm:px-4 ${
        !hasMessages ? "flex-1" : ""
      }`}
    >
      {!hasMessages && suggestions.length > 0 && (
        <div className="w-full max-w-3xl grid grid-cols-1 sm:grid-cols-2 gap-3 mb-6 px-2">
          {suggestions.map((s, idx) => (
            <motion.button
              key={s.id}
              initial={{ opacity: 0, y: 15 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: idx * 0.05 + 0.1 }}
              onClick={() => onSend(s.label, models[0].id)}
              className="flex items-center gap-3 p-4 bg-white/60 backdrop-blur-md border border-white hover:border-indigo-200 hover:bg-white hover:shadow-lg hover:shadow-indigo-500/5 transition-all rounded-[28px] text-left group"
            >
              <div className="w-10 h-10 rounded-2xl bg-indigo-50 flex items-center justify-center text-indigo-600 group-hover:bg-indigo-600 group-hover:text-white transition-colors shrink-0">
                {s.icon}
              </div>
              <div className="min-w-0 flex-1">
                <p className="text-sm font-black text-slate-800 tracking-tight leading-tight">{s.label}</p>
                <p className="text-[11px] font-medium text-slate-400 line-clamp-1 mt-0.5">{s.sub}</p>
              </div>
            </motion.button>
          ))}
        </div>
      )}

      <div
        className="w-full max-w-3xl rounded-2xl border border-neutral-200 bg-white p-3 shadow-lg sm:rounded-[24px] dark:border-neutral-800 dark:bg-neutral-900 transition-all duration-300"
      >
        <input type="file" accept="image/*" multiple ref={imageInputRef} onChange={handleFileChange} className="hidden" />
        <input type="file" accept=".pdf,.doc,.docx,.txt" multiple ref={docInputRef} onChange={handleFileChange} className="hidden" />

        {attachments.length > 0 && (
          <div className="flex flex-wrap gap-2 mb-3">
            <AnimatePresence>
              {attachments.map((file, i) => (
                <motion.div key={i} initial={{ opacity: 0, scale: 0.8 }} animate={{ opacity: 1, scale: 1 }} exit={{ opacity: 0, scale: 0.8 }} className="flex items-center gap-2 bg-indigo-50 border border-indigo-100 px-3 py-1.5 rounded-lg">
                   {file.type.startsWith('image/') ? <ImageIcon className="w-4 h-4 text-indigo-500" /> : <FileText className="w-4 h-4 text-indigo-500" />}
                   <span className="text-xs font-semibold text-slate-700 max-w-[120px] truncate">{file.name}</span>
                   <button onClick={() => setAttachments(prev => prev.filter((_, idx) => idx !== i))} className="text-slate-400 hover:text-red-500 ml-1"><X className="w-3.5 h-3.5" /></button>
                </motion.div>
              ))}
            </AnimatePresence>
          </div>
        )}

        <textarea
          ref={textAreaRef}
          value={inputValue}
          onChange={(e) => setInputValue(e.target.value)}
          onKeyDown={(e) => {
            if (e.key === "Enter" && !e.shiftKey) {
              e.preventDefault();
              handleSend();
            }
          }}
          placeholder={placeholder}
          className="mb-2 max-h-[180px] min-h-[40px] w-full resize-none bg-transparent px-1 text-sm font-semibold text-neutral-700 outline-none placeholder:text-neutral-400 sm:max-h-[200px] sm:min-h-[44px] sm:px-2 sm:text-base dark:text-neutral-300 dark:placeholder:text-neutral-600"
          rows={1}
        />

        <div className="mt-2 flex items-center justify-between gap-2 rounded-xl border border-neutral-200 bg-neutral-50 p-2 dark:border-neutral-800 dark:bg-neutral-950">
          <div className="no-scrollbar flex items-center gap-1 overflow-x-auto sm:gap-2">
            <AttachmentMenu 
               onImageClick={() => imageInputRef.current?.click()} 
               onDocClick={() => docInputRef.current?.click()}
               onAppClick={() => setShowAppsModal(true)}
            />

            <motion.button
              layout
              onClick={() => setIsSearchActive(!isSearchActive)}
              className={`flex items-center gap-2 rounded-lg border p-2 transition-all sm:p-2.5 ${
                isSearchActive
                  ? "border-sky-300 bg-sky-50 dark:border-sky-700 dark:bg-sky-950"
                  : "border-neutral-200 bg-neutral-100 dark:border-neutral-800 dark:bg-neutral-900"
              }`}
            >
              <Globe
                className={`h-4 w-4 sm:h-5 sm:w-5 ${
                  isSearchActive
                    ? "text-sky-600 dark:text-sky-400"
                    : "text-neutral-500 dark:text-neutral-400"
                }`}
              />
              <AnimatePresence>
                {isSearchActive && (
                  <motion.span
                    initial={{ opacity: 0, width: 0 }}
                    animate={{ opacity: 1, width: "auto" }}
                    exit={{ opacity: 0, width: 0 }}
                    className="hidden overflow-hidden text-sm font-medium whitespace-nowrap text-neutral-700 sm:inline dark:text-neutral-200"
                  >
                    Search
                  </motion.span>
                )}
              </AnimatePresence>
            </motion.button>

            <motion.button
              layout
              onClick={() => setIsDeepMindActive(!isDeepMindActive)}
              className={`flex items-center gap-2 rounded-lg border p-2 transition-all sm:p-2.5 ${
                isDeepMindActive
                  ? "border-indigo-300 bg-indigo-50 dark:border-indigo-700 dark:bg-indigo-950"
                  : "border-neutral-200 bg-neutral-100 dark:border-neutral-800 dark:bg-neutral-900"
              }`}
            >
              <LuBrain
                className={`h-4 w-4 sm:h-5 sm:w-5 ${
                  isDeepMindActive
                    ? "text-indigo-600 dark:text-indigo-400"
                    : "text-neutral-500 dark:text-neutral-400"
                }`}
              />
              <AnimatePresence>
                {isDeepMindActive && (
                  <motion.span
                    initial={{ opacity: 0, width: 0 }}
                    animate={{ opacity: 1, width: "auto" }}
                    exit={{ opacity: 0, width: 0 }}
                    className="hidden overflow-hidden text-sm font-medium whitespace-nowrap text-neutral-700 sm:inline dark:text-neutral-200"
                  >
                    DeepMind
                  </motion.span>
                )}
              </AnimatePresence>
            </motion.button>

            <ModelSelector
              models={models}
              selectedModel={selectedModel}
              onSelect={setSelectedModel}
            />
          </div>

          <button
            onClick={handleSend}
            disabled={!inputValue.trim() && attachments.length === 0}
            className={`rounded-lg p-2 transition-colors sm:p-3 ${
              inputValue.trim() || attachments.length > 0
                ? "bg-blue-600 text-white dark:bg-blue-500"
                : "cursor-not-allowed bg-neutral-200 text-neutral-400 dark:bg-neutral-800 dark:text-neutral-600"
            }`}
          >
            <Send className="h-4 w-4 sm:h-5 sm:w-5" />
          </button>
        </div>
      </div>

      <AnimatePresence>
        {showAppsModal && (
          <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }} className="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/40 backdrop-blur-sm p-4">
            <motion.div initial={{ scale: 0.95 }} animate={{ scale: 1 }} exit={{ scale: 0.95 }} className="bg-white rounded-3xl shadow-2xl w-full max-w-md overflow-hidden border border-slate-200">
              <div className="p-6">
                <div className="flex items-center justify-between mb-6">
                  <h3 className="text-lg font-bold text-slate-800">Available Integrations</h3>
                  <button onClick={() => setShowAppsModal(false)} className="text-slate-400 hover:text-red-500 bg-slate-100 p-2 rounded-full"><X className="w-4 h-4" /></button>
                </div>
                <div className="space-y-3">
                   {[
                     { name: 'Epic EHR Network', status: 'Connected', bg: 'bg-green-500' },
                     { name: 'LabCorp Direct', status: 'Available', bg: 'bg-slate-300' },
                     { name: 'Google Workspace', status: 'Available', bg: 'bg-slate-300' },
                   ].map(app => (
                     <div key={app.name} className="flex flex-row items-center justify-between p-4 border border-slate-200 rounded-2xl hover:border-indigo-300 transition-colors cursor-pointer group">
                        <div className="flex items-center gap-3">
                           <div className="w-10 h-10 bg-indigo-50 rounded-xl flex items-center justify-center text-indigo-600"><Layers className="w-5 h-5" /></div>
                           <div>
                             <p className="font-bold text-slate-700 text-sm">{app.name}</p>
                             <p className="text-[11px] text-slate-400 font-medium">{app.status}</p>
                           </div>
                        </div>
                        <div className={`w-10 h-6 ${app.status === 'Connected' ? 'bg-indigo-500' : 'bg-slate-200'} rounded-full p-1 transition-colors relative`}>
                           <div className={`w-4 h-4 bg-white rounded-full transition-transform ${app.status === 'Connected' ? 'translate-x-4' : 'translate-x-0'}`}></div>
                        </div>
                     </div>
                   ))}
                </div>
                <button onClick={() => setShowAppsModal(false)} className="w-full mt-6 py-3 bg-slate-900 text-white rounded-xl font-bold">Close Setup</button>
              </div>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>

    </motion.div>
  );
};



const AttachmentMenu = ({ onImageClick, onDocClick, onAppClick }: { onImageClick: () => void, onDocClick: () => void, onAppClick: () => void }) => (
  <DropdownMenu>
    <DropdownMenuTrigger asChild>
      <button className="group rounded-lg border border-neutral-200 bg-neutral-100 p-2 text-neutral-500 sm:p-2.5 dark:border-neutral-800 dark:bg-neutral-900 dark:text-neutral-400">
        <Plus className="h-4 w-4 transition-transform duration-200 group-data-[state=open]:rotate-45 sm:h-5 sm:w-5" />
      </button>
    </DropdownMenuTrigger>

    <DropdownMenuContent
      align="start"
      side="bottom"
      className="mt-5.5 w-44 rounded-xl border border-neutral-200 bg-white p-2 sm:w-48 dark:border-neutral-800 dark:bg-neutral-900"
    >
      <DropdownMenuItem onClick={onImageClick} className="flex items-center gap-2 p-2 text-sm text-neutral-700 dark:text-neutral-200 cursor-pointer">
        <ImageIcon className="h-4 w-4 shrink-0" /> Images
      </DropdownMenuItem>
      <DropdownMenuItem onClick={onDocClick} className="flex items-center gap-2 p-2 text-sm text-neutral-700 dark:text-neutral-200 cursor-pointer">
        <FileText className="h-4 w-4 shrink-0" /> Documents
      </DropdownMenuItem>
      <DropdownMenuItem onClick={onAppClick} className="flex items-center gap-2 p-2 text-sm text-neutral-700 dark:text-neutral-200 cursor-pointer">
        <Layers className="h-4 w-4 shrink-0" /> Connect Apps
      </DropdownMenuItem>
    </DropdownMenuContent>
  </DropdownMenu>
);

const ModelSelector = ({
  models,
  selectedModel,
  onSelect,
}: {
  models: Model[];
  selectedModel: Model;
  onSelect: (model: Model) => void;
}) => (
  <DropdownMenu>
    <DropdownMenuTrigger asChild>
      <button className="flex items-center gap-2 rounded-lg border border-neutral-200 bg-neutral-100 p-2 text-sm text-neutral-700 sm:p-2.5 dark:border-neutral-800 dark:bg-neutral-900 dark:text-neutral-200">
        {selectedModel.icon}
        <span className="hidden md:inline">{selectedModel.name}</span>
        <ChevronDown className="h-3 w-3" />
      </button>
    </DropdownMenuTrigger>

    <DropdownMenuContent
      align="start"
      side="bottom"
      className="mt-5.5 w-48 rounded-xl border border-neutral-200 bg-white sm:w-52 dark:border-neutral-800 dark:bg-neutral-900"
    >
      {models.map((model) => (
        <DropdownMenuItem
          key={model.id}
          onClick={() => onSelect(model)}
          className="flex items-center gap-2 p-2 text-sm text-neutral-700 dark:text-neutral-200"
        >
          {model.icon}
          {model.name}
        </DropdownMenuItem>
      ))}
    </DropdownMenuContent>
  </DropdownMenu>
);

