import React, { useState } from 'react';
import { supabase } from '../lib/supabase';
import { useNavigate, Link } from 'react-router-dom';
import toast from 'react-hot-toast';
import { LogIn, Mail, Lock } from 'lucide-react';
import logoUrl from '../assets/logo.svg';

export const Login: React.FC = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    const { error } = await supabase.auth.signInWithPassword({ email, password });
    
    if (error) {
      toast.error(error.message);
    } else {
      toast.success('Successfully logged in');
      navigate('/');
    }
    setLoading(false);
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-[#f9fafb] p-4 font-sans">
      <div className="max-w-md w-full bg-white rounded-3xl shadow-lg border border-slate-200/60 p-8">
        <div className="flex flex-col items-center mb-8">
          <img src={logoUrl} alt="MedAssist Logo" className="h-16 w-16 mb-4" onError={(e) => e.currentTarget.style.display = 'none'} />
          <h2 className="text-3xl font-extrabold text-slate-800 tracking-tight">Admin Portal</h2>
          <p className="text-slate-500 font-medium text-sm mt-2">Sign in to your professional account</p>
        </div>

        <form onSubmit={handleLogin} className="space-y-5">
          <div>
            <label className="block text-xs font-bold text-slate-500 uppercase tracking-widest mb-2">Email Address</label>
            <div className="relative">
              <Mail className="absolute left-4 top-1/2 -translate-y-1/2 h-5 w-5 text-slate-400" />
              <input
                type="email"
                required
                className="w-full pl-11 pr-4 py-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all outline-none font-medium text-slate-700"
                placeholder="admin@medassist.ai"
                value={email}
                onChange={e => setEmail(e.target.value)}
              />
            </div>
          </div>

          <div>
            <label className="block text-xs font-bold text-slate-500 uppercase tracking-widest mb-2">Password</label>
            <div className="relative">
              <Lock className="absolute left-4 top-1/2 -translate-y-1/2 h-5 w-5 text-slate-400" />
              <input
                type="password"
                required
                className="w-full pl-11 pr-4 py-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all outline-none font-medium text-slate-700"
                placeholder="••••••••"
                value={password}
                onChange={e => setPassword(e.target.value)}
              />
            </div>
          </div>

          <button
            type="submit"
            disabled={loading}
            className="w-full bg-teal-600 hover:bg-teal-700 text-white font-bold py-3.5 rounded-xl transition duration-200 shadow-md shadow-teal-600/20 flex items-center justify-center gap-2 disabled:opacity-70 disabled:cursor-not-allowed"
          >
            {loading ? 'Authenticating...' : <><LogIn className="h-5 w-5" /> Sign In</>}
          </button>
        </form>
        
        <p className="mt-8 text-center text-sm font-medium text-slate-500">
          Not registered? <Link to="/signup" className="text-teal-600 hover:text-teal-700 hover:underline">Request an account</Link>
        </p>
      </div>
    </div>
  );
};
