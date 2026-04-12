"use client"

import { Header } from "./ui/header"
import { CheckCircle2, XCircle } from "lucide-react"

interface QuestionScreenProps {
  questionNumber: number;
  totalQuestions: number;
  question: string;
  onAnswer: (answer: boolean) => void;
  onBack: () => void;
}

export function QuestionScreen({ questionNumber, totalQuestions, question, onAnswer, onBack }: QuestionScreenProps) {
  const progress = (questionNumber / totalQuestions) * 100

  return (
    <div className="flex flex-col h-full">
      <Header 
        title={`Question ${questionNumber}/${totalQuestions}`}
        onBack={onBack} 
      />

      <div className="flex-1 flex flex-col px-6 py-6 pb-2">
        {/* Progress Bar */}
        <div className="w-full h-[6px] rounded-full overflow-hidden mt-2 mb-10 bg-blue-100/50 shadow-inner">
          <div 
            className="h-full rounded-full bg-gradient-to-r from-[#2E6DD1] to-[#1D4ED8] transition-all duration-500 ease-out" 
            style={{ width: `${progress}%` }} 
          />
        </div>

        {/* Question */}
        <div className="flex-1 flex items-center justify-center">
          <h1 className="text-[24px] font-extrabold text-center mb-10 leading-tight text-[#1D4ED8] px-2">
            {question}
          </h1>
        </div>

        {/* Action Buttons */}
        <div className="grid grid-cols-2 gap-4 mt-auto mb-6">
          <button 
            onClick={() => onAnswer(true)}
            className="flex items-center justify-center gap-2 py-4 rounded-2xl shadow-[0_8px_20px_rgba(30,96,220,0.25)] text-white font-bold text-[16px] transition-all active:scale-[0.98] bg-gradient-to-r from-[#2E6DD1] to-[#1D4ED8]"
          >
            <CheckCircle2 size={20} className="text-white" />
            Yes
          </button>

          <button 
            onClick={() => onAnswer(false)}
            className="flex items-center justify-center gap-2 py-4 rounded-2xl shadow-sm bg-white font-bold text-[16px] text-[#1D4ED8] border border-blue-100 transition-all active:scale-[0.98]"
          >
            <XCircle size={20} className="text-[#1D4ED8]" />
            No
          </button>
        </div>
      </div>
    </div>
  )
}
