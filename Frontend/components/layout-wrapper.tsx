import { BottomNav } from "./bottom-nav"
import { FloatingMessage } from "./floating-message"

export function LayoutWrapper({ 
  children,
  floatingMessage,
  showChat = true,
  showBottomNav = true,
  activeTab,
  onTabChange,
}: { 
  children: React.ReactNode;
  floatingMessage?: string;
  showChat?: boolean;
  showBottomNav?: boolean;
  activeTab: 'home' | 'reports';
  onTabChange: (tab: 'home' | 'reports') => void;
}) {

  return (
    <div className="w-full h-full min-h-screen flex justify-center bg-gray-50 font-sans">
      <div className="w-full max-w-md bg-gradient-to-b from-[#DCEAFF] to-[#F4F9FF] h-screen flex flex-col overflow-hidden relative shadow-2xl">
        {/* Background Decorative Elements */}
        <div className="absolute top-0 left-0 w-full h-full overflow-hidden pointer-events-none opacity-50 z-0">
           <div className="absolute top-[5%] -left-[20%] w-[120%] h-[40%] bg-white/60 rounded-[100%] blur-3xl" />
           <div className="absolute top-[50%] -right-[20%] w-[120%] h-[50%] bg-white/40 rounded-[100%] blur-3xl" />
        </div>

        {/* Content Area */}
        <div className="flex-1 flex flex-col z-10 overflow-y-auto no-scrollbar pb-2">
          {children}
        </div>

        <div className="flex flex-col z-20 shrink-0 bg-transparent pt-4">
          {/* Floating Message */}
          {floatingMessage && (
            <div className="w-full">
              <FloatingMessage message={floatingMessage} />
            </div>
          )}

          {/* Bottom Nav with built-in Chat */}
          {showBottomNav && (
            <div className="w-full mt-2">
              <BottomNav activeTab={activeTab} onTabChange={onTabChange} showChat={showChat} />
            </div>
          )}
        </div>
      </div>
    </div>
  )
}
