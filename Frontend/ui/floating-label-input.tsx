"use client";

import type React from "react";
import { useState } from "react";
import { useTheme } from "@/contexts/theme-context";

interface FloatingLabelInputProps {
  label: string;
  value: string;
  onChange: (e: React.ChangeEvent<HTMLInputElement>) => void;
  type?: string;
  required?: boolean;
  disabled?: boolean;
  className?: string;
}

export const FloatingLabelInput: React.FC<FloatingLabelInputProps> = ({
  label,
  value,
  onChange,
  type = "text",
  required = false,
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
  };

  const [isFocused, setIsFocused] = useState(false);

  return (
    <div className={`relative ${className}`}>
      <input
        type={type}
        value={value}
        onChange={onChange}
        required={required}
        disabled={disabled}
        onFocus={() => setIsFocused(true)}
        onBlur={() => setIsFocused(false)}
        className="block w-full rounded-md px-3 pt-2 pb-2 text-base transition-all duration-200 ease-in-out"
        style={{
          backgroundColor: disabled
            ? colors.background.dark
            : colors.background.light,
          color: colors.text.primary,
          border: `1px solid ${isFocused ? colors.primary : colors.border}`,
          outline: "none",
          opacity: disabled ? 0.6 : 1,
        }}
      />
      <label
        className={`absolute left-3 top-0 z-10 transition-all duration-200 ease-in-out pointer-events-none`}
        style={{
          backgroundColor: colors.background.light,
          color: isFocused ? colors.primary : colors.text.secondary,
          transform:
            isFocused || value
              ? "translateY(-0.5rem) scale(0.85)"
              : "translateY(0.5rem) scale(1)",
          transformOrigin: "top left",
        }}
      >
        {label} {required && <span className="text-red-500">*</span>}
      </label>
    </div>
  );
};

export default FloatingLabelInput;
