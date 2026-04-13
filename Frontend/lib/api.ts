/**
 * lib/api.ts — Centralised API client for the FastAPI backend.
 *
 * All requests are proxied through Next.js rewrites so they hit
 * `/api/...` on the same origin, avoiding CORS issues in dev.
 */

const API_BASE = "/api";

// ─── Helpers ──────────────────────────────────────────────────────────────────

function authHeaders(): Record<string, string> {
  const token =
    typeof window !== "undefined" ? localStorage.getItem("token") : null;
  return token ? { Authorization: `Bearer ${token}` } : {};
}

async function handleResponse<T>(res: Response): Promise<T> {
  if (!res.ok) {
    const body = await res.json().catch(() => ({ detail: res.statusText }));
    throw new Error(body.detail || "Request failed");
  }
  return res.json() as Promise<T>;
}

// ─── Auth Types ───────────────────────────────────────────────────────────────

export interface TokenResponse {
  access_token: string;
  token_type: string;
}

export interface UserProfile {
  id: number;
  email: string;
  is_active: boolean;
  created_at: string;
}

// ─── Analysis Types ───────────────────────────────────────────────────────────

export interface AnalysisResult {
  alignment_tip: string;
  symmetry_tip: string;
  spacing_tip: string;
  gum_visibility: string;
  cavity_status: string;
  gum_health: string;
  staining_status: string;
  image_url: string;
  mask_url: string | null;
  report: Record<string, unknown>;
  report_id: number;
}

export interface ReportSummary {
  id: number;
  user_id: number;
  image_path: string;
  mask_path: string | null;
  alignment_score: number | null;
  symmetry_score: number | null;
  cavity_result: string | null;
  cavity_confidence: number | null;
  gum_disease_result: string | null;
  gum_confidence: number | null;
  staining_score: number | null;
  staining_result: string | null;
  issues: string | null;
  suggestions: string | null;
  created_at: string;
}

export interface ReportListResponse {
  total: number;
  reports: ReportSummary[];
}

// ─── Auth API ─────────────────────────────────────────────────────────────────

export async function loginUser(
  email: string,
  password: string
): Promise<TokenResponse> {
  const res = await fetch(`${API_BASE}/auth/login`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ email, password }),
  });
  return handleResponse<TokenResponse>(res);
}

export async function registerUser(
  email: string,
  password: string
): Promise<TokenResponse> {
  const res = await fetch(`${API_BASE}/auth/register`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ email, password }),
  });
  return handleResponse<TokenResponse>(res);
}

export async function fetchCurrentUser(): Promise<UserProfile> {
  const res = await fetch(`${API_BASE}/auth/me`, {
    headers: { ...authHeaders() },
  });
  return handleResponse<UserProfile>(res);
}

// ─── Analysis API ─────────────────────────────────────────────────────────────

export async function analyzeImage(file: File): Promise<AnalysisResult> {
  const form = new FormData();
  form.append("file", file);

  const res = await fetch(`${API_BASE}/analyze`, {
    method: "POST",
    headers: { ...authHeaders() },
    body: form,
  });
  return handleResponse<AnalysisResult>(res);
}

// ─── Reports API ──────────────────────────────────────────────────────────────

export async function fetchReports(
  skip = 0,
  limit = 20
): Promise<ReportListResponse> {
  const res = await fetch(
    `${API_BASE}/reports?skip=${skip}&limit=${limit}`,
    { headers: { ...authHeaders() } }
  );
  return handleResponse<ReportListResponse>(res);
}

export async function fetchReport(id: number): Promise<ReportSummary> {
  const res = await fetch(`${API_BASE}/reports/${id}`, {
    headers: { ...authHeaders() },
  });
  return handleResponse<ReportSummary>(res);
}

export async function deleteReport(id: number): Promise<void> {
  const res = await fetch(`${API_BASE}/report/${id}`, {
    method: "DELETE",
    headers: { ...authHeaders() },
  });
  if (!res.ok) {
    const body = await res.json().catch(() => ({ detail: res.statusText }));
    throw new Error(body.detail || "Delete failed");
  }
}
