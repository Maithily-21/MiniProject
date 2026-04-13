"use client"

import { useTheme } from "@/contexts/theme-context"
import { ShieldPlus } from "lucide-react"

export function WelcomeScreen({ onGetStarted }: { onGetStarted: () => void }) {
  const { colors } = useTheme()

  return (
    <div className="flex flex-col h-full min-h-screen items-center justify-between p-6" style={{ backgroundColor: colors.primary }}>
      <div className="flex-1 flex flex-col items-center justify-center w-full">
        <div className="bg-white p-4 rounded-3xl mb-6 shadow-xl">
           <ShieldPlus size={64} style={{ color: colors.primary }} />  
        </div>
        <h1 className="text-5xl font-extrabold text-white mb-4 tracking-tight">ProviDent</h1>
        <p className="text-white/90 text-center text-lg max-w-xs font-medium">
          Professional Dental Analysis<br/>Powered by AI Technology
        </p>
      </div>
      
      <div className="w-full pb-8">
        <button 
          onClick={onGetStarted}
          className="w-full py-4 rounded-2xl bg-white font-bold text-xl shadow-lg hover:shadow-xl transition-all active:scale-[0.98]"
          style={{ color: colors.primary }}
        >
          Get Started
        </button>
      </div>
    </div>
  )
}
