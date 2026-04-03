import React, { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Eye, Stethoscope, X, ChevronRight } from "lucide-react";

export interface CarouselCard {
  id: string;
  title: string;
  value: string;
  color: string;
  icon: React.ElementType;
}

interface MinimalCarouselProps {
  cards: CarouselCard[];
  onCopyClick?: (card: CarouselCard) => void;
  onCustomizeClick?: (card: CarouselCard) => void;
  copyLabel?: string;
  customizeLabel?: string;
  containerClass?: string;
}

export const MinimalCarousel: React.FC<MinimalCarouselProps> = ({
  cards,
  onCopyClick,
  onCustomizeClick,
  copyLabel = "View Details",
  customizeLabel = "Consult",
  containerClass = "max-w-none",
}) => {
  const [activeId, setActiveId] = useState<string | null>(null);

  const activeCard = cards.find((c) => c.id === activeId);
  const secondaryCards = cards.filter((c) => c.id !== activeId);

  return (
    <div className={`w-full ${containerClass} select-none`}>
      <motion.div layout className="flex flex-col gap-4">

        {/* ── Expanded Card ── */}
        <AnimatePresence mode="popLayout">
          {activeCard && (
            <motion.div
              key={activeCard.id}
              layoutId={activeCard.id}
              className={`relative w-full overflow-hidden rounded-3xl p-6 sm:p-8 text-white shadow-2xl ${activeCard.color}`}
              style={{ minHeight: 220 }}
              transition={{ type: "spring", bounce: 0.18, duration: 0.55 }}
            >
              {/* noise texture overlay */}
              <div className="absolute inset-0 opacity-10 pointer-events-none"
                style={{ backgroundImage: "url(\"data:image/svg+xml,%3Csvg viewBox='0 0 256 256' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='noise'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noise)'/%3E%3C/svg%3E\")" }} />

              {/* Top row */}
              <div className="relative flex items-start justify-between gap-3 mb-8">
                <div className="flex items-center gap-3">
                  {/* Avatar circle */}
                  <div className="w-14 h-14 rounded-2xl bg-white/20 backdrop-blur-sm flex items-center justify-center shadow-inner border border-white/20">
                    <activeCard.icon size={30} />
                  </div>
                  <div>
                    <span className="text-[11px] font-semibold tracking-widest uppercase opacity-60">Patient</span>
                    <h3 className="text-2xl sm:text-3xl font-black leading-tight">{activeCard.title}</h3>
                  </div>
                </div>

                {/* Close */}
                <motion.button
                  initial={{ opacity: 0, rotate: -90 }}
                  animate={{ opacity: 1, rotate: 0 }}
                  type="button"
                  onClick={(e) => { e.stopPropagation(); setActiveId(null); }}
                  className="w-9 h-9 rounded-full bg-white/15 hover:bg-white/25 flex items-center justify-center transition-colors shrink-0"
                >
                  <X size={16} />
                </motion.button>
              </div>

              {/* Sub-info */}
              <p className="relative text-base sm:text-lg font-semibold opacity-70 mb-8">{activeCard.value}</p>

              {/* Action buttons */}
              <motion.div
                initial={{ opacity: 0, y: 12 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.15 }}
                className="relative flex items-center gap-3"
              >
                <button
                  type="button"
                  onClick={(e) => { e.stopPropagation(); onCopyClick?.(activeCard); }}
                  className="flex items-center gap-2 rounded-2xl bg-white text-slate-900 px-5 py-2.5 text-sm font-bold shadow-lg hover:scale-105 active:scale-95 transition-transform"
                >
                  <Eye size={16} />
                  {copyLabel}
                </button>
                <button
                  type="button"
                  onClick={(e) => { e.stopPropagation(); onCustomizeClick?.(activeCard); }}
                  className="flex items-center gap-2 rounded-2xl bg-white/20 backdrop-blur-sm border border-white/25 text-white px-5 py-2.5 text-sm font-bold hover:bg-white/30 transition-colors"
                >
                  <Stethoscope size={16} />
                  {customizeLabel}
                </button>
              </motion.div>
            </motion.div>
          )}
        </AnimatePresence>

        {/* ── Card Grid ── */}
        <motion.div
          layout
          className={`grid gap-3 sm:gap-4 ${activeId ? "grid-cols-2 md:grid-cols-3" : "grid-cols-2 sm:grid-cols-3 md:grid-cols-4"}`}
        >
          {(activeId ? secondaryCards : cards).map((card) => (
            <motion.div
              key={card.id}
              layoutId={card.id}
              onClick={() => setActiveId(card.id)}
              whileHover={{ y: -3, scale: 1.02 }}
              whileTap={{ scale: 0.97 }}
              transition={{ type: "spring", bounce: 0.25, duration: 0.4 }}
              className={`relative flex flex-col justify-between cursor-pointer overflow-hidden rounded-[22px] sm:rounded-[26px] p-4 sm:p-5 text-white shadow-lg ${card.color} ${activeId ? "h-24 sm:h-28" : "h-32 sm:h-36"}`}
            >
              {/* Subtle top-right glow */}
              <div className="absolute -top-6 -right-6 w-20 h-20 rounded-full bg-white/10 blur-xl pointer-events-none" />

              <div className="flex justify-between items-start relative">
                <div className="w-9 h-9 rounded-xl bg-white/20 flex items-center justify-center shrink-0">
                  <card.icon size={activeId ? 16 : 20} />
                </div>
                <ChevronRight size={14} className="opacity-40" />
              </div>

              <div className="relative overflow-hidden mt-2">
                <h4 className={`${activeId ? "text-xs" : "text-sm sm:text-[15px]"} font-bold truncate leading-tight`}>
                  {card.title}
                </h4>
                <p className={`${activeId ? "text-[10px]" : "text-xs sm:text-sm"} font-medium text-white/60 truncate mt-0.5`}>
                  {card.value}
                </p>
              </div>
            </motion.div>
          ))}
        </motion.div>

      </motion.div>
    </div>
  );
};
