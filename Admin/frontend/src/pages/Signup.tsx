import React, { useState } from 'react';
import { supabase } from '../lib/supabase';
import { useNavigate, Link } from 'react-router-dom';
import toast from 'react-hot-toast';
import { UserPlus, Mail, Lock, UserCircle } from 'lucide-react';
import logoUrl from '../assets/logo.svg';

export const Signup: React.FC = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [fullName, setFullName] = useState('');
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();

  const handleSignup = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    
    // Call Supabase out-of-the-box Auth
    const { data: authData, error: authError } = await supabase.auth.signUp({ 
      email, 
      password,
      options: {
        data: { full_name: fullName, role: 'admin' }
      }
    });

    if (authError) {
      toast.error(authError.message);
      setLoading(false);
      return;
    }

    if (authData.session) {
      toast.success('Admin account registered! Redirecting...');
      navigate('/');
    } else if (authData.user) {
      toast.success('Registration successful! Please check your email to verify your account, or log in if auto-verify is on.', { duration: 6000 });
      navigate('/login');
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-[#f9fafb] p-4 font-sans">
      <div className="max-w-md w-full bg-white rounded-3xl shadow-lg border border-slate-200/60 p-8">
        <div className="flex flex-col items-center mb-8">
          <img src={logoUrl} alt="MedAssist" className="h-14 w-14 mb-3 opacity-90 grayscale-[50%]" onError={(e) => e.currentTarget.style.display = 'none'} />
          <h2 className="text-2xl font-extrabold text-slate-800 tracking-tight">Create Admin Profile</h2>
          <p className="text-slate-500 font-medium text-sm mt-1">Register for portal access</p>
        </div>

        <form onSubmit={handleSignup} className="space-y-4">
          <div>
            <label className="block text-xs font-bold text-slate-500 uppercase tracking-widest mb-2">Full Name</label>
            <div className="relative">
              <UserCircle className="absolute left-4 top-1/2 -translate-y-1/2 h-5 w-5 text-slate-400" />
              <input 
                type="text" 
                required 
                className="w-full pl-11 pr-4 py-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-teal-500/20 font-medium text-slate-700 outline-none transition" 
                placeholder="Eleanor Shellstrop" 
                value={fullName} onChange={e => setFullName(e.target.value)} 
              />
            </div>
          </div>

          <div>
            <label className="block text-xs font-bold text-slate-500 uppercase tracking-widest mb-2">Email</label>
            <div className="relative">
              <Mail className="absolute left-4 top-1/2 -translate-y-1/2 h-5 w-5 text-slate-400" />
              <input 
                type="email" 
                required 
                className="w-full pl-11 pr-4 py-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-teal-500/20 font-medium text-slate-700 outline-none transition" 
                placeholder="admin@medassist.ai" 
                value={email} onChange={e => setEmail(e.target.value)} 
              />
            </div>
          </div>

          <div>
            <label className="block text-xs font-bold text-slate-500 uppercase tracking-widest mb-2">Admin Password</label>
            <div className="relative">
              <Lock className="absolute left-4 top-1/2 -translate-y-1/2 h-5 w-5 text-slate-400" />
              <input 
                type="password" 
                required minLength={6}
                className="w-full pl-11 pr-4 py-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-teal-500/20 font-medium text-slate-700 outline-none transition" 
                placeholder="Create a strong password" 
                value={password} onChange={e => setPassword(e.target.value)} 
              />
            </div>
          </div>

          <button
            type="submit"
            disabled={loading}
            className="w-full bg-slate-800 hover:bg-slate-900 text-white font-bold py-3.5 rounded-xl transition duration-200 shadow-md shadow-slate-800/20 flex items-center justify-center gap-2 mt-4"
          >
            {loading ? 'Creating Profile...' : <><UserPlus className="h-5 w-5" /> Register Admin</>}
          </button>
        </form>

        <p className="mt-6 text-center text-sm font-medium text-slate-500">
          Already authorized? <Link to="/login" className="text-slate-800 hover:underline font-bold">Sign In here</Link>
        </p>
      </div>
    </div>
  );
};
