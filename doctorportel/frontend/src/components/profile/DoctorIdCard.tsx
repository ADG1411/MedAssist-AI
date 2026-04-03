import { Sparkles, QrCode } from 'lucide-react';

interface IDCardProps {
  name: string;
  idNumber: string;
  specialty?: string;
  bloodGroup: string;
}

export function DoctorIdCard({ name, idNumber, specialty, bloodGroup }: IDCardProps) {
  return (
    <div className="relative overflow-hidden bg-slate-900 rounded-3xl p-8 sm:p-10 shadow-2xl w-full max-w-2xl aspect-[1.58] shrink-0 border border-slate-800 text-slate-100 flex flex-col justify-between transition-all duration-300 hover:shadow-cyan-900/20">
      {/* Background Decorative Graphic */}
      <img 
        src="/logo.svg" 
        alt="" 
        className="absolute -right-16 -bottom-20 w-[32rem] h-[32rem] opacity-[0.03] pointer-events-none object-contain"
      />

      <div className="flex items-center justify-between mb-4 z-10 relative"> 
        <div className="flex items-center gap-4">
          <div className="flex items-center justify-center p-2.5 bg-blue-500/20 backdrop-blur-sm rounded-xl shadow-lg border border-blue-500/30">
            <img src="/logo.svg" alt="Logo" className="w-8 h-8 sm:w-10 sm:h-10 object-contain drop-shadow-md" />
          </div>
          <div>
            <h2 className="text-lg sm:text-xl font-bold tracking-tight text-white flex items-center gap-1.5">
              MedAssist <Sparkles className="w-4 h-4 sm:w-5 sm:h-5 text-cyan-400" />     
            </h2>
            <p className="text-xs sm:text-sm text-slate-400 font-medium tracking-[0.2em] uppercase mt-0.5">Universal Health ID</p>
          </div>
        </div>
        <div className="flex items-center gap-2 px-3 sm:px-4 py-1.5 rounded-full bg-emerald-500/10 border border-emerald-500/20">
          <div className="w-2 h-2 sm:w-2.5 sm:h-2.5 rounded-full bg-emerald-400 animate-pulse shadow-[0_0_8px_rgba(52,211,153,0.8)]"></div>
          <span className="text-xs sm:text-sm font-bold text-emerald-400 tracking-widest">ACTIVE</span>
        </div>
      </div>

      <div className="space-y-6 sm:space-y-8 z-10 relative flex-grow flex flex-col justify-center">
        <div>
          <p className="text-xs sm:text-sm font-bold text-slate-500 tracking-widest uppercase mb-1.5">Doctor Name</p>
          <h3 className="text-3xl sm:text-4xl font-bold text-white tracking-tight drop-shadow-sm">{name || 'Dr. Name'}</h3>
        </div>

        <div className="grid grid-cols-3 gap-6 sm:gap-8">
          <div>
            <p className="text-xs sm:text-sm font-bold text-slate-500 tracking-widest uppercase mb-1.5">ID Number</p>
            <p className="text-lg sm:text-xl font-bold text-slate-200 tracking-wide">{idNumber || 'MED - XXXX'}</p>
          </div>
          <div>
            <p className="text-xs sm:text-sm font-bold text-slate-500 tracking-widest uppercase mb-1.5">Specialty</p>
            <p className="text-lg sm:text-xl font-bold text-slate-200">{specialty || 'Cardiology'}</p>
          </div>
          <div>
            <p className="text-xs sm:text-sm font-bold text-slate-500 tracking-widest uppercase mb-1.5">Blood</p>
            <p className="text-lg sm:text-xl font-bold text-rose-400 drop-shadow-sm">{bloodGroup || 'B+'}</p>
          </div>
        </div>
      </div>

      <div className="mt-6 flex items-end justify-between z-10 relative border-t border-slate-800/80 pt-6">
        <p className="text-xs sm:text-sm text-slate-500 font-medium tracking-wide">© 2026 MEDASSIST GROUP</p>
        <div className="flex gap-6 sm:gap-8 items-center">
          <div className="w-14 h-9 sm:w-16 sm:h-11 bg-amber-500 rounded-lg border border-amber-400/50 shadow-[inset_0_1px_1px_rgba(255,255,255,0.4),0_2px_8px_rgba(0,0,0,0.4)] opacity-90 grid grid-cols-3 grid-rows-2 gap-[1px] p-[1px]">
             {/* Simulating chip */}
             <div className="bg-amber-600/60 rounded-sm"></div>
             <div className="bg-amber-600/60 rounded-sm"></div>
             <div className="bg-amber-600/60 rounded-sm"></div>
             <div className="bg-amber-600/60 rounded-sm"></div>
             <div className="bg-amber-600/60 rounded-sm"></div>
             <div className="bg-amber-600/60 rounded-sm"></div>
          </div>
          <div className="p-2 sm:p-2.5 bg-white rounded-xl shadow-lg ring-1 ring-slate-200">
            <QrCode className="w-10 h-10 sm:w-12 sm:h-12 text-slate-900" />
          </div>
        </div>
      </div>
    </div>
  );
}