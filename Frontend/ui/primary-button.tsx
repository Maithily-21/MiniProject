"use client"

import type React from "react"
import { motion } from "framer-motion"
import { useTheme } from "@/contexts/theme-context"

interface PrimaryButtonProps {
  children: React.ReactNode
  onClick?: () => void
  className?: string
  disabled?: boolean
}

export function PrimaryButton({ children, onClick, className = "", disabled = false }: PrimaryButtonProps) {
  const { colors } = useTheme()

  return (
    <motion.button
      whileHover={{ scale: 1.05 }}
      whileTap={{ scale: 0.95 }}
      className={`rounded-md px-4 py-2 font-medium text-white ${className}`}
      style={{ backgroundColor: colors.primary }}
      onClick={onClick}
      disabled={disabled}
    >
      {children}
    </motion.button>
  )
}
