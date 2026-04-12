"use client"

import { useState } from "react"
import { ChevronDown } from "lucide-react"
import { useTheme } from "@/contexts/theme-context"
import { cn } from "@/lib/utils"
import { motion, AnimatePresence } from "framer-motion"

interface AnimatedDropdownProps {
  options: string[]
  placeholder?: string
  className?: string
}

export function AnimatedDropdown({ options, placeholder = "Select option", className }: AnimatedDropdownProps) {
  const { colors } = useTheme()
  const [isOpen, setIsOpen] = useState(false)
  const [selected, setSelected] = useState<string | null>(null)

  return (
    <div className={cn("relative inline-block text-left", className)}>
      <motion.button
        onClick={() => setIsOpen(!isOpen)}
        className="flex items-center justify-between w-48 px-4 py-2 text-sm font-medium rounded-md border focus:outline-none"
        style={{
          backgroundColor: colors.background.main,
          color: colors.text.primary,
          borderColor: colors.border,
        }}
        whileHover={{ scale: 1.02 }}
        whileTap={{ scale: 0.98 }}
      >
        {selected || placeholder}
        <motion.div animate={{ rotate: isOpen ? 180 : 0 }} transition={{ duration: 0.2 }}>
          <ChevronDown className="w-4 h-4 ml-2" />
        </motion.div>
      </motion.button>

      <AnimatePresence>
        {isOpen && (
          <motion.div
            initial={{ opacity: 0, y: -10, scale: 0.95 }}
            animate={{ opacity: 1, y: 0, scale: 1 }}
            exit={{ opacity: 0, y: -10, scale: 0.95 }}
            transition={{ duration: 0.2 }}
            className="absolute right-0 z-10 w-48 mt-2 origin-top-right rounded-md shadow-lg border"
            style={{
              backgroundColor: colors.background.main,
              borderColor: colors.border,
            }}
          >
            <div className="py-1">
              {options.map((option, index) => (
                <motion.button
                  key={option}
                  initial={{ opacity: 0, x: -10 }}
                  animate={{ opacity: 1, x: 0 }}
                  transition={{ delay: index * 0.05 }}
                  onClick={() => {
                    setSelected(option)
                    setIsOpen(false)
                  }}
                  className="block w-full px-4 py-2 text-sm text-left hover:bg-opacity-10 transition-colors duration-150"
                  style={{
                    color: colors.text.primary,
                    backgroundColor: selected === option ? `${colors.primary}20` : "transparent",
                  }}
                  whileHover={{ x: 4, backgroundColor: `${colors.primary}10` }}
                >
                  {option}
                </motion.button>
              ))}
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  )
}
