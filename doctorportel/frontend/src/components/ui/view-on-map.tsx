import React, { useState } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { X, Loader2 } from 'lucide-react';
import { FaMap } from 'react-icons/fa6';

interface ViewOnMapProps {
  locationName?: string;
  address?: string;
  mapImageUrl?: string;
  className?: string;
}

export const ViewOnMap: React.FC<ViewOnMapProps> = ({
  address = 'Boston Public Garden',
  mapImageUrl = 'https://images.unsplash.com/photo-1526778548025-fa2f459cd5ce?q=80&w=2000&auto=format&fit=crop',
  className = '',
}) => {
  const [isOpen, setIsOpen] = useState(false);
  const [isMapLoaded, setIsMapLoaded] = useState(false);
  const [isDark] = useState(false);

  const toggleOpen = () => {
    setIsOpen(!isOpen);
    if (isOpen) setIsMapLoaded(false);
  };

  const springConfig = {
    type: 'spring' as const,
    stiffness: 400,
    damping: 30,
    mass: 0.8,
  };

  const publicMapUrl = `https://maps.google.com/maps?q=${encodeURIComponent(address)}&t=&z=16&ie=UTF8&iwloc=&output=embed`;

  return (
    <div className={`transition-colors duration-500`}>
      <div
        className={`flex min-h-full w-full flex-col items-center justify-center bg-transparent`}
      >
        <div
          className={`relative flex w-full items-center justify-center ${className}`}
        >
          <AnimatePresence mode="popLayout">
            {!isOpen ? (
              /* --- PILL BUTTON --- */
              <motion.div
                key="button"
                layoutId="map-container"
                onClick={toggleOpen}
                className="flex cursor-pointer items-center gap-2 bg-white hover:bg-slate-50 text-slate-600 border border-slate-200 px-4 py-2.5 rounded-xl font-bold text-[13px] shadow-sm transition-all"
                initial={{ opacity: 0, scale: 0.9 }}
                animate={{ opacity: 1, scale: 1 }}
                exit={{ opacity: 0, scale: 0.95 }}
                transition={springConfig}
                whileHover={{ scale: 1.02 }}
                whileTap={{ scale: 0.98 }}
              >
                <motion.div className="relative z-10 flex items-center space-x-1.5">
                  <FaMap className="h-4 w-4" />
                  <span className="hidden sm:inline">Location</span>
                </motion.div>
              </motion.div>
            ) : (
              /* --- EXPANDED MAP --- */
              <>
                <motion.div
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                  exit={{ opacity: 0 }}
                  className="fixed inset-0 z-[9998] bg-slate-900/60 backdrop-blur-sm"
                  onClick={toggleOpen}
                />
                <motion.div
                  key="map"
                  layoutId="map-container"
                  className="fixed z-[9999] top-24 right-8 w-[calc(100vw-32px)] sm:w-[380px] h-[380px] overflow-hidden bg-slate-200 shadow-2xl transition-colors duration-300 dark:bg-[#141414]"
                  style={{ borderRadius: 24 }}
                  transition={springConfig}
                >
                <motion.div
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                  transition={{ delay: 0.15 }}
                  className="absolute inset-0 h-full w-full"
                >
                  <iframe
                    title="Google Map"
                    width="100%"
                    height="100%"
                    style={{
                      border: 0,
                      filter: isDark
                        ? 'invert(90%) hue-rotate(180deg)'
                        : 'none',
                    }}
                    src={publicMapUrl}
                    allowFullScreen
                    onLoad={() => setIsMapLoaded(true)}
                    className={`transition-opacity duration-700 ${isMapLoaded ? 'opacity-100' : 'opacity-0'}`}
                  />
                </motion.div>

                {!isMapLoaded && (
                  <div className="absolute inset-0 flex items-center justify-center bg-[#E5E5E7] transition-colors dark:bg-[#1C1C1E]">
                    <Loader2 className="h-8 w-8 animate-spin text-gray-400" />
                  </div>
                )}

                {/* CLOSE BUTTON  */}
                <motion.button
                  initial={{ opacity: 0, scale: 0.5 }}
                  animate={{ opacity: 1, scale: 1 }}
                  onClick={toggleOpen}
                  className="absolute top-4 right-4 z-50 flex h-10 w-10 items-center justify-center rounded-full bg-white shadow-lg transition-all hover:bg-gray-50 active:scale-90"
                >
                  <X className="h-5 w-5" strokeWidth={3} />
                </motion.button>
              </motion.div>
              </>
            )}
          </AnimatePresence>
        </div>
      </div>
    </div>
  );
};
