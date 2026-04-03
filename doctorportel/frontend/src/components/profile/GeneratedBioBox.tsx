import { useState, useEffect, useRef } from 'react';
import { CheckCircle2, RefreshCw, Edit2, Copy, Check, Sparkles, ChevronDown, ChevronUp } from 'lucide-react';

interface GeneratedBioBoxProps {
  bio: string;
  isStreaming: boolean;
  onAccept: (bio: string) => void;
  onRegenerate: () => void;
  onClose: () => void;
}

// Bold key medical terms for display
function renderHighlighted(text: string) {
  const KEYWORDS = [
    /(\d+\+? years?)/gi,
    /(MBBS|MD|MS|DM|FRCS|FRCOG|MRCP|Ph\.?D\.?)/g,
    /(\d+%)/g,
  ];
  const parts: { text: string; bold: boolean }[] = [];

  const allMatches: { index: number; length: number; match: string }[] = [];
  for (const re of KEYWORDS) {
    const local = new RegExp(re.source, re.flags);
    let m: RegExpExecArray | null;
    while ((m = local.exec(text)) !== null) {
      allMatches.push({ index: m.index, length: m[0].length, match: m[0] });
    }
  }
  allMatches.sort((a, b) => a.index - b.index);

  let cursor = 0;
  for (const match of allMatches) {
    if (match.index < cursor) continue;
    if (match.index > cursor) {
      parts.push({ text: text.slice(cursor, match.index), bold: false });
    }
    parts.push({ text: match.match, bold: true });
    cursor = match.index + match.length;
  }
  if (cursor < text.length) {
    parts.push({ text: text.slice(cursor), bold: false });
  }
  return parts.length > 0 ? parts : [{ text, bold: false }];
}

