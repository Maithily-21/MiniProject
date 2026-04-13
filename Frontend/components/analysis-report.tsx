"use client"

import { Header } from "./ui/header"
import { CheckCircle2, MapPin, AlertTriangle } from "lucide-react"
import { type AnalysisResult } from "@/lib/api"

interface ReportScreenProps {
  analysisResult: AnalysisResult | null
  onDetailedReport: () => void
  onBack: () => void
}

function parseScore(tip: string): number | null {
  const match = tip.match(/(\d+(?:\.\d+)?)%/)
  if (match) return parseFloat(match[1])
  // Try to extract score from tip text patterns like "Score: 85"
  const scoreMatch = tip.match(/score[:\s]+(\d+(?:\.\d+)?)/i)
  if (scoreMatch) return parseFloat(scoreMatch[1])
  return null
}

function getStatus(tip: string): "success" | "warning" {
  const lower = tip.toLowerCase()
  if (lower.includes("healthy") || lower.includes("good") || lower.includes("normal") || lower.includes("no ") || lower.includes("not detected")) {
    return "success"
  }
  return "warning"
}

export function ReportScreen({ analysisResult, onDetailedReport, onBack }: ReportScreenProps) {
  // Build items from real analysis or fallback to placeholder
  const items = analysisResult
    ? [
        {
          label: "Teeth Alignment",
          value: analysisResult.alignment_tip,
          score: parseScore(analysisResult.alignment_tip),
          status: getStatus(analysisResult.alignment_tip),
        },
        {
          label: "Smile Symmetry",
          value: analysisResult.symmetry_tip,
          score: parseScore(analysisResult.symmetry_tip),
          status: getStatus(analysisResult.symmetry_tip),
        },
        {
          label: "Gum Health",
          value: analysisResult.gum_health,
          score: null,
          status: getStatus(analysisResult.gum_health),
        },
        {
          label: "Staining",
          value: analysisResult.staining_status,
          score: null,
          status: getStatus(analysisResult.staining_status),
        },
      ]
    : [
        { label: "Teeth Alignment", value: "No data", score: null, status: "warning" as const },
        { label: "Smile Symmetry", value: "No data", score: null, status: "warning" as const },
        { label: "Gum Health", value: "No data", score: null, status: "warning" as const },
      ]

  const cavityStatus = analysisResult?.cavity_status || "No data"
  const cavityIsGood = getStatus(cavityStatus) === "success"
  const spacing = analysisResult?.spacing_tip
  const gumVisibility = analysisResult?.gum_visibility

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
               {item.score !== null && (
                 <span className={`ml-auto font-bold text-[15px] ${item.status === 'success' ? 'text-[#34D399]' : 'text-[#FCA5A5]'}`}>
                   {Math.round(item.score)}%
                 </span>
               )}
             </div>
             
             <p className={`font-bold text-[14px] pl-8 ${item.status === 'success' ? 'text-[#34D399]' : 'text-[#FCA5A5]'} relative z-10 opacity-90 line-clamp-2`}>
               {item.value}
             </p>

             {/* Progress bar line */}
             {item.score !== null && (
               <div className="absolute right-4 bottom-4 w-20 h-1.5 bg-gray-100 rounded-full overflow-hidden">
                 <div className={`h-full rounded-full ${item.status === 'warning' ? 'bg-[#FCA5A5]' : 'bg-[#34D399]'}`} style={{ width: `${Math.min(item.score, 100)}%` }} />
               </div>
             )}
          </div>
        ))}

        {/* Cavity Detection */}
        <div className="bg-white rounded-[1.2rem] p-4 shadow-[0_2px_10px_rgba(30,96,220,0.06)] border border-blue-50">
           <div className="flex items-center gap-3 mb-1.5">
             <div className={`w-5 h-5 rounded-full flex items-center justify-center text-white ${cavityIsGood ? 'bg-[#34D399]' : 'bg-[#FCA5A5]'}`}>
                {cavityIsGood ? <CheckCircle2 size={12} /> : <AlertTriangle size={12} />}
             </div>
             <span className="font-bold text-[15px] text-[#3A5D84]">Cavity Detection</span>
           </div>
           <p className={`font-bold text-[14px] pl-8 ${cavityIsGood ? 'text-[#34D399]' : 'text-[#FCA5A5]'}`}>
             {cavityStatus}
           </p>
        </div>

        {/* Extra tips */}
        {(spacing || gumVisibility) && (
          <div className="space-y-3">
            {spacing && (
              <div className="bg-white rounded-[1.2rem] p-4 shadow-[0_2px_10px_rgba(30,96,220,0.06)] border border-blue-50">
                <div className="flex items-center gap-3 mb-1.5">
                  <div className="w-5 h-5 rounded-full bg-[#1D4ED8] flex items-center justify-center text-white">
                    <MapPin size={12} />
                  </div>
                  <span className="font-bold text-[15px] text-[#3A5D84]">Spacing</span>
                </div>
                <p className="font-bold text-[14px] pl-8 text-[#8A9EB5]">{spacing}</p>
              </div>
            )}
            {gumVisibility && (
              <div className="bg-white rounded-[1.2rem] p-4 shadow-[0_2px_10px_rgba(30,96,220,0.06)] border border-blue-50">
                <div className="flex items-center gap-3 mb-1.5">
                  <div className="w-5 h-5 rounded-full bg-[#1D4ED8] flex items-center justify-center text-white">
                    <MapPin size={12} />
                  </div>
                  <span className="font-bold text-[15px] text-[#3A5D84]">Gum Visibility</span>
                </div>
                <p className="font-bold text-[14px] pl-8 text-[#8A9EB5]">{gumVisibility}</p>
              </div>
            )}
          </div>
        )}

        <div className="pt-2 px-1">
          <h3 className="font-bold text-[16px] text-[#1D4ED8] mb-1.5 tracking-wide">Recommendations.</h3>
          <p className="text-[14px] font-semibold leading-relaxed text-[#3A5D84]">
            {analysisResult
              ? "Analysis complete. View the detailed report for personalised recommendations from our AI assistant."
              : "Please complete the analysis to receive recommendations."
            }
          </p>
        </div>

        <div className="pt-4">
          <button 
            id="detailed-report-button"
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
