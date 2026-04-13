"use client"

import { useState } from "react"
import { LayoutWrapper } from "./layout-wrapper"
import { SignInScreen } from "./sign-in-screen"
import { PatientRegistration } from "./patient-registration"
import { AnalyzeStartScreen } from "./analyze-start-screen"
import { UploadScreen } from "./upload-screen"
import { QuestionScreen } from "./question-screen"
import { ReportScreen } from "./analysis-report"
import { AssistantScreen } from "./assistant-screen"
import { ReportsScreen } from "./reports-screen"
import { type AnalysisResult } from "@/lib/api"

const QUESTIONS = [
  "Do you experience tooth pain?",
  "Do your gums bleed when brushing?",
  "Are your teeth sensitive to cold or hot?"
]

export function AnalysisFlow() {
  const [activeTab, setActiveTab] = useState<'home' | 'reports'>('home')
  const [step, setStep] = useState<
    "SIGN_IN" | "DETAILS" | "ANALYZE_START" | "UPLOAD" | "QUESTIONS" | "REPORT" | "ASSISTANT"
  >("SIGN_IN")

  const [currentQuestionIndex, setCurrentQuestionIndex] = useState(0)
  const [analysisResult, setAnalysisResult] = useState<AnalysisResult | null>(null)

  const getFloatingMessage = () => {
    if (activeTab === 'reports') return undefined;

    switch (step) {
      case "SIGN_IN":
        return "Hello! Upload a smile photo to begin your analysis."
      case "DETAILS":
        return "Please fill in your details to continue."
      case "ANALYZE_START":
        return "Please take a clear photo of your smile!"
      case "UPLOAD":
        return "Your photo is ready for analysis!"
      case "QUESTIONS":
        return "Answer a few questions for better accuracy."
      case "REPORT":
        return "Here is your provisional dental analysis report!"
      default:
        return undefined
    }
  }

  // Determine when to show the floating message
  const showFloatingMessage = activeTab === 'home' && (step === "ANALYZE_START" || step === "UPLOAD" || step === "QUESTIONS")

  const handleAnswer = (answer: boolean) => {
    if (currentQuestionIndex < QUESTIONS.length - 1) {
      setCurrentQuestionIndex(currentQuestionIndex + 1)
    } else {
      setStep("REPORT")
    }
  }

  const handleQuestionBack = () => {
    if (currentQuestionIndex > 0) {
      setCurrentQuestionIndex(currentQuestionIndex - 1)
    } else {
      setStep("UPLOAD")
    }
  }

  return (
    <LayoutWrapper 
      floatingMessage={showFloatingMessage ? getFloatingMessage() : undefined}
      showChat={step !== "SIGN_IN" && step !== "DETAILS"}
      showBottomNav={step !== "SIGN_IN" && step !== "DETAILS"}
      activeTab={activeTab}
      onTabChange={setActiveTab}
    >
      {activeTab === 'reports' ? (
        <ReportsScreen />
      ) : (
        <>
          {step === "SIGN_IN" && (
            <SignInScreen onSignIn={() => setStep("DETAILS")} />
          )}

          {step === "DETAILS" && (
            <PatientRegistration 
              onBack={() => setStep("SIGN_IN")} 
              onContinue={() => setStep("ANALYZE_START")} 
            />
          )}

          {step === "ANALYZE_START" && (
            <AnalyzeStartScreen 
              onBack={() => setStep("DETAILS")} 
              onUploadPhoto={() => setStep("UPLOAD")} 
            />
          )}

          {step === "UPLOAD" && (
            <UploadScreen 
              onBack={() => setStep("ANALYZE_START")}
              onAnalyze={(result) => {
                setAnalysisResult(result)
                setCurrentQuestionIndex(0);
                setStep("QUESTIONS")
              }} 
            />
          )}

          {step === "QUESTIONS" && (
            <QuestionScreen
              questionNumber={currentQuestionIndex + 1}
              totalQuestions={QUESTIONS.length}
              question={QUESTIONS[currentQuestionIndex]}
              onAnswer={handleAnswer}
              onBack={handleQuestionBack}
            />
          )}

          {step === "REPORT" && (
            <ReportScreen 
              analysisResult={analysisResult}
              onBack={() => setStep("QUESTIONS")}
              onDetailedReport={() => setStep("ASSISTANT")} 
            />
          )}

          {step === "ASSISTANT" && (
            <AssistantScreen 
              analysisResult={analysisResult}
              onBack={() => setStep("REPORT")} 
            />
          )}
        </>
      )}
    </LayoutWrapper>
  )
}
