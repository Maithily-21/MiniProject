"use client"

import { Header } from "./ui/header"
import { CheckCircle2, MapPin } from "lucide-react"

export function ReportScreen({ onDetailedReport, onBack }: { onDetailedReport: () => void, onBack: () => void }) {
  const items = [
    { label: "Teeth Alignment", value: "Slightly Irregular", score: 75, status: "warning" },
    { label: "Smile Symmetry", value: "Moderate", score: 72, status: "warning" },
    { label: "Gum Health", value: "Healthy", score: null, status: "success" },
  ]

  return (
    <div className="flex flex-col h-full">
      <Header 
        title="Provisional Analysis Report" 
        onBack={onBack} 
      />

      <div className="flex-1 overflow-y-auto px-5 py-6 space-y-4 no-scrollbar">
        {items.map((item, idx) => (
          <div key={idx} className="bg-white rounded-[1.2rem] p-4 shadow-[0_2px_10px_rgba(30,96,220,0.06)] border border-blue-50 relative overflow-hidden">
             
             <div className="flex items-center gap-3 mb-1.5 relative z-10">
               <div className={`w-5 h-5 rounded-full flex items-center justify-center text-white ${item.status === 'success' ? 'bg-[#34D399]' : 'bg-[#FCA5A5]'}`}>
                 <CheckCircle2 size={14} />
               </div>
               <span className="font-bold text-[15px] text-[#3A5D84]">{item.label}</span>
               {item.score && (
                 <span className={`ml-auto font-bold text-[15px] ${item.status === 'success' ? 'text-[#34D399]' : 'text-[#FCA5A5]'}`}>
                   {item.score}%
                 </span>
               )}
             </div>
             
             <p className={`font-bold text-[14px] pl-8 ${item.status === 'success' ? 'text-[#34D399]' : 'text-[#FCA5A5]'} relative z-10 opacity-90`}>
               {item.value}
             </p>

             {/* Progress bar line */}
             {item.score && (
               <div className="absolute right-4 bottom-4 w-20 h-1.5 bg-gray-100 rounded-full overflow-hidden">
                 <div className={`h-full rounded-full ${item.status === 'warning' ? 'bg-[#FCA5A5]' : 'bg-[#34D399]'}`} style={{ width: `${item.score}%` }} />
               </div>
             )}
          </div>
        ))}

        <div className="bg-white rounded-[1.2rem] p-4 shadow-[0_2px_10px_rgba(30,96,220,0.06)] border border-blue-50">
           <div className="flex items-center gap-3 mb-1.5">
             <div className="w-5 h-5 rounded-full bg-[#1D4ED8] flex items-center justify-center text-white">
                <MapPin size={12} />
             </div>
             <span className="font-bold text-[15px] text-[#3A5D84]">Cavity Detection</span>
           </div>
           <p className="font-bold text-[14px] pl-8 text-[#8A9EB5]">
             No Cavities Detected
           </p>
        </div>

        <div className="pt-2 px-1">
          <h3 className="font-bold text-[16px] text-[#1D4ED8] mb-1.5 tracking-wide">Recommendations.</h3>
          <p className="text-[14px] font-semibold leading-relaxed text-[#3A5D84]">
            Minor alignment irregularities detected. Please consult a dentist for a detailed evaluation.
          </p>
        </div>

        <div className="pt-4">
          <button 
            onClick={onDetailedReport}
            className="w-full py-4 rounded-2xl text-[16px] font-bold flex items-center justify-center text-white shadow-[0_8px_20px_rgba(30,96,220,0.25)] active:scale-[0.98] transition-all bg-gradient-to-r from-[#2E6DD1] to-[#1D4ED8]"
          >
            View Detailed Report
          </button>
        </div>
      </div>
    </div>
  )
}
