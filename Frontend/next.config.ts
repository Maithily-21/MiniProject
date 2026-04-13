import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  /**
   * Proxy /api/* to the FastAPI backend during development.
   * This avoids CORS issues and keeps the frontend code origin-agnostic.
   */
  async rewrites() {
    return [
      {
        source: "/api/:path*",
        destination: "http://localhost:8000/:path*",
      },
    ];
  },
};

export default nextConfig;