export const GeneratedBioBox = ({
  bio,
  isStreaming,
  onAccept,
  onRegenerate,
  onClose,
}: GeneratedBioBoxProps) => {
  const [editMode, setEditMode] = useState(false);
  const [editedBio, setEditedBio] = useState('');
  const [displayedBio, setDisplayedBio] = useState('');
  const [charIndex, setCharIndex] = useState(0);
  const [copied, setCopied] = useState(false);
  const [showHighlights, setShowHighlights] = useState(true);
  const textareaRef = useRef<HTMLTextAreaElement>(null);

  // Reset streaming when new bio arrives
  useEffect(() => {
    setDisplayedBio('');
    setCharIndex(0);
    setEditMode(false);
    setEditedBio('');
  }, [bio]);

  // Streaming character-by-character effect
  useEffect(() => {
    if (!bio || charIndex >= bio.length) return;
    const id = setTimeout(() => {
      setDisplayedBio(prev => prev + bio[charIndex]);
      setCharIndex(i => i + 1);
    }, 12);
    return () => clearTimeout(id);
  }, [charIndex, bio]);

  const isComplete = charIndex >= bio.length && bio.length > 0;
  const currentBio = editMode ? editedBio : displayedBio;
  const finalBio = editMode ? editedBio : bio;

  const handleEdit = () => {
    setEditedBio(bio);
    setEditMode(true);
    setTimeout(() => textareaRef.current?.focus(), 50);
  };

  const handleCopy = async () => {
    await navigator.clipboard.writeText(finalBio);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  const highlighted = renderHighlighted(displayedBio);

  return (
    <div className="rounded-xl border border-indigo-200 bg-gradient-to-br from-indigo-50/60 to-purple-50/40 overflow-hidden shadow-sm animate-in slide-in-from-top-2 duration-300">
      {/* Header */}
      <div className="flex items-center justify-between px-4 py-3 border-b border-indigo-100 bg-white/60">
        <div className="flex items-center gap-2">
          <div className="w-6 h-6 rounded-full bg-gradient-to-br from-blue-500 to-purple-600 flex items-center justify-center">
            <Sparkles className="w-3.5 h-3.5 text-white" />
          </div>
          <span className="text-sm font-bold text-slate-700">AI Generated Bio</span>
          {isStreaming && !isComplete && (
            <span className="flex gap-0.5 items-end ml-1">
              <span className="w-1 h-3 bg-indigo-400 rounded-full animate-[bounce_0.8s_ease-in-out_0s_infinite]" />
              <span className="w-1 h-4 bg-indigo-400 rounded-full animate-[bounce_0.8s_ease-in-out_0.15s_infinite]" />
              <span className="w-1 h-3 bg-indigo-400 rounded-full animate-[bounce_0.8s_ease-in-out_0.3s_infinite]" />
            </span>
          )}
          {isComplete && !editMode && (
            <span className="text-[10px] font-bold text-emerald-600 bg-emerald-50 border border-emerald-200 px-2 py-0.5 rounded-full">
              Ready
            </span>
          )}
        </div>

        <div className="flex items-center gap-1">
          {isComplete && !editMode && (
            <button
              onClick={() => setShowHighlights(h => !h)}
              className="flex items-center gap-1 text-[11px] text-slate-500 hover:text-indigo-600 px-2 py-1 rounded-lg hover:bg-white transition-colors"
              title="Toggle highlights"
            >
              {showHighlights ? <ChevronUp className="w-3 h-3" /> : <ChevronDown className="w-3 h-3" />}
              Highlights
            </button>
          )}
          <button
            onClick={handleCopy}
            disabled={!isComplete}
            className="p-1.5 rounded-lg text-slate-400 hover:text-slate-700 hover:bg-white disabled:opacity-30 transition-colors"
            title="Copy to clipboard"
          >
            {copied ? <Check className="w-3.5 h-3.5 text-emerald-500" /> : <Copy className="w-3.5 h-3.5" />}
          </button>
        </div>
      </div>

      {/* Content */}
      <div className="p-4">
        {editMode ? (
          <textarea
            ref={textareaRef}
            value={editedBio}
            onChange={e => setEditedBio(e.target.value)}
            rows={6}
            className="w-full bg-white border border-indigo-200 rounded-xl p-3 text-sm text-slate-700 resize-y focus:ring-2 focus:ring-indigo-300/40 focus:border-indigo-400 outline-none leading-relaxed"
          />
        ) : (
          <p className="text-sm text-slate-700 leading-relaxed min-h-[80px]">
            {showHighlights && isComplete
              ? highlighted.map((part, i) =>
                  part.bold
                    ? <strong key={i} className="font-bold text-indigo-700">{part.text}</strong>
                    : <span key={i}>{part.text}</span>
                )
              : currentBio
            }
            {/* Blinking cursor while streaming */}
            {!isComplete && (
              <span className="inline-block w-0.5 h-4 bg-indigo-500 ml-0.5 animate-pulse align-middle" />
            )}
          </p>
        )}
      </div>

      {/* Action Buttons */}
      {isComplete && (
        <div className="flex flex-wrap items-center gap-2 px-4 pb-4">
          <button
            onClick={() => onAccept(finalBio)}
            className="flex items-center gap-1.5 px-4 py-2 bg-gradient-to-r from-emerald-500 to-teal-500 text-white text-sm font-bold rounded-xl hover:brightness-110 shadow-sm transition-all active:scale-95"
          >
            <CheckCircle2 className="w-4 h-4" /> Accept
          </button>

          <button
            onClick={onRegenerate}
            className="flex items-center gap-1.5 px-4 py-2 bg-white border border-slate-200 text-slate-700 text-sm font-bold rounded-xl hover:bg-slate-50 shadow-sm transition-all active:scale-95"
          >
            <RefreshCw className="w-4 h-4" /> Regenerate
          </button>

          {!editMode ? (
            <button
              onClick={handleEdit}
              className="flex items-center gap-1.5 px-4 py-2 bg-white border border-indigo-200 text-indigo-600 text-sm font-bold rounded-xl hover:bg-indigo-50 shadow-sm transition-all active:scale-95"
            >
              <Edit2 className="w-4 h-4" /> Edit Manually
            </button>
          ) : (
            <button
              onClick={() => setEditMode(false)}
              className="flex items-center gap-1.5 px-4 py-2 bg-indigo-50 border border-indigo-200 text-indigo-600 text-sm font-bold rounded-xl hover:bg-indigo-100 shadow-sm transition-all active:scale-95"
            >
              <CheckCircle2 className="w-4 h-4" /> Done Editing
            </button>
          )}

          <button
            onClick={onClose}
            className="ml-auto text-xs text-slate-400 hover:text-slate-600 transition-colors"
          >
            Dismiss
          </button>
        </div>
      )}
    </div>
  );
};
