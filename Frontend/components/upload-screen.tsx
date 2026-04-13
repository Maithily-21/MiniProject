"use client"

import { Header } from "./ui/header"
import { Camera, Image as ImageIcon } from "lucide-react"

export function UploadScreen({ onAnalyze, onBack }: { onAnalyze: () => void, onBack: () => void }) {
  return (
    <div className="flex flex-col h-full">
      <Header 
        title="Analyzing Image..." 
        onBack={onBack} 
      />

      <div className="flex-1 flex flex-col px-6 py-6 pb-2">
        {/* Placeholder for Face Image */}
        <div className="w-full aspect-[4/3] rounded-2xl overflow-hidden mb-6 shadow-md bg-white border-4 border-white">
           <img 
             src="https://images.unsplash.com/photo-1544253303-62505c8623b2?q=80&w=600&auto=format&fit=crop" 
             alt="Smiling Woman" 
             className="w-full h-full object-cover"
           />
        </div>

        <div className="space-y-4 mb-8">
          <button 
            onClick={onAnalyze}
            className="w-full py-4 rounded-2xl text-[16px] font-bold gap-3 flex items-center justify-center text-white shadow-[0_8px_20px_rgba(30,96,220,0.25)] active:scale-[0.98] transition-all bg-gradient-to-r from-[#2E6DD1] to-[#1D4ED8]"
          >
            <Camera size={22} />
            Take a Photo
          </button>
          
          <button 
            className="w-full py-4 rounded-2xl text-[16px] font-bold gap-3 flex items-center justify-center text-white shadow-[0_8px_20px_rgba(30,96,220,0.25)] active:scale-[0.98] transition-all bg-gradient-to-r from-[#3A80E9] to-[#2563EB]"
          >
            <ImageIcon size={22} />
            Choose from Gallery
          </button>
        </div>

        <div className="px-1 text-[#3A5D84]">
          <h3 className="text-[16px] font-bold text-[#1D4ED8] mb-3">Tips for Best Results</h3>
          <ul className="space-y-2.5 text-[14px] font-semibold list-disc pl-5">
            <li>Face camera directly</li>
            <li>Smile clearly showing your teeth</li>
            <li>Ensure even lighting</li>
          </ul>
        </div>
      </div>
    </div>
  )
}
