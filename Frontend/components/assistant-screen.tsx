"use client"

import { Header } from "./ui/header"
import { Phone, ArrowDownToLine, RefreshCw } from "lucide-react"

export function AssistantScreen({ onBack }: { onBack: () => void }) {
  return (
    <div className="flex flex-col h-full">
      <Header 
        title="AI Dentist Assistant" 
        onBack={onBack} 
      />

      <div className="flex-1 overflow-y-auto px-5 py-6 space-y-5 no-scrollbar">
         {/* Bot Message */}
         <div className="flex items-start gap-3">
           <div className="w-8 h-8 rounded-full bg-white flex items-center justify-center shrink-0 shadow-sm border border-blue-50 relative overflow-hidden">
             <svg viewBox="0 0 24 24" fill="none" className="w-5 h-5 text-[#2E6DD1]">
                 <path d="M12 21 C8 21 5 18 5 14 C5 10 7 7 12 7 C17 7 19 10 19 14 C19 18 16 21 12 21 Z" fill="currentColor"/>
             </svg>
           </div>
           <div className="bg-white p-3.5 px-4 rounded-2xl rounded-tl-none shadow-sm border border-blue-50/50">
             <p className="text-[#3A5D84] text-[14px] font-medium leading-relaxed">
               Hello! How can I assist you today?
             </p>
           </div>
         </div>

         <div className="flex items-start gap-3">
           <div className="w-8 h-8 rounded-full bg-transparent shrink-0"></div>
           <div className="bg-white p-3.5 px-4 rounded-2xl rounded-tl-none shadow-sm border border-blue-50/50">
             <p className="text-[#3A5D84] text-[14px] font-medium leading-relaxed">
               You can ask me dental questions, and I can provide information based on your provisional analysis. 😄
             </p>
           </div>
         </div>

         {/* User Message */}
         <div className="flex items-start gap-3 justify-end mt-2">
           <div className="bg-gradient-to-r from-[#2E6DD1] to-[#1D4ED8] p-3.5 px-4 rounded-2xl rounded-tr-none shadow-[0_4px_10px_rgba(46,109,209,0.2)] max-w-[85%]">
             <p className="text-white text-[14px] font-medium leading-relaxed">
               What steps can improve my smile alignment?
             </p>
           </div>
         </div>

         {/* Bot Message */}
         <div className="flex items-start gap-3 mt-2">
           <div className="w-8 h-8 rounded-full bg-white flex items-center justify-center shrink-0 shadow-sm border border-blue-50 relative overflow-hidden">
             <svg viewBox="0 0 24 24" fill="none" className="w-5 h-5 text-[#2E6DD1]">
                 <path d="M12 21 C8 21 5 18 5 14 C5 10 7 7 12 7 C17 7 19 10 19 14 C19 18 16 21 12 21 Z" fill="currentColor"/>
             </svg>
           </div>
           <div className="bg-white p-4 rounded-2xl rounded-tl-none shadow-sm border border-blue-50/50 flex-1">
             <ul className="list-disc pl-4 text-[#3A5D84] text-[13px] font-medium leading-relaxed space-y-2">
                <li>Seek orthodontic consultations for braces or clear aligners.</li>
                <li>Avoid habits like teeth grinding.</li>
                <li>Maintain good oral hygiene to prevent gum issues that affect alignment.</li>
             </ul>
           </div>
         </div>

         <div className="flex items-start gap-3 justify-end mt-2">
           <div className="bg-[#DCEAFF] p-3 px-4 rounded-full rounded-tr-none text-[#1D4ED8] text-[13px] font-bold">
             Feel free to ask if you need more details on your analysis!
           </div>
         </div>

         <div className="space-y-3 pt-2">
            <button className="w-full bg-white text-[#1D4ED8] font-bold text-[14px] py-3.5 rounded-2xl shadow-sm border border-blue-50 flex items-center gap-3 px-4">
              <div className="bg-[#E8F1FF] p-1.5 rounded-full"><Phone size={16} /></div>
              Tell me more
            </button>
            <button className="w-full bg-white text-[#1D4ED8] font-bold text-[14px] py-3.5 rounded-2xl shadow-sm border border-blue-50 flex items-center gap-3 px-4">
              <div className="bg-[#E8F1FF] p-1.5 rounded-full"><ArrowDownToLine size={16} /></div>
              Download Report
            </button>
            <button className="w-full bg-white text-[#1D4ED8] font-bold text-[14px] py-3.5 rounded-2xl shadow-sm border border-blue-50 flex items-center gap-3 px-4">
              <div className="bg-[#E8F1FF] p-1.5 rounded-full"><RefreshCw size={16} /></div>
              Analyze Another Photo
            </button>
         </div>
         
      </div>
    </div>
  )
}
