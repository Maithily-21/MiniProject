import { ThemeProvider } from "@/contexts/theme-context";
import { AnalysisFlow } from "@/components/analysis-flow";

export default function Home() {
  return (
    <ThemeProvider>
      <AnalysisFlow />
    </ThemeProvider>
  );
}
