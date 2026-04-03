import { FileText, Upload, CheckCircle2, AlertCircle } from 'lucide-react';

export const DocumentsTab = () => {
  return (
    <div className="space-y-6">
      <div className="bg-white rounded-2xl p-6 shadow-sm border border-slate-200">
        <h3 className="font-bold text-lg text-slate-800 mb-1">Professional Documents</h3>
        <p className="text-sm text-slate-500 mb-6">Upload your medical license and certificates to earn the Verified badge.</p>

        <div className="grid gap-4">
          
          <div className="flex flex-col sm:flex-row gap-4 p-4 border border-slate-200 rounded-xl items-center justify-between">
            <div className="flex items-center gap-4">
              <div className="w-12 h-12 bg-green-50 text-green-600 rounded-lg flex items-center justify-center shrink-0">
                <FileText className="w-6 h-6" />
              </div>
              <div>
                <h4 className="font-bold text-slate-800 flex items-center gap-2">
                  Medical License 
                  <CheckCircle2 className="w-4 h-4 text-green-500" />
                </h4>
                <p className="text-xs text-slate-500">Verified on Jan 12, 2024</p>
              </div>
            </div>
            <button className="text-sm font-bold text-slate-600 hover:bg-slate-50 px-4 py-2 rounded-lg transition-colors border border-slate-200">
              View
            </button>
          </div>

          <div className="flex flex-col sm:flex-row gap-4 p-4 border border-amber-200 bg-amber-50/30 rounded-xl items-center justify-between relative overflow-hidden">
            <div className="flex items-center gap-4">
              <div className="w-12 h-12 bg-amber-100 text-amber-600 rounded-lg flex items-center justify-center shrink-0">
                <AlertCircle className="w-6 h-6" />
              </div>
              <div>
                <h4 className="font-bold text-slate-800">Board Certification</h4>
                <p className="text-xs text-amber-600 font-medium">Pending upload</p>
              </div>
            </div>
            <button className="text-sm font-bold bg-amber-500 text-white hover:bg-amber-600 px-4 py-2 rounded-lg transition-colors shadow-sm flex items-center gap-2">
              <Upload className="w-4 h-4" /> Upload PDF
            </button>
          </div>

        </div>

      </div>
    </div>
  );
};