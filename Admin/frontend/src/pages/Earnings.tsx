import React from 'react';
import { CircleDollarSign, TrendingUp, Wallet, ArrowDownRight, ArrowUpRight } from 'lucide-react';

export const Earnings: React.FC = () => {
  return (
    <div className="p-8 max-w-[1400px] mx-auto fade-in animate-in slide-in-from-bottom-2 duration-300">
      <div className="mb-8">
        <h1 className="text-3xl font-extrabold text-slate-800 tracking-tight flex items-center gap-3">
           <span className="p-2 bg-emerald-100 text-emerald-600 rounded-[1.25rem]"><CircleDollarSign className="h-6 w-6 stroke-[2.5]" /></span>
           Earnings & Finance
        </h1>
        <p className="text-slate-500 font-medium text-sm mt-3 ml-[3.25rem]">Manage platform revenue, commissions, and payouts</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        <div className="bg-gradient-to-br from-emerald-600 to-teal-800 text-white p-6 rounded-2xl shadow-md border border-emerald-500/20 relative overflow-hidden">
           <Wallet className="absolute -bottom-4 -right-4 h-24 w-24 text-white/10" />
           <p className="text-sm font-bold text-emerald-100 uppercase tracking-widest relative z-10">Total Platform Revenue</p>
           <p className="text-4xl font-extrabold tabular-nums mt-1 relative z-10">$142,500.00</p>
           <p className="text-xs font-semibold mt-3 text-emerald-200 flex items-center gap-1 relative z-10"><ArrowUpRight className="h-4 w-4" /> +15.3% this month</p>
        </div>
        <div className="bg-white p-6 rounded-2xl shadow-sm border border-slate-200/60">
           <p className="text-sm font-bold text-slate-500 uppercase tracking-widest">Commission Earned</p>
           <p className="text-4xl font-extrabold text-slate-800 tabular-nums mt-1">$21,375.00</p>
           <p className="text-xs font-semibold mt-3 text-emerald-500 flex items-center gap-1"><TrendingUp className="h-4 w-4" /> Stable at 15% rate</p>
        </div>
        <div className="bg-white p-6 rounded-2xl shadow-sm border border-slate-200/60">
           <p className="text-sm font-bold text-slate-500 uppercase tracking-widest">Pending Doctor Payouts</p>
           <p className="text-4xl font-extrabold text-slate-800 tabular-nums mt-1">$8,450.00</p>
           <button className="mt-3 bg-slate-900 hover:bg-slate-800 text-white text-xs font-bold px-4 py-1.5 rounded-lg transition-colors flex items-center gap-1.5 w-max">
             <ArrowDownRight className="h-3.5 w-3.5" /> Process Payouts
           </button>
        </div>
      </div>

      <div className="bg-white rounded-2xl shadow-sm border border-slate-200/60 overflow-hidden mb-6">
        <div className="px-6 py-5 border-b border-slate-100 flex items-center justify-between">
           <h2 className="text-base font-extrabold text-slate-800">Recent Transactions</h2>
        </div>
        <table className="w-full text-left">
           <thead className="bg-slate-50 border-b border-slate-100">
             <tr className="text-slate-500 font-bold uppercase tracking-wider text-[11px]">
               <th className="px-6 py-4">Transaction ID</th>
               <th className="px-6 py-4">Source</th>
               <th className="px-6 py-4">Gross Amount</th>
               <th className="px-6 py-4">Platform Fee (15%)</th>
               <th className="px-6 py-4">Net Payout</th>
               <th className="px-6 py-4">Status</th>
             </tr>
           </thead>
           <tbody className="divide-y divide-slate-100 text-sm">
             <tr className="hover:bg-slate-50/50">
               <td className="px-6 py-4 font-mono font-bold text-slate-600">TXN-8821</td>
               <td className="px-6 py-4 font-semibold text-slate-800">Dr. Sarah Jenkins</td>
               <td className="px-6 py-4 font-bold text-slate-600">$150.00</td>
               <td className="px-6 py-4 font-bold text-emerald-600">+$22.50</td>
               <td className="px-6 py-4 font-bold text-slate-600">$127.50</td>
               <td className="px-6 py-4"><span className="px-2.5 py-1 rounded-md text-[10px] uppercase font-extrabold tracking-widest bg-emerald-100 text-emerald-700">Completed</span></td>
             </tr>
             <tr className="hover:bg-slate-50/50">
               <td className="px-6 py-4 font-mono font-bold text-slate-600">TXN-8820</td>
               <td className="px-6 py-4 font-semibold text-slate-800">City Lab Referral</td>
               <td className="px-6 py-4 font-bold text-slate-600">$200.00</td>
               <td className="px-6 py-4 font-bold text-emerald-600">+$30.00</td>
               <td className="px-6 py-4 font-bold text-slate-600">$170.00</td>
               <td className="px-6 py-4"><span className="px-2.5 py-1 rounded-md text-[10px] uppercase font-extrabold tracking-widest bg-blue-100 text-blue-700">Pending</span></td>
             </tr>
           </tbody>
        </table>
      </div>
    </div>
  );
};
