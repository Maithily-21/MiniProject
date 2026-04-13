import { ChevronLeft } from "lucide-react"

export function Header({ 
  title, 
  showBack = true, 
  rightIcon, 
  onBack 
}: { 
  title: string; 
  showBack?: boolean; 
  rightIcon?: React.ReactNode;
  onBack?: () => void;
}) {
  return (
    <div className="bg-gradient-to-b from-[#2E6DD1] to-[#1D4ED8] text-white rounded-b-[2.5rem] pt-11 pb-6 px-6 flex flex-col shadow-lg relative overflow-hidden shrink-0">
      {/* Background cloud pattern or light fade */}
      <div className="absolute top-0 left-0 w-full h-full overflow-hidden opacity-30 pointer-events-none">
        <div className="absolute -top-10 -left-10 w-40 h-40 bg-white rounded-full blur-3xl" />
        <div className="absolute top-10 -right-10 w-40 h-40 bg-white rounded-full blur-3xl" />
      </div>
      <div className="flex items-center w-full relative z-10">
        {showBack ? (
          <button onClick={onBack} className="p-1 hover:bg-white/20 rounded-full transition-colors">
            <ChevronLeft size={24} />
          </button>
        ) : (
          <div className="w-8" />
        )}
        <h1 className="flex-1 text-center font-bold text-lg tracking-wide uppercase">{title}</h1>
        {rightIcon ? rightIcon : <div className="w-8" />}
      </div>
    </div>
  )
}
