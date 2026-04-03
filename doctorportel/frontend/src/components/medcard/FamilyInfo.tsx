import { Phone, Users, Star, PhoneCall } from 'lucide-react';
import { cn } from '../../layouts/DashboardLayout';
import type { FamilyMember } from '../../services/medcardService';

interface Props {
  members: FamilyMember[];
}

const RELATION_COLORS: Record<string, string> = {
  Wife:    'bg-pink-50    text-pink-600    border-pink-200',
  Husband: 'bg-pink-50    text-pink-600    border-pink-200',
  Mother:  'bg-purple-50  text-purple-600  border-purple-200',
  Father:  'bg-indigo-50  text-indigo-600  border-indigo-200',
  Son:     'bg-blue-50    text-blue-600    border-blue-200',
  Daughter:'bg-rose-50    text-rose-600    border-rose-200',
  Brother: 'bg-cyan-50    text-cyan-600    border-cyan-200',
  Sister:  'bg-teal-50    text-teal-600    border-teal-200',
};

const initials = (name: string) =>
  name.split(' ').map(n => n[0]).join('').slice(0, 2).toUpperCase();

export const FamilyInfo = ({ members }: Props) => {
  if (members.length === 0) {
    return (
      <div className="bg-white rounded-2xl border border-slate-200 p-6 text-center shadow-sm">
        <Users className="w-8 h-8 text-slate-300 mx-auto mb-2" />
        <p className="text-[13px] font-medium text-slate-400">No family members on record</p>
      </div>
    );
  }

  return (
    <div className="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden">
      {/* Header */}
      <div className="flex items-center gap-3 px-5 py-4 border-b border-slate-100">
        <div className="w-8 h-8 bg-blue-50 rounded-xl flex items-center justify-center">
          <Users className="w-4 h-4 text-blue-500" />
        </div>
        <div>
          <p className="font-black text-slate-800 text-[14px]">Family & Emergency Contacts</p>
          <p className="text-[11px] text-slate-400 font-medium mt-0.5">{members.length} contact{members.length > 1 ? 's' : ''} on file</p>
        </div>
      </div>

      {/* Members list */}
      <div className="divide-y divide-slate-100">
        {members.map(member => {
          const chip = RELATION_COLORS[member.relation] ?? 'bg-slate-50 text-slate-600 border-slate-200';
          return (
            <div key={member.id} className="flex items-center gap-4 px-5 py-4 hover:bg-slate-50/60 transition-colors">

              {/* Avatar */}
              <div className={cn(
                'w-11 h-11 rounded-2xl flex items-center justify-center font-black text-sm shrink-0',
                member.is_primary ? 'bg-blue-500 text-white shadow-md shadow-blue-500/25' : 'bg-slate-100 text-slate-600'
              )}>
                {initials(member.name)}
              </div>

              {/* Info */}
              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-2 flex-wrap">
                  <p className="font-black text-slate-800 text-[14px]">{member.name}</p>
                  {member.is_primary && (
                    <div className="flex items-center gap-1 text-[10px] font-bold text-amber-600 bg-amber-50 border border-amber-200 px-1.5 py-0.5 rounded-lg">
                      <Star className="w-2.5 h-2.5 fill-amber-500" /> Primary
                    </div>
                  )}
                </div>
                <div className="flex items-center gap-2 mt-1 flex-wrap">
                  <span className={cn('text-[11px] font-bold px-2 py-0.5 rounded-lg border', chip)}>
                    {member.relation}
                  </span>
                  <span className="text-[12px] font-semibold text-slate-500 flex items-center gap-1">
                    <Phone className="w-3 h-3" /> {member.phone}
                  </span>
                </div>
              </div>

              {/* Call button */}
              <a href={`tel:${member.phone.replace(/\s+/g, '')}`}
                className="w-10 h-10 bg-emerald-50 hover:bg-emerald-100 border border-emerald-200 rounded-xl flex items-center justify-center transition-colors shrink-0">
                <PhoneCall className="w-4 h-4 text-emerald-600" />
              </a>
            </div>
          );
        })}
      </div>
    </div>
  );
};
