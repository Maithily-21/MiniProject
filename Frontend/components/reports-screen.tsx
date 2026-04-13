"use client"

import { useState, useEffect } from "react"
import { Header } from "./ui/header"
import { Calendar, CheckCircle2, ChevronRight, Loader2, AlertCircle } from "lucide-react"
import { fetchReports, type ReportSummary } from "@/lib/api"

export function ReportsScreen() {
  const [reports, setReports] = useState<ReportSummary[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    setLoading(true)
    fetchReports()
      .then((data) => {
        setReports(data.reports)
        setError(null)
      })
      .catch((err) => {
        setError(err instanceof Error ? err.message : "Failed to load reports")
      })
      .finally(() => setLoading(false))
  }, [])

  const formatDate = (dateStr: string) => {
    try {
      return new Date(dateStr).toLocaleDateString("en-US", {
        year: "numeric",
        month: "long",
        day: "numeric",
      })
    } catch {
      return dateStr
    }
  }

  const getReportTitle = (r: ReportSummary) => {
    if (r.cavity_result && r.cavity_result.toLowerCase().includes("detected")) {
      return "Cavity Detected"
    }
    if (r.alignment_score !== null && r.alignment_score < 70) {
      return "Irregular Alignment"
    }
    if (r.gum_disease_result && r.gum_disease_result.toLowerCase().includes("disease")) {
      return "Gum Issues Found"
    }
    return "Healthy Analysis"
  }

  return (
    <div className="flex flex-col h-full bg-transparent">
      <Header 
        title="My Reports" 
        showBack={false}
      />

      <div className="flex-1 overflow-y-auto px-5 py-6 space-y-4 no-scrollbar">
        {loading && (
          <div className="flex flex-col items-center justify-center py-16 gap-3">
            <Loader2 size={32} className="animate-spin text-[#2E6DD1]" />
            <p className="text-[14px] font-medium text-[#5A7B9B]">Loading reports...</p>
          </div>
        )}

        {error && (
          <div className="flex flex-col items-center justify-center py-16 gap-3">
            <AlertCircle size={32} className="text-[#FCA5A5]" />
            <p className="text-[14px] font-medium text-[#5A7B9B]">{error}</p>
          </div>
        )}

        {!loading && !error && reports.length === 0 && (
          <div className="flex flex-col items-center justify-center py-16 gap-3">
            <CheckCircle2 size={32} className="text-[#94b1c9]" />
            <p className="text-[14px] font-medium text-[#5A7B9B]">No reports yet. Upload a photo to get started!</p>
          </div>
        )}

        {reports.map((report) => (
          <div key={report.id} className="bg-white rounded-[1.2rem] p-4 shadow-[0_2px_10px_rgba(30,96,220,0.06)] border border-blue-50 relative overflow-hidden flex flex-col">
             
             <div className="flex items-center gap-2 mb-3">
               <Calendar size={14} className="text-[#94b1c9]" />
               <span className="font-semibold text-[13px] text-[#94b1c9] uppercase tracking-wide">
                 {formatDate(report.created_at)}
               </span>
               <span className="ml-auto font-bold text-[11px] px-2.5 py-1 rounded-full bg-[#1D4ED8]/10 text-[#1D4ED8]">
                 Provisional
               </span>
             </div>

             <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-full bg-[#E8F1FF] flex items-center justify-center">
                    <CheckCircle2 size={20} className="text-[#1D4ED8]" />
                  </div>
                  <div>
                    <h3 className="font-bold text-[15px] text-[#3A5D84]">{getReportTitle(report)}</h3>
                    <p className="font-medium text-[13px] text-[#5A7B9B]">
                      {report.alignment_score !== null ? `Alignment: ${Math.round(report.alignment_score)}%` : "Full scan complete"}
                    </p>
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
