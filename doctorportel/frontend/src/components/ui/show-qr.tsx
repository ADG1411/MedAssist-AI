"use client";

import { X, Link } from "lucide-react";
import { IoQrCodeOutline } from "react-icons/io5";
import {
  AnimatePresence,
  motion,
  MotionConfig,
  type Transition,
} from "framer-motion";
import { useEffect, useState } from "react";
import { QRCodeSVG } from "qrcode.react";
import useMeasure from "react-use-measure";

interface ShowQrProps {
  value: string;
  buttonLabel?: string;
  onCopy?: () => void;
}

export const ShowQr = ({
  value,
  buttonLabel = "Show QR Code",
  onCopy,
}: ShowQrProps) => {
  const [isExpanded, setIsExpanded] = useState(false);
  const [isCopied, setIsCopied] = useState(false);

  const [ref, bounds] = useMeasure();

  useEffect(() => {
    if (isCopied) {
      const t = setTimeout(() => setIsCopied(false), 2000);
      return () => clearTimeout(t);
    }
  }, [isCopied]);

  const springConfig: Transition = {
    type: "spring",
    bounce: 0.25,
    visualDuration: 0.35,
  };

  const collapsedTransition: Transition = {
    type: "spring",
    bounce: 0.15,
    visualDuration: 0.35,
  };

  return (
    <div className="flex w-full items-center justify-center overflow-hidden transition-colors py-4">
      <MotionConfig
        transition={isExpanded ? springConfig : collapsedTransition}
      >
        <motion.div
          initial={{
            width: buttonLabel ? 180 : 48,
          }}
          animate={{
            width: isExpanded ? 250 : (buttonLabel ? 180 : 48),
            height: isExpanded ? bounds.height : 48,
          }}
          className="overflow-hidden rounded-[32px] bg-slate-100 shadow-inner border border-slate-200"
        >
          <div ref={ref} className="">
            <AnimatePresence mode="popLayout" initial={false}>
              {!isExpanded ? (
                <motion.div
                  key="collapsed"
                  className="flex cursor-pointer items-center justify-center gap-1.5 px-4 py-3 font-bold text-[13px] text-slate-700 hover:text-slate-900"
                  onClick={() => setIsExpanded(true)}
                  initial={{ opacity: 0, filter: "blur(4px)" }}
                  animate={{ opacity: 1, y: 0, filter: "blur(0px)" }}
                  exit={{ opacity: 0, filter: "blur(4px)" }}
                >
                  <IoQrCodeOutline className="w-5 h-5" />
                  <span>{buttonLabel}</span>
                </motion.div>
              ) : (
                <motion.div
                  key="expanded"
                  className="flex flex-col items-center gap-2 p-4 text-slate-900"
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                  exit={{
                    opacity: 0,
                    transition: {
                      duration: 0.2,
                      ease: "easeOut",
                    },
                  }}
                >
                  <motion.div
                    className="flex h-[200px] w-[200px] items-center justify-center rounded-3xl border border-slate-200 bg-white p-4 shadow-sm"
                    initial={{ opacity: 0, y: 60, scale: 1.2 }}
                    animate={{ opacity: 1, y: 0, scale: 1 }}
                  >
                    <QRCodeSVG
                      value={value}
                      size={180}
                      level="M"
                      fgColor="#0f172a"
                      bgColor="#ffffff"
                      className="h-full w-full"
                    />
                  </motion.div>

                  <div className="flex w-full items-center gap-2 mt-2">
                    <motion.div
                      className="flex flex-1 cursor-pointer items-center justify-center gap-1.5 rounded-full border border-slate-200 hover:bg-slate-50 bg-white p-2.5 text-[13px] font-bold shadow-sm"
                      onClick={() => {
                        navigator.clipboard.writeText(value);
                        setIsCopied(true);
                        onCopy?.();
                      }}
                      layout
                    >
                      <motion.div layout>
                        <Link className="w-4 h-4" />
                      </motion.div>
                      <AnimatedText
                        from="Copy ID"
                        to="Copied!"
                        isCopied={isCopied}
                      />
                    </motion.div>

                    <div
                      className="flex cursor-pointer items-center justify-center rounded-full border border-slate-200 hover:bg-slate-50 bg-white p-2.5 shadow-sm"
                      onClick={() => {
                        setIsExpanded(false);
                        setIsCopied(false);
                      }}
                    >
                      <X className="w-4 h-4" />
                    </div>
                  </div>
                </motion.div>
              )}
            </AnimatePresence>
          </div>
        </motion.div>
      </MotionConfig>
    </div>
  );
};

const AnimatedText = ({
  from,
  to,
  isCopied,
}: {
  from: string;
  to: string;
  isCopied: boolean;
}) => {
  const activeText = isCopied ? to : from;

  return (
    <div className="flex tracking-tight will-change-transform">
      <AnimatePresence mode="popLayout" initial={false}>
        {activeText.split("").map((char, index) => {
          const displayChar = char === " " ? "\u00A0" : char;

          return (
            <motion.span
              key={char + index}
              layout
              initial={{ opacity: 0, y: 5, scale: 0.7 }}
              animate={{
                opacity: 1,
                y: 0,
                scale: 1,
                transition: {
                  type: "spring",
                  stiffness: 200,
                  damping: 20,
                  delay: 0.03 * index,
                },
              }}
              exit={{ opacity: 0, y: -5, scale: 0.7 }}
            >
              {displayChar}
            </motion.span>
          );
        })}
      </AnimatePresence>
    </div>
  );
};
