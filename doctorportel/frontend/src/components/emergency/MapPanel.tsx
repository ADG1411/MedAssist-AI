import { MapPin, Navigation, Phone, Hospital } from 'lucide-react';

export const MapPanel = ({ location, distance }: { location: string, distance: string }) => {
  return (
    <div className="bg-white rounded-2xl border border-slate-200 p-4 flex flex-col h-[280px] lg:h-1/2 shadow-sm">
       <h3 className="text-slate-800 font-bold mb-3 flex items-center gap-2 text-sm md:text-base">
         <MapPin className="w-4 h-4 text-emerald-500"/> Live Location Tracking
       </h3>
       
       <div className="flex-1 bg-slate-50 rounded-xl relative overflow-hidden mb-4 bg-[url('https://www.transparenttextures.com/patterns/cubes.png')] flex items-center justify-center border border-slate-200">
         <div className="absolute w-full h-full bg-white/80"></div>
         <div className="relative z-10 flex flex-col items-center">
            <div className="flex items-center justify-center relative">
               <div className="w-6 h-6 bg-red-500 rounded-full animate-ping absolute opacity-40"></div>
               <div className="w-4 h-4 bg-red-500 rounded-full relative z-10 border-2 border-white shadow-lg"></div>
            </div>
            <span className="mt-2 bg-white/80 px-3 py-1 flex items-center rounded-full text-[10px] font-bold tracking-wider uppercase text-slate-700 backdrop-blur-sm border border-slate-200 shadow-sm">
              <Navigation className="w-3 h-3 mr-1.5 text-red-500"/> {distance} Away
            </span>
            <p className="text-xs text-slate-600 mt-2 font-medium bg-white/70 px-2 py-0.5 rounded shadow-sm">{location}</p>
         </div>
       </div>

       <div className="space-y-3">
         <div className="bg-slate-50 p-3 rounded-xl border border-slate-200 flex flex-col">
            <div className="flex justify-between items-start mb-1">
              <div className="flex items-center gap-2 text-slate-600">
                 <Hospital className="w-4 h-4 text-slate-500" />
                 <span className="text-xs font-bold uppercase tracking-wider text-slate-500">Nearest Hospital</span>
              </div>
              <span className="bg-emerald-50 text-emerald-600 text-xs font-bold px-2 py-0.5 rounded-md border border-emerald-100">5 mins ETA</span>
            </div>
            <p className="text-slate-800 font-bold text-sm ml-6">City Central General</p>
         </div>
         <button className="w-full bg-emerald-50 text-emerald-600 border border-emerald-200 hover:bg-emerald-100 hover:text-emerald-700 transition-colors py-2.5 rounded-xl text-sm font-bold flex items-center justify-center gap-2 shadow-sm relative overflow-hidden group">
           <span className="absolute inset-0 w-1/4 bg-white/50 skew-x-12 -translate-x-full group-hover:animate-[shimmer_1s_infinite]"></span>
           <Phone className="w-4 h-4" /> Dispatch Ambulance
         </button>
       </div>
    </div>
  );
};