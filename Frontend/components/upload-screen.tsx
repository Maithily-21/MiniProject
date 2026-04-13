"use client"

import { useState, useRef } from "react"
import { Header } from "./ui/header"
import { Camera, Image as ImageIcon, Loader2 } from "lucide-react"
import { analyzeImage, type AnalysisResult } from "@/lib/api"

interface UploadScreenProps {
  onAnalyze: (result: AnalysisResult) => void
  onBack: () => void
}

export function UploadScreen({ onAnalyze, onBack }: UploadScreenProps) {
  const [selectedFile, setSelectedFile] = useState<File | null>(null)
  const [preview, setPreview] = useState<string | null>(null)
  const [uploading, setUploading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const fileInputRef = useRef<HTMLInputElement>(null)

  const handleFileSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0]
    if (!file) return
    setSelectedFile(file)
    setError(null)
    const reader = new FileReader()
    reader.onload = (ev) => setPreview(ev.target?.result as string)
    reader.readAsDataURL(file)
  }

  const handleAnalyze = async () => {
    if (!selectedFile) {
      setError("Please select an image first")
      return
    }
    setUploading(true)
    setError(null)
    try {
      const result = await analyzeImage(selectedFile)
      onAnalyze(result)
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : "Analysis failed"
      setError(msg)
    } finally {
      setUploading(false)
    }
  }

  return (
    <div className="flex flex-col h-full">
      <Header 
        title={uploading ? "Analyzing Image..." : "Upload Photo"} 
        onBack={onBack} 
      />

      <div className="flex-1 flex flex-col px-6 py-6 pb-2">
        {/* Image Preview */}
        <div className="w-full aspect-[4/3] rounded-2xl overflow-hidden mb-6 shadow-md bg-white border-4 border-white flex items-center justify-center">
          {preview ? (
            <img 
              src={preview} 
              alt="Selected dental photo" 
              className="w-full h-full object-cover"
            />
          ) : (
            <div className="flex flex-col items-center gap-3 text-[#94b1c9]">
              <Camera size={48} strokeWidth={1.5} />
              <p className="text-[14px] font-medium">No image selected</p>
            </div>
          )}
        </div>

        {error && (
          <div className="mb-4 p-3 rounded-xl bg-red-50 border border-red-200 text-red-600 text-[13px] font-medium text-center">
            {error}
          </div>
        )}

        <input
          id="file-upload-input"
          ref={fileInputRef}
          type="file"
          accept="image/jpeg,image/png,image/webp,image/bmp"
          className="hidden"
          onChange={handleFileSelect}
        />

        <div className="space-y-4 mb-8">
          {selectedFile ? (
            <button 
              id="analyze-button"
              onClick={handleAnalyze}
              disabled={uploading}
              className="w-full py-4 rounded-2xl text-[16px] font-bold gap-3 flex items-center justify-center text-white shadow-[0_8px_20px_rgba(30,96,220,0.25)] active:scale-[0.98] transition-all bg-gradient-to-r from-[#2E6DD1] to-[#1D4ED8] disabled:opacity-60"
            >
              {uploading ? (
                <>
                  <Loader2 size={22} className="animate-spin" />
                  Analyzing...
                </>
              ) : (
                <>
                  <Camera size={22} />
                  Analyze Photo
                </>
              )}
            </button>
          ) : (
            <button 
              id="take-photo-button"
              onClick={() => fileInputRef.current?.click()}
              className="w-full py-4 rounded-2xl text-[16px] font-bold gap-3 flex items-center justify-center text-white shadow-[0_8px_20px_rgba(30,96,220,0.25)] active:scale-[0.98] transition-all bg-gradient-to-r from-[#2E6DD1] to-[#1D4ED8]"
            >
              <Camera size={22} />
              Take a Photo
            </button>
          )}
          
          <button 
            id="gallery-button"
            onClick={() => fileInputRef.current?.click()}
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
