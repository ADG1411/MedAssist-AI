"use client";

import { SidebarLeftIcon } from "@hugeicons/core-free-icons";
import { HugeiconsIcon } from "@hugeicons/react";
import { motion, AnimatePresence } from "motion/react";
import { useState, type ReactNode } from "react";

export interface MacOSSidebarProps {
  items: string[];
  defaultOpen?: boolean;
  initialSelectedIndex?: number;
  children?: ReactNode;
  className?: string;
  onItemSelect?: (index: number) => void;
}

export function MacOSSidebar({
  items,
  defaultOpen = true,
  initialSelectedIndex = 0,
  children,
  className = "",
  onItemSelect,
}: MacOSSidebarProps) {
  const [hoveredIndex, setHoveredIndex] = useState<number | null>(null);
  const [selectedIndex, setSelectedIndex] =
    useState<number>(initialSelectedIndex);
  const [isOpen, setIsOpen] = useState<boolean>(defaultOpen);

  const handleSelect = (index: number) => {
    setSelectedIndex(index);
    if (onItemSelect) {
      onItemSelect(index);
    }
  };

  return (
    <div
      className={`flex relative w-full sm:min-w-[480px] overflow-hidden ${className}`}
    >
      <motion.div
        animate={{
          width: isOpen ? 250 : 70,
        }}
        transition={{ type: "spring", bounce: 0.1, duration: 0.6 }}
        className={`shrink-0 flex flex-col items-start transition-colors duration-500 ease-out border-r border-slate-200 z-50 ${
          isOpen ? "bg-white" : "bg-white"
        }`}
      >
        <div
          className={`flex items-center w-full min-h-[64px] border-b border-slate-100 ${
            isOpen ? "justify-between px-6" : "justify-center px-0 flex-col py-4"
          } shrink-0 mb-2`}
        >
          <AnimatePresence>
            {isOpen && (
              <motion.div
                initial={{ opacity: 0, x: -10 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: -10 }}
                transition={{ duration: 0.2 }}
                className="flex items-center gap-3 overflow-hidden"
              >
                <img 
                  src="/medassist-logo.svg" 
                  alt="MedAssist" 
                  className="h-8 w-8 object-contain"
                />
                <span className="font-bold text-xl text-[#0A2540] tracking-tight whitespace-nowrap">
                  MedAssist
                </span>
              </motion.div>
            )}
          </AnimatePresence>
          {!isOpen && (
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="absolute pointer-events-none top-4"
            >
               <img src="/medassist-logo.svg" alt="M" className="h-8 w-8 object-contain" />
            </motion.div>
          )}
          <motion.div
            layout
            className={`shrink-0 flex items-center justify-center z-10 ${!isOpen ? 'mt-12' : ''}`}
          >
            <HugeiconsIcon
              icon={SidebarLeftIcon}
              className="size-5 cursor-pointer text-slate-400 hover:text-brand-blue transition-colors"
              onClick={() => setIsOpen(!isOpen)}
            />
          </motion.div>
        </div>

        <AnimatePresence>
          {isOpen && (
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              transition={{ duration: 0.2, ease: "easeOut" }}
              className="flex flex-col gap-1 mt-2 w-full px-3 relative z-10 whitespace-nowrap"
              onMouseLeave={() => setHoveredIndex(null)}
            >
              {items.map((item, index) => (
                <div
                  key={item}
                  className="relative cursor-pointer group"
                  onMouseEnter={() => setHoveredIndex(index)}
                  onClick={() => handleSelect(index)}
                >
                  <AnimatePresence>
                    {selectedIndex === index && (
                      <motion.div
                        className="absolute inset-0 z-0 bg-brand-blue rounded-xl shadow-soft"
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        exit={{ opacity: 0 }}
                        transition={{ duration: 0.2, ease: "easeOut" }}
                      />
                    )}
                  </AnimatePresence>
                  <p
                    className={`relative z-10 px-3 py-3 tracking-tight text-[15px] ${
                      selectedIndex === index
                        ? "text-white font-medium"
                        : "text-slate-600 font-medium group-hover:text-slate-900"
                    }`}
                  >
                    {item}
                  </p>
                  <AnimatePresence>
                    {hoveredIndex === index && selectedIndex !== index && (
                      <motion.span
                        layoutId="sidebar-hover-bg"
                        className="absolute inset-0 z-0 bg-slate-100 rounded-xl"
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        exit={{ opacity: 0 }}
                        transition={{
                          type: "spring",
                          stiffness: 350,
                          damping: 30,
                        }}
                      />
                    )}
                  </AnimatePresence>
                </div>
              ))}
            </motion.div>
          )}
        </AnimatePresence>
      </motion.div>

      <div className="flex-1 w-full h-full min-h-full overflow-y-auto z-0 bg-[#F9FBFF]">
        {children}
      </div>
    </div>
  );
}