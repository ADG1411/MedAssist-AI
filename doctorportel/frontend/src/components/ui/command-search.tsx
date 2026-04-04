import React, { useState, useRef } from 'react';
import { Search, Mic } from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';

interface CommandSearchProps {
  value: string;
  onChange: (value: string) => void;
  placeholder?: string;
  onVoiceSearch?: () => void;
}

export const CommandSearch: React.FC<CommandSearchProps> = ({
  value,
  onChange,
  placeholder = 'Search by name, disease, symptoms...',
  onVoiceSearch
}) => {
  const [isFocused, setIsFocused] = useState(false);
  const inputRef = useRef<HTMLInputElement>(null);

  // Focus shortcut: Cmd/Ctrl + K
  React.useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if ((e.metaKey || e.ctrlKey) && e.key === 'k') {
        e.preventDefault();
        inputRef.current?.focus();
      }
    };
    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, []);

  return (
    <motion.div 
      className="relative flex-1 group z-20"
      initial={false}
      animate={{
        scale: isFocused ? 1.02 : 1,
      }}
      transition={{ type: "spring", stiffness: 400, damping: 30 }}
    >
      <div className={`absolute inset-0 -z-10 rounded-2xl transition-all duration-500 ease-out ${isFocused ? 'bg-brand-blue/10 blur-xl opacity-100' : 'opacity-0 blur-md'}`} />
      
      <div className={`relative flex items-center bg-white rounded-2xl shadow-sm border transition-all duration-300 ${isFocused ? 'border-brand-blue/30 shadow-[0_8px_30px_rgb(0,0,0,0.08)]' : 'border-slate-200/60 hover:border-slate-300'}`}>
        <Search className={`absolute left-5 w-5 h-5 transition-colors duration-300 ${isFocused ? 'text-brand-blue' : 'text-slate-400'}`} />
        
        <input
          ref={inputRef}
          type="text"
          placeholder={placeholder}
          value={value}
          onChange={(e) => onChange(e.target.value)}
          onFocus={() => setIsFocused(true)}
          onBlur={() => setIsFocused(false)}
          className="w-full bg-transparent pl-14 pr-24 py-4 text-[15px] font-medium outline-none text-slate-800 placeholder:text-slate-400 placeholder:font-normal rounded-2xl"
        />

        <AnimatePresence>
          {!isFocused && !value && (
            <motion.div
              initial={{ opacity: 0, x: 10 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: 10 }}
              className="absolute right-14 flex items-center gap-1 px-2 py-1 bg-slate-100 rounded-lg text-[10px] font-bold text-slate-400 pointer-events-none"
            >
              <span>⌘</span>
              <span>K</span>
            </motion.div>
          )}
        </AnimatePresence>

        <button 
          onClick={onVoiceSearch ? onVoiceSearch : () => alert("Voice search is unavailable")}
          className={`absolute right-3 p-2.5 rounded-xl transition-all duration-300 ${isFocused ? 'bg-brand-blue/10 text-brand-blue hover:bg-brand-blue/20' : 'bg-slate-50 hover:bg-slate-100 text-slate-500'}`}
        >
          <Mic className="w-4 h-4" />
        </button>
      </div>
    </motion.div>
  );
};
