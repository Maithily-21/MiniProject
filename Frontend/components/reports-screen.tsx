"use client"

import { Header } from "./ui/header"
import { Calendar, CheckCircle2, ChevronRight } from "lucide-react"

export function ReportsScreen() {
  const reports = [
    { id: 1, date: "April 10, 2024", title: "Slightly Irregular Alignment", status: "Provisional" },
    { id: 2, date: "March 15, 2024", title: "Healthy Gums & Detection", status: "Reviewed" },
  ]

  return (
    <div className="flex flex-col h-full bg-transparent">
      <Header 
        title="My Reports" 
        showBack={false}
      />

      <div className="flex-1 overflow-y-auto px-5 py-6 space-y-4 no-scrollbar">
        {reports.map((report) => (
          <div key={report.id} className="bg-white rounded-[1.2rem] p-4 shadow-[0_2px_10px_rgba(30,96,220,0.06)] border border-blue-50 relative overflow-hidden flex flex-col">
             
             <div className="flex items-center gap-2 mb-3">
               <Calendar size={14} className="text-[#94b1c9]" />
               <span className="font-semibold text-[13px] text-[#94b1c9] uppercase tracking-wide">
                 {report.date}
               </span>
               <span className={`ml-auto font-bold text-[11px] px-2.5 py-1 rounded-full ${report.status === 'Reviewed' ? 'bg-[#34D399]/10 text-[#34D399]' : 'bg-[#1D4ED8]/10 text-[#1D4ED8]'}`}>
                 {report.status}
               </span>
             </div>

             <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-full bg-[#E8F1FF] flex items-center justify-center">
                    <CheckCircle2 size={20} className="text-[#1D4ED8]" />
                  </div>
                  <div>
                    <h3 className="font-bold text-[15px] text-[#3A5D84]">{report.title}</h3>
                    <p className="font-medium text-[13px] text-[#5A7B9B]">Full scan complete</p>
                  </div>
                </div>
                
                <ChevronRight size={20} className="text-[#94b1c9]" />
             </div>
          </div>
        ))}
      </div>
    </div>
  )
}
