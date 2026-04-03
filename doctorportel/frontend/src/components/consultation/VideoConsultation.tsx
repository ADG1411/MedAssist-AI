import { useState, useEffect } from 'react';
import { Mic, MicOff, Video, VideoOff, PhoneOff, MonitorUp, Focus } from 'lucide-react';
import { cn } from '../../layouts/DashboardLayout';

interface Props {
  patientName: string;
}

export function VideoConsultation({ patientName }: Props) {
  const [callState, setCallState] = useState<'waiting' | 'joining' | 'connected' | 'ended'>('joining');
  const [micOn, setMicOn] = useState(true);
  const [camOn, setCamOn] = useState(true);
  const [duration, setDuration] = useState(0);

  // Mock progression
  useEffect(() => {
    if (callState === 'joining') {
      const t = setTimeout(() => setCallState('connected'), 3000);
      return () => clearTimeout(t);
    }
    if (callState === 'connected') {
      const interval = setInterval(() => setDuration(d => d + 1), 1000);
      return () => clearInterval(interval);
    }
  }, [callState]);

  const formatTime = (secs: number) => {
    const m = Math.floor(secs / 60).toString().padStart(2, '0');
    const s = (secs % 60).toString().padStart(2, '0');
    return `${m}:${s}`;
  };

  const endCall = () => setCallState('ended');

  return (
    <div className="h-full flex flex-col bg-slate-900 relative overflow-hidden">
      
      {/* Top Bar */}
      <div className="absolute top-0 inset-x-0 p-4 z-10 flex justify-between items-center bg-gradient-to-b from-black/60 to-transparent">
        <div className="flex items-center gap-2 text-white">
          <div className="w-2 h-2 rounded-full bg-red-500 animate-pulse" />
          <span className="text-[12px] font-bold tracking-widest uppercase">
            {callState === 'connected' ? formatTime(duration) : callState === 'joining' ? 'Connecting...' : 'Call Ended'}
          </span>
        </div>
        <button className="bg-white/10 hover:bg-white/20 text-white rounded-xl p-2 transition-colors border border-white/10">
          <Focus className="w-4 h-4" />
        </button>
      </div>

      {/* Main Video Area */}
      <div className="flex-1 relative flex items-center justify-center">
        {callState === 'joining' && (
          <div className="flex flex-col items-center gap-4 text-white/50">
            <div className="w-16 h-16 rounded-full border-2 border-slate-700 border-t-indigo-500 animate-spin" />
            <p className="text-sm font-bold tracking-widest uppercase animate-pulse">Waiting for {patientName}</p>
          </div>
        )}

        {callState === 'connected' && (
          <>
            {/* Mock Patient Video stream */}
            <div className="absolute inset-0 bg-slate-800">
              <img 
                src="https://images.unsplash.com/photo-1544723795-3cg2aa19747?auto=format&fit=crop&q=80&w=800" 
                alt="Patient Video"
                className="w-full h-full object-cover opacity-80"
              />
            </div>
            
            {/* My Video PiP */}
            <div className="absolute bottom-6 right-6 w-32 md:w-48 aspect-[3/4] bg-slate-800 rounded-2xl border-2 border-slate-700 overflow-hidden shadow-2xl z-10 transition-all hover:scale-105 cursor-pointer">
               <img 
                src="https://images.unsplash.com/photo-1559839734-2b71ea197ec2?auto=format&fit=crop&q=80&w=300"
                alt="My Video"
                className={cn("w-full h-full object-cover", !camOn && "hidden")}
              />
              {!camOn && (
                <div className="absolute inset-0 flex items-center justify-center bg-slate-800 text-white/30">
                  <VideoOff className="w-8 h-8" />
                </div>
              )}
            </div>
          </>
        )}

        {callState === 'ended' && (
          <div className="flex flex-col items-center gap-2 text-white/50">
            <PhoneOff className="w-12 h-12 mb-2" />
            <p className="text-xl font-bold tracking-widest uppercase">Consultation Ended</p>
            <p className="text-sm">Duration: {formatTime(duration)}</p>
          </div>
        )}
      </div>

      {/* Controls */}
      {callState !== 'ended' && (
        <div className="bg-slate-900/80 backdrop-blur-md p-4 border-t border-white/5 flex items-center justify-center gap-4 z-10">
          <button 
            onClick={() => setMicOn(x => !x)}
            className={cn("w-12 h-12 rounded-full flex items-center justify-center transition-colors", micOn ? "bg-slate-700 hover:bg-slate-600 text-white" : "bg-red-500/20 text-red-500 border border-red-500/50 hover:bg-red-500/30")}
          >
            {micOn ? <Mic className="w-5 h-5" /> : <MicOff className="w-5 h-5" />}
          </button>

          <button 
            onClick={() => setCamOn(x => !x)}
            className={cn("w-12 h-12 rounded-full flex items-center justify-center transition-colors", camOn ? "bg-slate-700 hover:bg-slate-600 text-white" : "bg-red-500/20 text-red-500 border border-red-500/50 hover:bg-red-500/30")}
          >
            {camOn ? <Video className="w-5 h-5" /> : <VideoOff className="w-5 h-5" />}
          </button>

          <button className="w-12 h-12 rounded-full flex items-center justify-center bg-slate-700 hover:bg-slate-600 text-white transition-colors">
            <MonitorUp className="w-5 h-5" />
          </button>

          <button 
            onClick={endCall}
            className="w-14 h-14 rounded-full flex items-center justify-center bg-red-500 hover:bg-red-600 text-white focus:ring-4 ring-red-500/30 transition-all"
          >
            <PhoneOff className="w-5 h-5" />
          </button>
        </div>
      )}
    </div>
  );
}
