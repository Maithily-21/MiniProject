import { Mic, Send } from "lucide-react"

export function ChatBar() {
  return (
    <div className="px-5 py-3 w-full shrink-0">
      <div className="bg-white rounded-full shadow-md flex items-center p-1.5 px-4 border border-blue-50/50">
        <input 
          type="text" 
          placeholder="Ask me anything..." 
          className="flex-1 outline-none text-[#5A7B9B] bg-transparent placeholder-[#94b1c9] text-[15px] font-medium" 
        />
        <button className="p-2 text-[#4A88EF] hover:bg-blue-50 rounded-full transition-colors border-none bg-transparent flex items-center justify-center cursor-pointer">
          <Mic size={20} />
        </button>
        <button className="p-2 text-[#4A88EF] hover:bg-blue-50 rounded-full transition-colors border-none bg-transparent flex items-center justify-center cursor-pointer">
          <Send size={18} className="translate-x-[-1px] translate-y-[1px]" />
        </button>
      </div>
    </div>
  )
}
