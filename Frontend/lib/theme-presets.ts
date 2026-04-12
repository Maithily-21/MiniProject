import type { ThemeColors } from "@/contexts/theme-context"

// Helper function to get theme based on mode
export function getThemeByPreset(): ThemeColors {
    return {
        "primary": "#0ea5e9",
        "secondary": "#06b6d4",
        "accent": "#14b8a6",
        "background": {
            "main": "#ffffff",
            "light": "#f0f9ff",
            "dark": "#e0f2fe"
        },
        "text": {
            "primary": "#0c4a6e",
            "secondary": "#0369a1",
            "muted": "#7dd3fc"
        },
        "border": "#bae6fd",
        "shadow": "0 4px 6px -1px rgba(14, 165, 233, 0.1), 0 2px 4px -1px rgba(14, 165, 233, 0.06)",
        "dropShadow": "drop-shadow(0 4px 3px rgb(14 165 233 / 0.07)) drop-shadow(0 2px 2px rgb(14 165 233 / 0.06))",
        "backdropFilter": "blur(8px)",
        "semantic": {
            "info": {
                "border": "#0284c7",
                "text": "#0369a1"
            },
            "success": {
                "border": "#14b8a6",
                "text": "#0d9488"
            },
            "warning": {
                "border": "#f59e0b",
                "text": "#b45309"
            },
            "error": {
                "border": "#ef4444",
                "text": "#b91c1c"
            }
        },
        "gradients": {
            "primary": "linear-gradient(90deg, #0ea5e9, #06b6d4)",
            "subtle": "linear-gradient(180deg, rgba(14,165,233,0.08), rgba(14,165,233,0))"
        }
    }
}
