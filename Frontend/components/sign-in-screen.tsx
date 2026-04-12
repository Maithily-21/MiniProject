"use client"

import { MessageSquare } from "lucide-react"

export function SignInScreen({ onSignIn }: { onSignIn: () => void }) {
  return (
    <div className="flex flex-col h-full p-6 pb-2 justify-center">
      <div className="flex-1 flex flex-col justify-center w-full">
        {/* Logo and Title */}
        <div className="text-center mb-8 flex flex-col items-center">
          <div className="relative mb-5">
            <div className="w-[5.5rem] h-[5.5rem] flex items-center justify-center text-[#2E6DD1]">
              <svg viewBox="0 0 100 100" fill="currentColor" className="w-full h-full drop-shadow-[0_8px_16px_rgba(46,109,209,0.25)]">
                 <path d="M50 8 C25 8 8 26 8 50 C8 62.5 13.5 73.5 22.5 81 L19 93 L32.5 89.5 C38.5 91.5 45 92 50 92 C75 92 92 74 92 50 C92 26 75 8 50 8 Z" />
              </svg>
              {/* White tooth inside the bubble */}
              <div className="absolute inset-0 flex items-center justify-center pb-2">
                <svg viewBox="0 0 24 24" fill="white" className="w-10 h-10">
                   <path d="M12 21 C8 21 5 18 5 14 C5 10 7 7 12 7 C17 7 19 10 19 14 C19 18 16 21 12 21 Z" />
                   <path d="M12 21 V14" stroke="#2E6DD1" strokeWidth="2" strokeLinecap="round" />
                   <path d="M9 21 V17" stroke="#2E6DD1" strokeWidth="2" strokeLinecap="round" />
                   <path d="M15 21 V17" stroke="#2E6DD1" strokeWidth="2" strokeLinecap="round" />
                </svg>
              </div>
            </div>
          </div>
          <h1 className="text-[2.2rem] font-extrabold mb-1 tracking-tight text-[#1D4ED8]">
            Provident
          </h1>
          <p className="font-semibold text-[14px] text-[#5A7B9B]">
            AI Smile Analysis Assistant
          </p>
        </div>

        {/* Login Form */}
        <div className="mb-7 px-2">
          <h2 className="text-[13px] font-semibold mb-5 text-center text-[#5A7B9B]">
            Sign in to start analyzing your smile photos.
          </h2>

          <div className="space-y-4">
            <input 
              className="w-full bg-white px-5 py-4 rounded-2xl text-[15px] font-medium shadow-[0_2px_10px_rgba(30,96,220,0.04)] border border-blue-50 outline-none text-[#3A5D84] placeholder-[#94b1c9]"
              placeholder="Email" 
              type="email"
            />
            <div className="relative">
              <input 
                className="w-full bg-white px-5 py-4 rounded-2xl text-[15px] font-medium shadow-[0_2px_10px_rgba(30,96,220,0.04)] border border-blue-50 outline-none text-[#3A5D84] placeholder-[#94b1c9]"
                placeholder="Password" 
                type="password"
              />
              <button className="absolute right-5 top-1/2 -translate-y-1/2 text-[12px] font-bold text-[#4A88EF]">
                Forgot password?
              </button>
            </div>

            <div className="pt-2">
              <button
                onClick={onSignIn}
                className="w-full py-4 rounded-2xl text-[16px] font-bold text-white shadow-[0_8px_20px_rgba(30,96,220,0.25)] active:scale-[0.98] transition-all bg-gradient-to-r from-[#2E6DD1] to-[#1D4ED8]"
              >
                Sign In
              </button>
            </div>
          </div>
        </div>

        {/* Social Login */}
        <div className="text-center relative pt-1 mb-5">
          <div className="absolute top-1/2 left-0 w-full h-[1px] bg-blue-100" />
          <span className="relative px-4 text-[12px] font-bold text-[#94b1c9] bg-[#DCEAFF]">
            Or continue with
          </span>
        </div>

        <div className="grid grid-cols-2 gap-4 px-2">
          <button className="flex items-center justify-center py-3.5 bg-white rounded-2xl shadow-[0_2px_10px_rgba(30,96,220,0.04)] border border-blue-50 transition-all active:scale-95">
            <svg viewBox="0 0 24 24" width="22" height="22" xmlns="http://www.w3.org/2000/svg">
              <g transform="matrix(1, 0, 0, 1, 27.009001, -39.238598)">
                <path fill="#4285F4" d="M -3.264 51.509 C -3.264 50.719 -3.334 49.969 -3.454 49.239 L -14.754 49.239 L -14.754 53.749 L -8.284 53.749 C -8.574 55.229 -9.424 56.479 -10.684 57.329 L -10.684 60.329 L -6.824 60.329 C -4.564 58.239 -3.264 55.159 -3.264 51.509 Z"/>
                <path fill="#34A853" d="M -14.754 63.239 C -11.514 63.239 -8.804 62.159 -6.824 60.329 L -10.684 57.329 C -11.764 58.049 -13.134 58.489 -14.754 58.489 C -17.884 58.489 -20.534 56.379 -21.484 53.529 L -25.464 53.529 L -25.464 56.619 C -23.494 60.539 -19.444 63.239 -14.754 63.239 Z"/>
                <path fill="#FBBC05" d="M -21.484 53.529 C -21.734 52.809 -21.864 52.039 -21.864 51.239 C -21.864 50.439 -21.724 49.669 -21.484 48.949 L -21.484 45.859 L -25.464 45.859 C -26.284 47.479 -26.754 49.299 -26.754 51.239 C -26.754 53.179 -26.284 54.999 -25.464 56.619 L -21.484 53.529 Z"/>
                <path fill="#EA4335" d="M -14.754 43.989 C -12.984 43.989 -11.404 44.599 -10.154 45.789 L -6.734 42.369 C -8.804 40.429 -11.514 39.239 -14.754 39.239 C -19.444 39.239 -23.494 41.939 -25.464 45.859 L -21.484 48.949 C -20.534 46.099 -17.884 43.989 -14.754 43.989 Z"/>
              </g>
            </svg>
          </button>
          <button className="flex items-center justify-center py-3.5 bg-white rounded-2xl shadow-[0_2px_10px_rgba(30,96,220,0.04)] border border-blue-50 transition-all active:scale-95">
            <svg viewBox="0 0 24 24" className="w-5 h-5" fill="black">
              <path d="M17.05 20.28c-.98.95-2.05.88-3.08.4-1.09-.5-2.08-.48-3.24 0-1.44.62-2.2.44-3.06-.35C2.79 15.25 3.51 7.59 9.05 7.31c1.35.07 2.29.74 3.08.8 1.18-.04 2.34-.84 3.73-.81 1.63.14 2.87.82 3.66 2.05-3.15 1.83-2.6 5.82.49 7.08-.72 1.81-1.78 3.32-2.96 4.65V20.28zM12.03 7.25c-.15-2.23 1.66-4.07 3.74-4.25.29 2.58-2.34 4.5-3.74 4.25z" />
            </svg>
          </button>
        </div>
      </div>
    </div>
  )
}
