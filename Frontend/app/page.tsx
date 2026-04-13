import { ThemeProvider } from "@/contexts/theme-context";
import { AuthProvider } from "@/contexts/auth-context";
import { AnalysisFlow } from "@/components/analysis-flow";

export default function Home() {
  return (
    <ThemeProvider>
      <AuthProvider>
        <AnalysisFlow />
      </AuthProvider>
    </ThemeProvider>
  );
}
