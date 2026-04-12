import { Home, ClipboardList, Mic, Send } from "lucide-react"

export function BottomNav({ activeTab, onTabChange, showChat = true }: { activeTab: 'home' | 'reports', onTabChange: (tab: 'home' | 'reports') => void, showChat?: boolean }) {
  return (
    <div className="bg-white/95 backdrop-blur-md pb-6 pt-3 px-4 border-t border-blue-50 rounded-t-[2.5rem] shadow-[0_-4px_20px_rgba(30,96,220,0.05)] w-full shrink-0 flex flex-col">
      {showChat && (
        <div className="bg-white rounded-full shadow-sm flex items-center p-1.5 px-3 border border-blue-100 mb-2 w-full">
          <input 
            type="text" 
            placeholder="Ask me anything..." 
            className="flex-1 outline-none text-[#5A7B9B] bg-transparent placeholder-[#94b1c9] text-[15px] font-medium min-w-0 ml-1" 
          />
          <button className="p-2 text-[#4A88EF] hover:bg-blue-50 rounded-full transition-colors border-none bg-transparent flex items-center justify-center cursor-pointer shrink-0">
            <Mic size={20} />
          </button>
          <button className="p-2 text-[#4A88EF] hover:bg-blue-50 rounded-full transition-colors border-none bg-transparent flex items-center justify-center cursor-pointer shrink-0">
            <Send size={18} className="translate-x-[-1px] translate-y-[1px]" />
          </button>
        </div>
      )}

      <div className="flex justify-around items-center pt-1">
        <button 
          onClick={() => onTabChange('home')} 
          className={`flex flex-col items-center flex-1 transition-colors ${activeTab === 'home' ? 'text-[#1D4ED8]' : 'text-[#A0BCE0]'}`}
        >
          <Home size={22} className="mb-1.5" strokeWidth={activeTab === 'home' ? 2.5 : 2} />
          <span className="text-[11px] font-bold">Home</span>
        </button>
        <button 
          onClick={() => onTabChange('reports')} 
          className={`flex flex-col items-center flex-1 transition-colors ${activeTab === 'reports' ? 'text-[#1D4ED8]' : 'text-[#A0BCE0]'}`}
        >
          <ClipboardList size={22} className="mb-1.5" strokeWidth={activeTab === 'reports' ? 2.5 : 2} />
          <span className="text-[11px] font-bold">Reports</span>
        </button>
      </div>
    </div>
  )
}
