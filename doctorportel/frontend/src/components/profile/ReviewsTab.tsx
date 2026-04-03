import { Star, Sparkles, ThumbsUp } from 'lucide-react';

const mockReviews = [
  { id: 1, name: "Emily Chen", rating: 5, date: "2 weeks ago", text: "Dr. Smith was incredibly thorough and took the time to explain everything clearly. Highly recommend!", helpful: 12 },
  { id: 2, name: "James Wilson", rating: 5, date: "1 month ago", text: "Excellent bedside manner. I felt completely at ease during my consultation.", helpful: 8 },
  { id: 3, name: "Maria Garcia", rating: 4, date: "2 months ago", text: "Very knowledgeable doctor. Wait time was a little long, but the consultation was worth it.", helpful: 3 },
];

export const ReviewsTab = () => {
  return (
    <div className="space-y-6">
      
      {/* AI Summary */}
      <div className="bg-gradient-to-r from-purple-50 to-brand-blue/5 border border-purple-100 rounded-2xl p-5 relative overflow-hidden">
        <div className="flex items-start gap-4">
          <div className="bg-white p-2.5 rounded-xl shadow-sm border border-purple-100 shrink-0">
            <Sparkles className="w-6 h-6 text-purple-600" />
          </div>
          <div>
            <h3 className="font-bold text-slate-800 flex items-center gap-2 mb-1">
              AI Review Summary
              <span className="bg-purple-100 text-purple-700 text-[10px] uppercase font-bold px-2 py-0.5 rounded-full">Beta</span>
            </h3>
            <p className="text-sm text-slate-600 leading-relaxed">
              Based on 150+ reviews, patients consistently praise your <strong className="text-purple-700">excellent bedside manner</strong> and <strong className="text-purple-700">thorough explanations</strong>. Some patients noted occasional <span className="text-slate-500 italic">longer wait times</span>.
            </p>
          </div>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="md:col-span-1 bg-white rounded-2xl p-6 shadow-sm border border-slate-200 text-center flex flex-col justify-center">
          <p className="text-5xl font-black text-slate-800 mb-2">4.9</p>
          <div className="flex justify-center gap-1 mb-2">
            {[1,2,3,4,5].map(i => <Star key={i} className="w-5 h-5 fill-amber-400 text-amber-400" />)}
          </div>
          <p className="text-sm text-slate-500">Based on 154 reviews</p>
        </div>

        <div className="md:col-span-2 space-y-4">
          {mockReviews.map(r => (
            <div key={r.id} className="bg-white rounded-2xl p-5 shadow-sm border border-slate-200">
              <div className="flex justify-between items-start mb-3">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 bg-brand-blue/10 text-brand-blue rounded-full flex items-center justify-center font-bold">
                    {r.name.charAt(0)}
                  </div>
                  <div>
                    <p className="font-bold text-slate-800 text-sm">{r.name}</p>
                    <p className="text-xs text-slate-500">{r.date}</p>
                  </div>
                </div>
                <div className="flex gap-0.5">
                  {[...Array(5)].map((_, i) => (
                    <Star key={i} className={`w-3.5 h-3.5 ${i < r.rating ? 'fill-amber-400 text-amber-400' : 'fill-slate-100 text-slate-200'}`} />
                  ))}
                </div>
              </div>
              <p className="text-sm text-slate-600 mb-3">{r.text}</p>
              <button className="flex items-center gap-1.5 text-xs text-slate-400 hover:text-brand-blue font-medium transition-colors">
                <ThumbsUp className="w-3.5 h-3.5" /> Helpful ({r.helpful})
              </button>
            </div>
          ))}
          <button className="w-full py-3 text-sm font-bold text-brand-blue hover:bg-blue-50 rounded-xl transition-colors">
            Load More Reviews
          </button>
        </div>
      </div>
    </div>
  );
};