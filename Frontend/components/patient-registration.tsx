"use client"

import { Header } from "./ui/header"
import { User, Phone, Calendar, Users } from "lucide-react"

export function PatientRegistration({ onBack, onContinue }: { onBack: () => void, onContinue: () => void }) {
  return (
    <div className="flex flex-col h-full">
      <Header 
        title="Patient Details" 
        onBack={onBack} 
      />

      <div className="flex-1 overflow-y-auto px-6 py-6 pb-2 no-scrollbar">
        <h2 className="text-[20px] font-extrabold text-[#1D4ED8] text-center mb-6 uppercase tracking-wide">
          Your Information
        </h2>

        <form className="flex flex-col space-y-4 h-full" onSubmit={(e) => { e.preventDefault(); onContinue(); }}>
            <div className="relative">
              <div className="flex items-center bg-white rounded-2xl px-5 py-4 shadow-[0_2px_10px_rgba(30,96,220,0.04)] border border-blue-50">
                <User size={20} className="mr-3 text-[#5A7B9B]" />
                <input 
                  type="text" 
                  placeholder="Full Name"
                  defaultValue="Mohammad Muzammil"
                  className="flex-1 w-full text-[15px] outline-none font-medium bg-transparent text-[#3A5D84] placeholder-[#94b1c9]"
                />
              </div>
            </div>

            <div className="relative">
              <div className="flex items-center bg-white rounded-2xl px-5 py-4 shadow-[0_2px_10px_rgba(30,96,220,0.04)] border border-blue-50 relative">
                <Users size={20} className="mr-3 text-[#5A7B9B]" />
                <select 
                  className="flex-1 w-full text-[15px] outline-none font-medium bg-transparent appearance-none text-[#3A5D84]"
                >
                   <option>Male</option>
                   <option>Female</option>
                   <option>Other</option>
                </select>
                <div className="pointer-events-none absolute right-5">
                  <svg className="w-5 h-5 text-[#94b1c9]" fill="currentColor" viewBox="0 0 20 20">
                    <path fillRule="evenodd" d="M5.23 7.21a.75.75 0 011.06.02L10 10.94l3.71-3.71a.75.75 0 111.06 1.06l-4.24 4.25a.75.75 0 01-1.06 0L5.21 8.27a.75.75 0 01.02-1.06z" clipRule="evenodd" />
                  </svg>
                </div>
              </div>
            </div>

            <div className="relative">
              <div className="flex items-center bg-white rounded-2xl px-5 py-4 shadow-[0_2px_10px_rgba(30,96,220,0.04)] border border-blue-50">
                <Calendar size={20} className="mr-3 text-[#5A7B9B]" />
                <input 
                  type="number" 
                  placeholder="Age"
                  defaultValue="22"
                  className="flex-1 w-full text-[15px] outline-none font-medium bg-transparent text-[#3A5D84] placeholder-[#94b1c9]"
                />
              </div>
            </div>

            <div className="relative">
              <div className="flex items-center bg-white rounded-2xl px-5 py-4 shadow-[0_2px_10px_rgba(30,96,220,0.04)] border border-blue-50">
                <Phone size={20} className="mr-3 text-[#5A7B9B]" />
                <input 
                  type="tel" 
                  placeholder="Contact Number"
                  defaultValue="9200000000"
                  className="flex-1 w-full text-[15px] outline-none font-medium bg-transparent text-[#3A5D84] placeholder-[#94b1c9]"
                />
              </div>
            </div>

          <div className="pt-8 w-full pb-4">
             <button 
               type="submit"
               className="w-full py-4 rounded-2xl text-[16px] font-bold text-white shadow-[0_8px_20px_rgba(30,96,220,0.25)] active:scale-[0.98] transition-all bg-gradient-to-r from-[#2E6DD1] to-[#1D4ED8]"
             >
               Continue to Photo
             </button>
          </div>
        </form>
      </div>
    </div>
  )
}
