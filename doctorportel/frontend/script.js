import fs from 'fs';
const file = 'frontend/src/pages/Patients.tsx';
let data = fs.readFileSync(file, 'utf8');

data = data.replace(
  /<button className="bg-white text-slate-900 text-xs font-bold px-4 py-2 rounded-xl shadow-sm hover:bg-slate-50\s+transition-colors whitespace-nowrap ml-4">/g,
  '<button onClick={() => navigate("/emergency")} className="bg-white text-slate-900 text-xs font-bold px-4 py-2 rounded-xl shadow-sm hover:bg-slate-50 transition-colors whitespace-nowrap ml-4">'
);
data = data.replace(
  /<button className="text-brand-blue text-sm font-bold hover:underline">View<\/button>/g,
  '<button onClick={(e) => { e.stopPropagation(); setSelectedPatient(patient); }} className="text-brand-blue text-sm font-bold hover:underline">View</button>'
);

fs.writeFileSync(file, data);
console.log("Replaced");
