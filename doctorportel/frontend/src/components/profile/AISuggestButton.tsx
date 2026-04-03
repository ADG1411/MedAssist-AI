import { Sparkles, Loader2 } from 'lucide-react';
import { cn } from '../../layouts/DashboardLayout';

interface AISuggestButtonProps {
  onClick: () => void;
  loading?: boolean;
  className?: string;
}

export const AISuggestButton = ({ onClick, loading, className }: AISuggestButtonProps) => {
  return (
    <button
      onClick={onClick}
      disabled={loading}
      className={cn(
        'relative flex items-center gap-2 px-4 py-2 rounded-xl text-sm font-bold',
        'bg-gradient-to-r from-blue-500 via-indigo-500 to-purple-600 text-white',
        'shadow-md hover:shadow-lg hover:brightness-110 active:scale-95',
        'transition-all duration-200 overflow-hidden select-none',
        'disabled:opacity-70 disabled:cursor-not-allowed disabled:brightness-100 disabled:active:scale-100',
        className
      )}
    >
      {/* animated shimmer overlay */}
      {!loading && (
        <span
          aria-hidden
          className="pointer-events-none absolute inset-0 animate-shimmer bg-gradient-to-r from-transparent via-white/25 to-transparent"
        />
      )}
      {loading
        ? <Loader2 className="w-4 h-4 animate-spin relative z-10" />
        : <Sparkles className="w-4 h-4 relative z-10" />
      }
      <span className="relative z-10">{loading ? 'Generating…' : 'AI Suggest'}</span>
    </button>
  );
};
