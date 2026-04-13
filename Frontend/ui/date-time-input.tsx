"use client"

import type React from "react"
import { useState } from "react"
import { useTheme } from "@/contexts/theme-context"
import { Calendar, Clock, ChevronLeft, ChevronRight } from "lucide-react"

interface DateTimeInputProps {
  label?: string
  value: Date | null
  onChange: (value: Date | null) => void
  type?: "date" | "time" | "datetime"
  disabled?: boolean
  className?: string
}

export const DateTimeInput: React.FC<DateTimeInputProps> = ({
  label,
  value,
  onChange,
  type = "date",
  disabled = false,
  className = "",
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

  const [isFocused, setIsFocused] = useState(false)
  const [showPicker, setShowPicker] = useState(false)
  const [currentMonth, setCurrentMonth] = useState(value ? new Date(value) : new Date())
  const [currentView, setCurrentView] = useState<"date" | "time">(type === "time" ? "time" : "date")

  // Format date for display
  const formatDate = (date: Date | null): string => {
    if (!date) return ""

    if (type === "date") {
      return date.toLocaleDateString()
    } else if (type === "time") {
      return date.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" })
    } else {
      return `${date.toLocaleDateString()} ${date.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" })}`
    }
  }

  // Get days in month
  const getDaysInMonth = (year: number, month: number) => {
    return new Date(year, month + 1, 0).getDate()
  }

  // Get day of week for first day of month
  const getFirstDayOfMonth = (year: number, month: number) => {
    return new Date(year, month, 1).getDay()
  }

  // Navigate to previous month
  const prevMonth = () => {
    setCurrentMonth(new Date(currentMonth.getFullYear(), currentMonth.getMonth() - 1, 1))
  }

  // Navigate to next month
  const nextMonth = () => {
    setCurrentMonth(new Date(currentMonth.getFullYear(), currentMonth.getMonth() + 1, 1))
  }

  // Handle date selection
  const handleDateSelect = (day: number) => {
    const newDate = new Date(
      currentMonth.getFullYear(),
      currentMonth.getMonth(),
      day,
      value ? value.getHours() : 0,
      value ? value.getMinutes() : 0,
    )

    if (type === "datetime") {
      setCurrentView("time")
    } else {
      onChange(newDate)
      setShowPicker(false)
    }
  }

  // Handle time selection
  const handleTimeChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (!value) return

    const [hours, minutes] = e.target.value.split(":").map(Number)
    const newDate = new Date(value)
    newDate.setHours(hours)
    newDate.setMinutes(minutes)

    onChange(newDate)
  }

  // Handle time confirmation
  const handleTimeConfirm = () => {
    setShowPicker(false)
  }

  // Toggle between date and time views
  const toggleView = () => {
    setCurrentView(currentView === "date" ? "time" : "date")
  }

  // Render calendar
  const renderCalendar = () => {
    const year = currentMonth.getFullYear()
    const month = currentMonth.getMonth()
    const daysInMonth = getDaysInMonth(year, month)
    const firstDay = getFirstDayOfMonth(year, month)

    const days = []
    const weekdays = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]

    // Add weekday headers
    for (let i = 0; i < 7; i++) {
      days.push(
        <div key={`header-${i}`} className="text-center text-xs font-medium py-1">
          {weekdays[i]}
        </div>,
      )
    }

    // Add empty cells for days before first day of month
    for (let i = 0; i < firstDay; i++) {
      days.push(<div key={`empty-${i}`} className="p-2"></div>)
    }

    // Add days of month
    for (let day = 1; day <= daysInMonth; day++) {
      const isSelected = value && value.getDate() === day && value.getMonth() === month && value.getFullYear() === year

      days.push(
        <button
          key={`day-${day}`}
          onClick={() => handleDateSelect(day)}
          className="w-8 h-8 rounded-full flex items-center justify-center text-sm transition-colors"
          style={{
            backgroundColor: isSelected ? colors.primary : "transparent",
            color: isSelected ? "white" : colors.text.primary,
          }}
        >
          {day}
        </button>,
      )
    }

    return days
  }

  // Render time picker
  const renderTimePicker = () => {
    const hours = value ? value.getHours().toString().padStart(2, "0") : "00"
    const minutes = value ? value.getMinutes().toString().padStart(2, "0") : "00"

    return (
      <div className="p-4 flex flex-col items-center">
        <input
          type="time"
          value={`${hours}:${minutes}`}
          onChange={handleTimeChange}
          className="p-2 rounded-md mb-4"
          style={{
            backgroundColor: colors.background.light,
            border: `1px solid ${colors.border}`,
            color: colors.text.primary,
          }}
        />

        {type === "datetime" && (
          <button
            onClick={toggleView}
            className="px-3 py-1 rounded-md text-sm mb-2"
            style={{
              backgroundColor: `${colors.primary}20`,
              color: colors.primary,
            }}
          >
            Back to Date
          </button>
        )}

        <button
          onClick={handleTimeConfirm}
          className="px-4 py-2 rounded-md text-sm"
          style={{
            backgroundColor: colors.primary,
            color: "white",
          }}
        >
          Confirm
        </button>
      </div>
    )
  }

  return (
    <div className={`space-y-2 ${className}`}>
      {label && (
        <label className="block text-sm font-medium" style={{ color: colors.text.primary }}>
          {label}
        </label>
      )}
      <div className="relative">
        <div
          className="flex items-center rounded-md transition-all duration-200"
          style={{
            backgroundColor: disabled ? colors.background.dark : colors.background.light,
            border: `1px solid ${isFocused ? colors.primary : colors.border}`,
            opacity: disabled ? 0.6 : 1,
            boxShadow: isFocused ? `0 0 0 2px ${colors.primary}20` : "none",
          }}
        >
          <div className="px-3" style={{ color: isFocused ? colors.primary : colors.text.muted }}>
            {type === "time" ? <Clock size={16} /> : <Calendar size={16} />}
          </div>
          <input
            type="text"
            value={formatDate(value)}
            readOnly
            onFocus={() => {
              setIsFocused(true)
              if (!disabled) setShowPicker(true)
            }}
            onBlur={() => setIsFocused(false)}
            disabled={disabled}
            className="flex-1 bg-transparent px-0 py-2 outline-none cursor-pointer"
            style={{ color: colors.text.primary }}
          />
          {value && (
            <button
              type="button"
              onClick={() => onChange(null)}
              className="px-3 focus:outline-none"
              style={{ color: colors.text.muted }}
              aria-label="Clear date"
            >
              &times;
            </button>
          )}
        </div>

        {showPicker && (
          <div
            className="absolute mt-1 rounded-md shadow-lg z-10 overflow-hidden"
            style={{
              backgroundColor: colors.background.main,
              border: `1px solid ${colors.border}`,
              width: "280px",
            }}
          >
            {currentView === "date" ? (
              <>
                <div className="flex items-center justify-between p-2 border-b" style={{ borderColor: colors.border }}>
                  <button
                    onClick={prevMonth}
                    className="p-1 rounded-full hover:bg-gray-100"
                    aria-label="Previous month"
                  >
                    <ChevronLeft size={16} />
                  </button>
                  <div className="font-medium">
                    {currentMonth.toLocaleDateString("en-US", { month: "long", year: "numeric" })}
                  </div>
                  <button onClick={nextMonth} className="p-1 rounded-full hover:bg-gray-100" aria-label="Next month">
                    <ChevronRight size={16} />
                  </button>
                </div>
                <div className="grid grid-cols-7 gap-1 p-2">{renderCalendar()}</div>
                {type === "datetime" && (
                  <div className="border-t p-2 flex justify-center" style={{ borderColor: colors.border }}>
                    <button
                      onClick={toggleView}
                      className="px-3 py-1 rounded-md text-sm"
                      style={{
                        backgroundColor: `${colors.primary}20`,
                        color: colors.primary,
                      }}
                    >
                      Set Time
                    </button>
                  </div>
                )}
              </>
            ) : (
              renderTimePicker()
            )}
          </div>
        )}
      </div>
    </div>
  )
}

export default DateTimeInput
