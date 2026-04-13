"use client"

import { Header } from "./ui/header"
import { UploadCloud, Image as ImageIcon, UserCircle2 } from "lucide-react"

export function AnalyzeStartScreen({ onUploadPhoto, onBack }: { onUploadPhoto: () => void, onBack: () => void }) {
  return (
    <div className="flex flex-col h-full">
      <Header 
        title="PROVIDENT" 
        onBack={onBack} 
        rightIcon={<UserCircle2 size={26} className="opacity-90" />} 
      />

      <div className="flex-1 flex flex-col px-6 py-8 pb-2">
        <h2 className="text-[22px] font-extrabold text-[#1D4ED8] text-center mb-8 uppercase tracking-wide">
          Analyze Your Smile
        </h2>

        {/* Big Smile Graphic */}
        <div className="w-full max-w-[260px] mx-auto mb-10 flex justify-center drop-shadow-xl relative">
            <svg viewBox="0 0 100 50" className="w-full">
              {/* Lips */}
              <path d="M5,25 C25,50 75,50 95,25 C75,5 25,5 5,25 Z" fill="#E64A19" />
              {/* Upper Teeth */}
              <path d="M15,25 C25,40 75,40 85,25 C75,15 25,15 15,25 Z" fill="#FFFFFF" />
              <path d="M30,25 v9 M40,25 v11 M50,25 v12 M60,25 v11 M70,25 v9" stroke="#E0E0E0" strokeWidth="0.8" />
              {/* Lower Teeth */}
              <path d="M20,25 C30,32 70,32 80,25 C70,28 30,28 20,25 Z" fill="#F5F5F5" />
            </svg>
        </div>

        <div className="space-y-4 mb-8">
          <button 
            onClick={onUploadPhoto}
            className="w-full py-4 rounded-2xl text-[16px] font-bold gap-3 flex items-center justify-center text-white shadow-[0_8px_20px_rgba(30,96,220,0.25)] active:scale-[0.98] transition-all bg-gradient-to-r from-[#2E6DD1] to-[#1D4ED8]"
          >
            <UploadCloud size={22} />
            Upload Photo
          </button>
          
          <button 
            onClick={onUploadPhoto}
            className="w-full py-4 rounded-2xl text-[16px] font-bold gap-3 flex items-center justify-center text-white shadow-[0_8px_20px_rgba(30,96,220,0.25)] active:scale-[0.98] transition-all bg-gradient-to-r from-[#3A80E9] to-[#2563EB]"
          >
            <ImageIcon size={22} />
            Choose from Gallery
          </button>
        </div>

        <p className="text-center text-[12px] font-bold text-[#5A7B9B] px-4 leading-relaxed mt-auto">
          Disclaimer: This app provides only provisional assessment and is no ts substitute for professional dental consultation.
        </p>
      </div>
    </div>
  )
}
