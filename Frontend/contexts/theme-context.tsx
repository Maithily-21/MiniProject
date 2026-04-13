"use client"

import { getThemeByPreset } from "@/lib/theme-presets"
import type React from "react"
import { createContext, useContext, useState, useEffect } from "react"

// Define theme types
export type ThemeColors = {
  primary: string
  secondary: string
  accent: string
  background: {
    main: string
    light: string
    dark: string
  }
  text: {
    primary: string
    secondary: string
    muted: string
  }
  border: string
  shadow: string
  dropShadow: string
  backdropFilter: string
  // Semantic colors for statuses (used by alerts, badges, etc.)
  semantic: {
    info: { border: string; text: string; icon?: string }
    success: { border: string; text: string; icon?: string }
    warning: { border: string; text: string; icon?: string }
    error: { border: string; text: string; icon?: string }
  }
  // Common gradients
  gradients: {
    primary: string
    subtle: string
  }
}

// Define theme options
export type ThemeOption = "light" | "dark" | "system"

// Define the context type
type ThemeContextType = {
  colors: ThemeColors
}

// Create the context
const ThemeContext = createContext<ThemeContextType | undefined>(undefined)

// Create provider component
export const ThemeProvider = ({ children }: { children: React.ReactNode }) => {
  const [theme, setThemeState] = useState<ThemeOption>("system")
  const [colors, setColors] = useState<ThemeColors>(getThemeByPreset())

  return (
    <ThemeContext.Provider value={{ colors }}>
      {children}
    </ThemeContext.Provider>
  )
}

// Create a hook to use the theme context
export const useTheme = () => {
  const context = useContext(ThemeContext)
  if (context === undefined) {
    throw new Error("useTheme must be used within a ThemeProvider")
  }
  return context
}
