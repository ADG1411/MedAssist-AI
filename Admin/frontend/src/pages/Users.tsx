import React, { useState } from 'react';
import { Search, Filter, MoreHorizontal, UserCheck, UserX, ShieldBan } from 'lucide-react';

const usersData = [
  { id: '#DOC-101', name: 'Dr. Sarah Jenkins', role: 'Doctor', specialty: 'Cardiologist', status: 'Active', joined: '12 Jan 2026' },
  { id: '#DOC-102', name: 'Dr. Emily Chen', role: 'Doctor', specialty: 'Neurologist', status: 'Pending', joined: '03 Apr 2026' },
  { id: '#PAT-992', name: 'Michael Ross', role: 'Patient', specialty: '-', status: 'Active', joined: '15 Feb 2026' },
  { id: '#PAT-993', name: 'Anna Lee', role: 'Patient', specialty: '-', status: 'Suspended', joined: '10 Mar 2026' },
  { id: '#HOS-004', name: 'City Central Hospital', role: 'Hospital', specialty: 'General', status: 'Active', joined: '01 Jan 2026' },
];

export const Users: React.FC = () => {
  const [activeTab, setActiveTab] = useState('All');
  
  const filteredUsers = activeTab === 'All' ? usersData : usersData.filter(u => u.role === activeTab);

  return (
    <div className="p-8 max-w-[1400px] mx-auto fade-in animate-in slide-in-from-bottom-2 duration-300">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 mb-8">
        <div>
          <h1 className="text-3xl font-extrabold text-slate-800 tracking-tight">User Management</h1>
          <p className="text-slate-500 font-medium text-sm mt-1">Manage doctors, patients, and partner hospitals</p>
        </div>
        <div className="flex items-center gap-3">
          <button className="bg-white border border-slate-200 text-slate-700 hover:bg-slate-50 font-medium px-4 py-2 rounded-xl shadow-sm text-sm transition-all focus:ring-4 focus:ring-slate-100 flex items-center gap-2">
            <Filter className="h-4 w-4" /> Filter
          </button>
          <button className="bg-teal-600 hover:bg-teal-700 text-white font-medium px-5 py-2 rounded-xl shadow-sm text-sm transition-all focus:ring-4 focus:ring-teal-500/20 active:scale-95 flex items-center gap-2">
             +  Add New User
          </button>
        </div>
      </div>

      <div className="bg-white rounded-2xl shadow-sm border border-slate-200/60 overflow-hidden">
        <div className="p-5 border-b border-slate-100 flex flex-col sm:flex-row sm:items-center justify-between gap-4 bg-slate-50/50">
          <div className="flex p-1 bg-slate-100 rounded-xl overflow-hidden self-start">
            {['All', 'Doctor', 'Patient', 'Hospital'].map(tab => (
              <button 
                key={tab}
                onClick={() => setActiveTab(tab)}
                className={`px-5 py-1.5 text-sm font-semibold rounded-lg transition-all ${
                  activeTab === tab 
                    ? 'bg-white text-teal-600 shadow-sm ring-1 ring-slate-200/50' 
                    : 'text-slate-500 hover:text-slate-700 hover:bg-slate-200/50'
                }`}
              >
                {tab}
              </button>
            ))}
          </div>

          <div className="relative max-w-sm w-full">
            <input 
              type="text" 
              placeholder="Search users..." 
              className="w-full bg-white border border-slate-200 rounded-xl py-2 pl-10 pr-4 text-sm focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all outline-none"
            />
            <Search className="h-4 w-4 text-slate-400 absolute left-3.5 top-1/2 transform -translate-y-1/2" />
          </div>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="bg-white border-b border-slate-100 text-slate-500 text-xs uppercase tracking-wider font-bold">
                <th className="px-6 py-4">User ID</th>
                <th className="px-6 py-4">Name / Entity</th>
                <th className="px-6 py-4">Role</th>
                <th className="px-6 py-4">Specialty</th>
                <th className="px-6 py-4">Joined</th>
                <th className="px-6 py-4">Status</th>
                <th className="px-6 py-4 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {filteredUsers.map((user, idx) => (
                <tr key={idx} className="hover:bg-slate-50/80 transition-colors group">
                  <td className="px-6 py-4 text-sm font-semibold text-slate-600">{user.id}</td>
                  <td className="px-6 py-4 text-sm font-bold text-slate-800">{user.name}</td>
                  <td className="px-6 py-4 text-sm">
                    <span className="bg-slate-100 text-slate-600 font-bold px-2.5 py-1 rounded-md text-[11px] uppercase tracking-wide">
                      {user.role}
                    </span>
                  </td>
                  <td className="px-6 py-4 text-sm text-slate-500 font-medium">{user.specialty}</td>
                  <td className="px-6 py-4 text-sm text-slate-500 font-medium">{user.joined}</td>
                  <td className="px-6 py-4">
                    <span className={`inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[11px] font-bold uppercase tracking-wider ${
                      user.status === 'Active' ? 'bg-emerald-50 text-emerald-700 ring-1 ring-emerald-600/20' :
                      user.status === 'Pending' ? 'bg-amber-50 text-amber-700 ring-1 ring-amber-600/20' :
                      'bg-rose-50 text-rose-700 ring-1 ring-rose-600/20'
                    }`}>
                      {user.status === 'Active' && <div className="h-1.5 w-1.5 rounded-full bg-emerald-500"></div>}
                      {user.status === 'Pending' && <div className="h-1.5 w-1.5 rounded-full bg-amber-500"></div>}
                      {user.status === 'Suspended' && <div className="h-1.5 w-1.5 rounded-full bg-rose-500"></div>}
                      {user.status}
                    </span>
                  </td>
                  <td className="px-6 py-4 text-right">
                    <div className="flex items-center justify-end gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
                      {user.status === 'Pending' && (
                        <button className="p-1.5 text-emerald-600 hover:bg-emerald-50 rounded-lg transition" title="Approve">
                          <UserCheck className="h-4 w-4" />
                        </button>
                      )}
                      {user.status === 'Active' && (
                        <button className="p-1.5 text-rose-600 hover:bg-rose-50 rounded-lg transition" title="Suspend">
                          <ShieldBan className="h-4 w-4" />
                        </button>
                      )}
                      <button className="p-1.5 text-slate-400 hover:text-slate-600 hover:bg-slate-100 rounded-lg transition">
                        <MoreHorizontal className="h-4 w-4" />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        <div className="p-4 border-t border-slate-100 bg-slate-50 flex items-center justify-between text-sm text-slate-500">
           <span>Showing 1 to 5 of 5 entries</span>
           <div className="flex gap-1">
             <button className="px-3 py-1 bg-white border border-slate-200 rounded text-slate-400 cursor-not-allowed">Prevent</button>
             <button className="px-3 py-1 bg-white border border-slate-200 rounded hover:bg-slate-100 text-slate-700 font-medium transition">Next</button>
           </div>
        </div>
      </div>
    </div>
  );
};
