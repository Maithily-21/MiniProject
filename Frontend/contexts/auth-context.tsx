"use client"

import {
  createContext,
  useContext,
  useState,
  useEffect,
  useCallback,
  type ReactNode,
} from "react"
import {
  loginUser,
  registerUser,
  fetchCurrentUser,
  type UserProfile,
} from "@/lib/api"

// ─── Types ────────────────────────────────────────────────────────────────────

interface AuthState {
  token: string | null
  user: UserProfile | null
  loading: boolean
  error: string | null
}

interface AuthContextValue extends AuthState {
  login: (email: string, password: string) => Promise<void>
  register: (email: string, password: string) => Promise<void>
  logout: () => void
  clearError: () => void
}

// ─── Context ──────────────────────────────────────────────────────────────────

const AuthContext = createContext<AuthContextValue | null>(null)

export function useAuth(): AuthContextValue {
  const ctx = useContext(AuthContext)
  if (!ctx) throw new Error("useAuth must be used inside <AuthProvider>")
  return ctx
}

// ─── Provider ─────────────────────────────────────────────────────────────────

export function AuthProvider({ children }: { children: ReactNode }) {
  const [state, setState] = useState<AuthState>({
    token: null,
    user: null,
    loading: true,
    error: null,
  })

  // Hydrate from localStorage on mount
  useEffect(() => {
    const stored = localStorage.getItem("token")
    if (stored) {
      setState((s) => ({ ...s, token: stored }))
      fetchCurrentUser()
        .then((user) => setState((s) => ({ ...s, user, loading: false })))
        .catch(() => {
          localStorage.removeItem("token")
          setState((s) => ({ ...s, token: null, loading: false }))
        })
    } else {
      setState((s) => ({ ...s, loading: false }))
    }
  }, [])

  const login = useCallback(async (email: string, password: string) => {
    setState((s) => ({ ...s, loading: true, error: null }))
    try {
      const { access_token } = await loginUser(email, password)
      localStorage.setItem("token", access_token)
      const user = await fetchCurrentUser()
      setState({ token: access_token, user, loading: false, error: null })
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : "Login failed"
      setState((s) => ({ ...s, loading: false, error: msg }))
      throw err
    }
  }, [])

  const register = useCallback(async (email: string, password: string) => {
    setState((s) => ({ ...s, loading: true, error: null }))
    try {
      const { access_token } = await registerUser(email, password)
      localStorage.setItem("token", access_token)
      const user = await fetchCurrentUser()
      setState({ token: access_token, user, loading: false, error: null })
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : "Registration failed"
      setState((s) => ({ ...s, loading: false, error: msg }))
      throw err
    }
  }, [])

  const logout = useCallback(() => {
    localStorage.removeItem("token")
    setState({ token: null, user: null, loading: false, error: null })
  }, [])

  const clearError = useCallback(() => {
    setState((s) => ({ ...s, error: null }))
  }, [])

  return (
    <AuthContext.Provider
      value={{ ...state, login, register, logout, clearError }}
    >
      {children}
    </AuthContext.Provider>
  )
}
