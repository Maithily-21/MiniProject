"use client"

import type React from "react"
import { useState, useRef } from "react"
import { useTheme } from "@/contexts/theme-context"
import { Upload, X, File, ImageIcon, Film, Music, Archive } from "lucide-react"

interface FileUploadInputProps {
  label?: string
  onChange: (files: File[]) => void
  multiple?: boolean
  accept?: string
  maxSize?: number // in MB
  disabled?: boolean
  className?: string
  preview?: boolean
}

export const FileUploadInput: React.FC<FileUploadInputProps> = ({
  label,
  onChange,
  multiple = false,
  accept,
  maxSize,
  disabled = false,
  className = "",
  preview = true,
}) => {
  const { colors } = useTheme() || {
    colors: {
      primary: "#3b82f6",
      secondary: "#6366f1",
      background: { main: "#ffffff", light: "#f9fafb", dark: "#f3f4f6" },
      text: { primary: "#111827", secondary: "#4b5563", muted: "#9ca3af" },
      border: "#e5e7eb",
    },
  }

  const [isDragging, setIsDragging] = useState(false)
  const [files, setFiles] = useState<File[]>([])
  const [error, setError] = useState<string | null>(null)
  const fileInputRef = useRef<HTMLInputElement>(null)

  // Handle file selection
  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files) {
      const fileList = Array.from(e.target.files)
      processFiles(fileList)
    }
  }

  // Process and validate files
  const processFiles = (fileList: File[]) => {
    setError(null)

    // Check file size if maxSize is provided
    if (maxSize) {
      const oversizedFiles = fileList.filter((file) => file.size > maxSize * 1024 * 1024)
      if (oversizedFiles.length > 0) {
        setError(`Some files exceed the maximum size of ${maxSize}MB`)
        return
      }
    }

    // Update files state
    const newFiles = multiple ? [...files, ...fileList] : fileList
    setFiles(newFiles)
    onChange(newFiles)
  }

  // Handle drag events
  const handleDragOver = (e: React.DragEvent<HTMLDivElement>) => {
    e.preventDefault()
    if (!disabled) {
      setIsDragging(true)
    }
  }

  const handleDragLeave = (e: React.DragEvent<HTMLDivElement>) => {
    e.preventDefault()
    setIsDragging(false)
  }

  const handleDrop = (e: React.DragEvent<HTMLDivElement>) => {
    e.preventDefault()
    setIsDragging(false)

    if (!disabled && e.dataTransfer.files) {
      const fileList = Array.from(e.dataTransfer.files)
      processFiles(fileList)
    }
  }

  // Remove a file
  const removeFile = (index: number) => {
    const newFiles = [...files]
    newFiles.splice(index, 1)
    setFiles(newFiles)
    onChange(newFiles)
  }

  // Get file icon based on type
  const getFileIcon = (file: File) => {
    const type = file.type

    if (type.startsWith("image/")) {
      return <ImageIcon size={24} />
    } else if (type.startsWith("video/")) {
      return <Film size={24} />
    } else if (type.startsWith("audio/")) {
      return <Music size={24} />
    } else if (type.startsWith("text/")) {
      return <File size={24} />
    } else if (type.includes("zip") || type.includes("rar") || type.includes("tar")) {
      return <Archive size={24} />
    } else {
      return <File size={24} />
    }
  }

  // Format file size
  const formatFileSize = (size: number) => {
    if (size < 1024) {
      return `${size} B`
    } else if (size < 1024 * 1024) {
      return `${(size / 1024).toFixed(1)} KB`
    } else {
      return `${(size / (1024 * 1024)).toFixed(1)} MB`
    }
  }

  return (
    <div className={`space-y-2 ${className}`}>
      {label && (
        <label className="block text-sm font-medium" style={{ color: colors.text.primary }}>
          {label}
        </label>
      )}
      <div
        onDragOver={handleDragOver}
        onDragLeave={handleDragLeave}
        onDrop={handleDrop}
        onClick={() => fileInputRef.current?.click()}
        className="border-2 border-dashed rounded-md p-6 flex flex-col items-center justify-center cursor-pointer transition-all duration-200"
        style={{
          borderColor: isDragging ? colors.primary : colors.border,
          backgroundColor: isDragging ? `${colors.primary}10` : colors.background.light,
          opacity: disabled ? 0.6 : 1,
        }}
      >
        <Upload size={32} style={{ color: colors.primary, opacity: 0.7 }} />
        <p className="mt-2 text-sm font-medium" style={{ color: colors.text.primary }}>
          {multiple ? "Drop files here or click to browse" : "Drop a file here or click to browse"}
        </p>
        <p className="text-xs mt-1" style={{ color: colors.text.muted }}>
          {maxSize ? `Maximum file size: ${maxSize}MB` : ""}
          {accept ? ` Accepted formats: ${accept}` : ""}
        </p>
        <input
          ref={fileInputRef}
          type="file"
          onChange={handleFileChange}
          multiple={multiple}
          accept={accept}
          disabled={disabled}
          className="hidden"
        />
      </div>

      {error && <p className="text-sm text-red-500 mt-1">{error}</p>}

      {files.length > 0 && (
        <div className="mt-4 space-y-2">
          {files.map((file, index) => (
            <div
              key={index}
              className="flex items-center p-2 rounded-md"
              style={{
                backgroundColor: colors.background.light,
                border: `1px solid ${colors.border}`,
              }}
            >
              <div className="mr-2" style={{ color: colors.text.secondary }}>
                {getFileIcon(file)}
              </div>
              <div className="flex-1 min-w-0">
                <p className="text-sm font-medium truncate" style={{ color: colors.text.primary }}>
                  {file.name}
                </p>
                <p className="text-xs" style={{ color: colors.text.muted }}>
                  {formatFileSize(file.size)}
                </p>
              </div>
              {preview && file.type.startsWith("image/") && (
                <div className="w-10 h-10 mr-2 rounded overflow-hidden">
                  <img
                    src={URL.createObjectURL(file) || "/placeholder.svg"}
                    alt={file.name}
                    className="w-full h-full object-cover"
                  />
                </div>
              )}
              <button
                type="button"
                onClick={(e) => {
                  e.stopPropagation()
                  removeFile(index)
                }}
                className="p-1 rounded-full hover:bg-gray-200"
                style={{ color: colors.text.muted }}
                aria-label={`Remove ${file.name}`}
              >
                <X size={16} />
              </button>
            </div>
          ))}
        </div>
      )}
    </div>
  )
}

export default FileUploadInput
