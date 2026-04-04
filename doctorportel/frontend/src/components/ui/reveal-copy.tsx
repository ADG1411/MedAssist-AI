import { useState, useEffect, useCallback } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { FaCopy } from 'react-icons/fa';
import { BsEyeFill } from 'react-icons/bs';
import { FaCheck } from 'react-icons/fa6';

type RevealAndCopyProps = {
  cardNumber: string;
  hiddenIndexes?: number[];
  revealDuration?: number;
  copiedDuration?: number;
  className?: string;
};

export const RevealAndCopy = ({
  cardNumber,
  hiddenIndexes = [1, 2],
  revealDuration = 3000,
  copiedDuration = 1200,
  className,
}: RevealAndCopyProps) => {
  const [revealed, setRevealed] = useState(false);
  const [copied, setCopied] = useState(false);
  const [timerActive, setTimerActive] = useState(false);

  const parts = cardNumber.split('-');

  const resetAll = useCallback(() => {
    setRevealed(false);
    setCopied(false);
    setTimerActive(false);
  }, []);

  useEffect(() => {
    if (!revealed) return;

    // eslint-disable-next-line react-hooks/set-state-in-effect
    setTimerActive(true);

    const timer = setTimeout(() => {
      if (!copied) resetAll();
    }, revealDuration);

    return () => clearTimeout(timer);
  }, [revealed, copied, revealDuration, resetAll]);

  useEffect(() => {
    if (!copied) return;

    const timer = setTimeout(() => {
      resetAll();
    }, copiedDuration);

    return () => clearTimeout(timer);
  }, [copied, copiedDuration, resetAll]);

  const handleCopy = async () => {
    if (copied) return;

    await navigator.clipboard.writeText(cardNumber);

    setCopied(true);
    setTimerActive(false);
  };

  return (
    <div className={`flex flex-col items-start justify-center transition-colors duration-500 ${className || ''}`}>
      <div className="flex h-[40px] w-full max-w-[420px] items-center rounded-xl bg-slate-900 px-2 transition-colors duration-500">
        <div className="relative flex flex-1 items-center justify-start overflow-hidden text-[13px] tracking-widest sm:text-[14px]">
          <AnimatePresence>
            {revealed && (
              <motion.div
                key="shine"
                initial={{ left: '-60%' }}
                animate={{ left: '160%' }}
                transition={{
                  delay: 0.35,
                  duration: 1,
                  ease: 'linear',
                }}
                className="pointer-events-none absolute inset-y-0 z-30 w-[60%] mix-blend-screen"
                style={{
                  transform: 'skewX(-20deg)',
                  background: `
                    linear-gradient(
                      90deg,
                      transparent 0%,
                      rgba(255,255,255,0.15) 20%,
                      rgba(255,255,255,0.9) 50%,
                      rgba(255,255,255,0.15) 80%,
                      transparent 100%
                    )
                  `,
                  filter: 'blur(6px)',
                }}
              />
            )}
          </AnimatePresence>

          {parts.map((part, idx) => {
            const isMasked = !revealed && hiddenIndexes.includes(idx);
            
            // Generate display, if masked replace with *, but keep length (or standard length if it's the long UUID part)
            // Example MED-2026-X-YYYYYYYY
            let display = part;
            if (isMasked) {
              display = idx === 2 ? '*' : '********';
            }

            return (
              <div
                key={idx}
                className="relative flex-none overflow-hidden font-bold"
              >
                <div className="relative flex items-center">
                  <AnimatePresence mode="popLayout" initial={false}>
                    {display.split('').map((char, i) => (
                      <motion.span
                        key={`${display}-${i}`}
                        initial={{
                          opacity: 0,
                          y: 12,
                          scale: 0.5,
                          filter: 'blur(4px)',
                        }}
                        animate={{
                          opacity: 1,
                          y: 0,
                          scale: 1,
                          filter: 'blur(0px)',
                          transition: {
                            type: 'spring',
                            stiffness: 200,
                            damping: 14,
                            delay: i * 0.06,
                          },
                        }}
                        exit={{
                          opacity: 0,
                          y: -12,
                          scale: 0.5,
                          filter: 'blur(4px)',
                          transition: {
                            delay: i * 0.06,
                            duration: 0.18,
                          },
                        }}
                        className="text-teal-400 tabular-nums"
                      >
                        {char}
                      </motion.span>
                    ))}
                    {idx < parts.length - 1 && <span className="text-teal-400 mx-0.5">-</span>}
                  </AnimatePresence>
                </div>
              </div>
            );
          })}
        </div>

        <div className="relative ml-2 shrink-0 h-6 w-6">
          <AnimatePresence mode="popLayout" initial={false}>
            {!revealed && (
              <motion.button
                key="eye"
                onClick={() => setRevealed(true)}
                initial={{ scale: 0.85, opacity: 0 }}
                animate={{ scale: 1, opacity: 1 }}
                exit={{ scale: 0.85, opacity: 0 }}
                className="flex h-full w-full items-center justify-center rounded bg-slate-800 text-teal-400 hover:bg-slate-700 transition"
              >
                <BsEyeFill size={12} />
              </motion.button>
            )}

            {revealed && (
              <motion.button
                key="copy"
                onClick={handleCopy}
                initial={{ scale: 0.85, opacity: 0 }}
                animate={{ scale: 1, opacity: 1 }}
                exit={{ scale: 0.85, opacity: 0 }}
                className={`relative flex h-full w-full items-center justify-center rounded transition-colors duration-300 ${copied
                  ? 'bg-emerald-500 text-white'
                  : 'bg-slate-800 text-teal-400 hover:bg-slate-700'
                  }`}
              >
                {timerActive && !copied && (
                  <svg
                    className="pointer-events-none absolute inset-0 h-full w-full text-teal-400"
                    viewBox="0 0 24 24"
                  >
                    <motion.rect
                      x="0.5"
                      y="0.5"
                      width="23"
                      height="23"
                      rx="4"
                      ry="4"
                      fill="transparent"
                      stroke="currentColor"
                      strokeWidth="1.5"
                      strokeDasharray="92"
                      initial={{ strokeDashoffset: 92 }}
                      animate={{ strokeDashoffset: 0 }}
                      transition={{
                        duration: revealDuration / 1000,
                        ease: 'linear',
                      }}
                    />
                  </svg>
                )}

                {copied ? <FaCheck size={12} /> : <FaCopy size={12} />}
              </motion.button>
            )}
          </AnimatePresence>
        </div>
      </div>
    </div>
  );
};
