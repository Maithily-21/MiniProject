export function FloatingMessage({ message }: { message: string }) {
  return (
    <div className="bg-white rounded-[1.5rem] p-3 px-4 shadow-lg flex items-center gap-4 mx-6 mb-2 border border-blue-50/50 transform translate-y-2">
      <div className="w-10 h-10 bg-[#E8F1FF] rounded-full flex items-center justify-center shrink-0">
        <svg viewBox="0 0 24 24" fill="none" className="w-6 h-6 text-[#1D4ED8]">
          <path d="M12 2C6.48 2 2 6.48 2 12C2 17.52 6.48 22 12 22C17.52 22 22 17.52 22 12C22 6.48 17.52 2 12 2ZM15.5 10.5C14.67 10.5 14 9.83 14 9C14 8.17 14.67 7.5 15.5 7.5C16.33 7.5 17 8.17 17 9C17 9.83 16.33 10.5 15.5 10.5ZM8.5 10.5C7.67 10.5 7 9.83 7 9C7 8.17 7.67 7.5 8.5 7.5C9.33 7.5 10 8.17 10 9C10 9.83 9.33 10.5 8.5 10.5ZM12 17.5C9.5 17.5 7.4 15.82 6.5 13.5H17.5C16.6 15.82 14.5 17.5 12 17.5Z" fill="currentColor"/>
        </svg>
      </div>
      <p className="text-[#3A5D84] text-[13px] font-medium leading-tight">
        {message}
      </p>
    </div>
  )
}
