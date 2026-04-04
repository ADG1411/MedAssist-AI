import React from 'react';
import { CircleDollarSign, TrendingUp, Wallet, ArrowDownRight, ArrowUpRight } from 'lucide-react';
import { BudgetCard } from '@/components/ui/budget-card';

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

      <div className="mb-8">
        <BudgetCard
          month="April"
          totalBudget={150000}
          spentAmount={142500}
          breakdown={[
            { label: "Platform Revenue", amount: 100000, color: "#059669" },
            { label: "Commission Earned", amount: 21375, color: "#10B981" },
            { label: "Doctor Payouts", amount: 21125, color: "#34D399" }
          ]}
          onMonthChange={(m) => console.log('Month changed to', m)}
          onViewDetails={() => console.log('View details clicked')}
        />
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
