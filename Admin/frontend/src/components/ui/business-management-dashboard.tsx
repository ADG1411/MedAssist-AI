import { XAxis, YAxis, Tooltip, ResponsiveContainer, BarChart, Bar, CartesianGrid } from 'recharts';
import { Briefcase, CreditCard, DollarSign, Users, TrendingUp, Download } from 'lucide-react';

const data = [
  { name: 'Jan', value: 4000 },
  { name: 'Feb', value: 3000 },
  { name: 'Mar', value: 5000 },
  { name: 'Apr', value: 4500 },
  { name: 'May', value: 6000 },
  { name: 'Jun', value: 7000 },
  { name: 'Jul', value: 8500 },
];

export function BusinessManagementDashboard() {
  return (
    <div className="space-y-6 w-full mt-8 pt-8 border-t border-slate-200/80 fade-in animate-in slide-in-from-bottom-2 duration-300">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-2xl font-bold tracking-tight text-slate-800">Business Management</h2>
          <p className="text-slate-500 text-sm font-medium mt-1">Financial overviews and business growth metrics</p>
        </div>
        <button className="flex items-center gap-2 bg-slate-900 hover:bg-slate-800 text-white px-4 py-2 rounded-xl text-sm font-semibold transition-colors shadow-sm">
          <Download className="h-4 w-4" /> Export Data
        </button>
      </div>

      <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-4">
         <div className="bg-white p-6 rounded-2xl border border-slate-200/60 shadow-sm ring-1 ring-slate-100 hover:border-slate-300 transition-colors">
           <div className="flex flex-row items-center justify-between pb-2">
             <h3 className="text-sm font-bold text-slate-500">Total Revenue</h3>
             <DollarSign className="h-4 w-4 text-slate-400" />
           </div>
           <div className="text-2xl font-extrabold text-slate-800 tabular-nums">$45,231.89</div>
           <p className="text-xs text-emerald-500 font-bold mt-1 flex items-center gap-1"><TrendingUp className="h-3 w-3"/> +20.1% from last month</p>
         </div>
         <div className="bg-white p-6 rounded-2xl border border-slate-200/60 shadow-sm ring-1 ring-slate-100 hover:border-slate-300 transition-colors">
           <div className="flex flex-row items-center justify-between pb-2">
             <h3 className="text-sm font-bold text-slate-500">Subscriptions</h3>
             <Users className="h-4 w-4 text-slate-400" />
           </div>
           <div className="text-2xl font-extrabold text-slate-800 tabular-nums">+2350</div>
           <p className="text-xs text-emerald-500 font-bold mt-1 flex items-center gap-1"><TrendingUp className="h-3 w-3"/> +180 since last hour</p>
         </div>
         <div className="bg-white p-6 rounded-2xl border border-slate-200/60 shadow-sm ring-1 ring-slate-100 hover:border-slate-300 transition-colors">
           <div className="flex flex-row items-center justify-between pb-2">
             <h3 className="text-sm font-bold text-slate-500">Sales</h3>
             <CreditCard className="h-4 w-4 text-slate-400" />
           </div>
           <div className="text-2xl font-extrabold text-slate-800 tabular-nums">+12,234</div>
           <p className="text-xs text-emerald-500 font-bold mt-1 flex items-center gap-1"><TrendingUp className="h-3 w-3"/> +19% from last month</p>
         </div>
         <div className="bg-white p-6 rounded-2xl border border-slate-200/60 shadow-sm ring-1 ring-slate-100 hover:border-slate-300 transition-colors">
           <div className="flex flex-row items-center justify-between pb-2">
             <h3 className="text-sm font-bold text-slate-500">Active Partners</h3>
             <Briefcase className="h-4 w-4 text-slate-400" />
           </div>
           <div className="text-2xl font-extrabold text-slate-800 tabular-nums">+573</div>
           <p className="text-xs text-emerald-500 font-bold mt-1 flex items-center gap-1"><TrendingUp className="h-3 w-3"/> +201 since last week</p>
         </div>
      </div>

      <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-7">
        <div className="bg-white p-6 rounded-2xl border border-slate-200/60 shadow-sm ring-1 ring-slate-100 lg:col-span-4 h-[380px] flex flex-col">
          <div className="mb-4">
             <h3 className="text-lg font-bold tracking-tight text-slate-800">Business Overview</h3>
          </div>
          <div className="flex-1 w-full pl-0">
             <ResponsiveContainer width="100%" height="100%">
               <BarChart data={data} margin={{ top: 0, right: 0, left: -20, bottom: 0 }}>
                 <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#e2e8f0" />
                 <XAxis 
                   dataKey="name" 
                   stroke="#64748b" 
                   fontSize={12} 
                   fontWeight={600}
                   tickLine={false} 
                   axisLine={false} 
                   dy={10} 
                 />
                 <YAxis 
                   stroke="#64748b" 
                   fontSize={12} 
                   fontWeight={600}
                   tickLine={false} 
                   axisLine={false} 
                   tickFormatter={(value) => `$${value}`} 
                 />
                 <Tooltip 
                   cursor={{fill: '#f8fafc'}} 
                   contentStyle={{ borderRadius: '12px', border: '1px solid #f1f5f9', boxShadow: '0 4px 6px -1px rgb(0 0 0 / 0.1)' }} 
                   itemStyle={{ color: '#0f172a', fontWeight: 'bold' }}
                 />
                 <Bar dataKey="value" fill="#0f172a" radius={[6, 6, 0, 0]} barSize={40} />
               </BarChart>
             </ResponsiveContainer>
          </div>
        </div>
        <div className="bg-white p-6 rounded-2xl border border-slate-200/60 shadow-sm ring-1 ring-slate-100 lg:col-span-3">
          <div className="mb-4">
             <h3 className="text-lg font-bold tracking-tight text-slate-800">Recent Sales</h3>
             <p className="text-sm font-medium text-slate-500 mt-1">You made 265 sales this month.</p>
          </div>
          <div className="space-y-6 mt-6">
            {[
              { name: "Olivia Martin", email: "olivia.martin@email.com", amount: "+$1,999.00" },
              { name: "Jackson Lee", email: "jackson.lee@email.com", amount: "+$39.00" },
              { name: "Isabella Nguyen", email: "isabella.nguyen@email.com", amount: "+$299.00" },
              { name: "William Kim", email: "will@email.com", amount: "+$99.00" },
              { name: "Sofia Davis", email: "sofia.davis@email.com", amount: "+$39.00" },
            ].map((sale, i) => (
              <div key={i} className="flex items-center">
                <div className="h-9 w-9 rounded-full bg-slate-100 ring-1 ring-slate-200 flex items-center justify-center font-extrabold text-slate-700 text-xs">
                   {sale.name.split(' ').map(n=>n[0]).join('')}
                </div>
                <div className="ml-4 space-y-0.5">
                  <p className="text-sm font-bold text-slate-800 leading-none">{sale.name}</p>
                  <p className="text-xs font-medium text-slate-500">{sale.email}</p>
                </div>
                <div className="ml-auto font-extrabold text-slate-800 tabular-nums">
                  {sale.amount}
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}