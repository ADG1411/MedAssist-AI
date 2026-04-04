import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { Eye, EyeOff } from 'lucide-react';
import { authService } from '../services/authService';

const LoginPage = () => {
  const [showPassword, setShowPassword] = useState(false);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [errorMsg, setErrorMsg] = useState('');
  const navigate = useNavigate();

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setErrorMsg('');
    
    // Call Supabase Auth
    const { data, error } = await authService.login(email, password);
    
    setLoading(false);
    
    if (error) {
      setErrorMsg(error.message);
    } else {
      console.log("Logged in:", data.user);
      navigate('/dashboard');
    }
  };

  const handleOAuthLogin = async (provider: 'google' | 'apple') => {
    try {
      const { error } = provider === 'google' 
        ? await authService.signInWithGoogle()
        : await authService.signInWithApple();
        
      if (error) throw error;
    } catch (err: unknown) {
      if (err instanceof Error) {
        setErrorMsg(err.message || `Failed to authenticate with ${provider}`);
      } else {
        setErrorMsg(`Failed to authenticate with ${provider}`);
      }
    }
  };

  return (
    <div className="flex bg-[#EBF4FE] overflow-y-auto justify-center min-h-screen py-10 px-4 font-sans text-slate-800 relative w-full selection:bg-brand-blue selection:text-white md:items-center items-start">
      {/* Background Gradient & Glow (Matched from screenshot) */}
      <div className="absolute inset-0 bg-gradient-to-b from-[#D4E0FD] via-[#f1f5fe] to-[#FAFBFF] pointer-events-none" />

      {/* Main Container */}
      <div className="relative z-10 w-full max-w-[420px] mx-auto min-h-[700px] flex flex-col justify-start">

        {/* Logo Section */}
        <div className="flex flex-col items-center justify-center space-y-2 mb-12 select-none cursor-pointer">
          <div aria-label="Portal Logo">
            <img src="/logo.svg" alt="MedAssist Logo" className="w-20 h-20 object-contain drop-shadow-sm" />
          </div>
          <span className="font-bold text-[36px] tracking-tight text-[#0A2540]">MedAssist</span>
        </div>

        {/* Texts */}
        <div className="text-center mb-10">
          <h1 className="text-3xl font-bold mb-3">Welcome Back!</h1>
          <p className="text-slate-500 font-medium">Ready to step up your style? Log in now!</p>
        </div>

        {/* Form elements */}
        <form onSubmit={handleLogin} className="flex flex-col w-full px-2">
          
          {errorMsg && (
            <div className="mb-4 p-3 bg-red-50 text-red-600 rounded-lg text-sm border border-red-100">
              {errorMsg}
            </div>
          )}

          <div className="mb-4">
            <label className="block text-slate-800 text-[15px] font-medium mb-2 pl-1">Email</label>
            <input 
              type="email" 
              placeholder="Enter your email"
              className="auth-input"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
            />
          </div>

          <div className="mb-4 relative">
            <label className="block text-slate-800 text-[15px] font-medium mb-2 pl-1">Password</label>
            <div className="relative">
              <input 
                type={showPassword ? "text" : "password"} 
                placeholder="Enter your password"
                className="auth-input pr-12"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
              />
              <button 
                type="button"
                className="absolute right-4 top-1/2 -translate-y-1/2 text-slate-500 hover:text-slate-700 p-2"
                onClick={() => setShowPassword(!showPassword)}
                aria-label={showPassword ? "Hide password" : "Show password"}
              >
                {showPassword ? <EyeOff size={18} /> : <Eye size={18} strokeWidth={2.2} />}
              </button>
            </div>
          </div>

          <div className="flex items-center justify-between mb-8 px-1">
            <label className="flex items-center cursor-pointer">
              <div className="relative flex items-center">
                <input type="checkbox" className="peer w-5 h-5 opacity-0 absolute cursor-pointer rounded-sm" defaultChecked />
                <div className="w-[18px] h-[18px] border-2 border-emerald-500 rounded flex items-center justify-center bg-white peer-checked:bg-emerald-50 peer-checked:border-emerald-500 transition-colors">
                  <svg className="w-3.5 h-3.5 text-emerald-600 opacity-0 peer-checked:opacity-100 transition-opacity" viewBox="0 0 20 20" fill="currentColor">
                    <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" />
                  </svg>
                </div>
              </div>
              <span className="ml-2 text-[14px] text-slate-700 font-medium select-none">Remember me</span>
            </label>
            <a href="#" className="text-orange-600 text-[14px] font-medium hover:underline hover:text-orange-700 transition-colors">
              Forgot password
            </a>
          </div>

          <button 
             type="submit" 
             disabled={loading}
             className="w-full bg-[#1A6BFF] hover:bg-[#1556CC] text-white font-medium text-[16px] py-4 rounded-full transition-all shadow-soft ring-2 ring-offset-2 ring-transparent ring-offset-slate-50 hover:ring-brand-blue outline-none transform active:scale-[0.98] disabled:opacity-70 disabled:cursor-not-allowed"
          >
            {loading ? "Logging in..." : "Login"}
          </button>
        </form>

        {/* Separator */}
        <div className="flex items-center justify-center mt-12 mb-8 select-none opacity-80 px-2">
          <div className="h-px bg-slate-300 flex-grow rounded"></div>
          <span className="px-3 text-slate-500 font-medium text-[15px]">Or</span>
          <div className="h-px bg-slate-300 flex-grow rounded"></div>
        </div>

        {/* Social Logins */}
        <div className="flex justify-center space-x-6 mb-12">
          <button 
            type="button"
            onClick={() => handleOAuthLogin('apple')}
            className="w-[52px] h-[52px] rounded-full bg-white border border-slate-200 flex items-center justify-center hover:bg-slate-50 transition-colors shadow-sm"
          >
            <svg width="22" height="22" viewBox="0 0 24 24" fill="black"><path d="M17.05 20.28c-.98.95-2.05.8-3.08.35-1.09-.46-2.09-.48-3.24 0-1.08.45-2.1.58-3.03-.36C3.9 16.29 2.5 10.74 5.38 7.37c1.3-1.57 2.92-2.15 4.54-2.11 1.48.04 2.76.84 3.52.84.77 0 2.27-1.05 4.09-.9 1.4.05 2.66.52 3.53 1.54-3.04 1.76-2.58 5.86.38 7.07-.68 1.83-1.61 3.75-3.39 5.42v1.05zM12.03 5.4c-.11-1.74 1.25-3.5 3.01-3.69.21 1.84-1.39 3.55-3.01 3.69z"/></svg>
          </button>
          <button 
            type="button"
            onClick={() => handleOAuthLogin('google')}
            className="w-[52px] h-[52px] rounded-full bg-white border border-slate-200 flex items-center justify-center hover:bg-slate-50 transition-colors shadow-sm"
          >
            <svg viewBox="0 0 24 24" width="22" height="22" xmlns="http://www.w3.org/2000/svg"><path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" fill="#4285F4"/><path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" fill="#34A853"/><path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z" fill="#FBBC05"/><path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" fill="#EA4335"/><path d="M1 1h22v22H1z" fill="none"/></svg>
          </button>
          <button 
            type="button"
            className="w-[52px] h-[52px] rounded-full bg-white border border-slate-200 flex items-center justify-center hover:bg-slate-50 transition-colors shadow-sm"
          >
            <svg width="22" height="22" viewBox="0 0 24 24" fill="#1877F2" xmlns="http://www.w3.org/2000/svg"><path d="M12.0003 0C5.37257 0 0 5.37257 0 12.0003C0 17.9897 4.38827 22.9542 10.1253 23.854V15.468H7.07817V12.0003H10.1253V9.35919C10.1253 6.35345 11.916 4.68744 14.6563 4.68744C15.9686 4.68744 17.3438 4.92193 17.3438 4.92193V7.87529H15.8306C14.3392 7.87529 13.8752 8.80003 13.8752 9.74868V12.0003H17.2029L16.671 15.468H13.8752V23.854C19.6121 22.9542 24.0003 17.9897 24.0003 12.0003C24.0003 5.37257 18.6277 0 12.0003 0Z"/></svg>
          </button>
        </div>

        {/* Footer */}
        <div className="mt-auto pb-6 text-center text-slate-700 font-medium text-[15px]">
          Don't have an account? <Link to="/signup" className="text-[#1A6BFF] hover:underline">Sign UP</Link>
        </div>

      </div>
    </div>
  );
};

export default LoginPage;