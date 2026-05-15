import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../widgets/layout_wrapper.dart';
import 'sign_in_screen.dart';
import 'patient_registration_screen.dart';
import 'analyze_start_screen.dart';
import 'upload_screen.dart';
import 'report_screen.dart';
import 'assistant_screen.dart';
import 'reports_screen.dart';

class AnalysisFlowScreen extends StatelessWidget {
  const AnalysisFlowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();

    return LayoutWrapper(
      activeTab: appProvider.activeTab,
      onTabChange: appProvider.setActiveTab,
      showChat: false,
      floatingMessage:
          appProvider.showFloatingMessage ? appProvider.floatingMessage : null,
      child: _buildCurrentScreen(appProvider),
    );
  }

  Widget _buildCurrentScreen(AppProvider provider) {
    if (provider.activeTab == ActiveTab.reports) {
      return const ReportsScreen();
    }

    switch (provider.step) {
      case AppStep.signIn:
        return SignInScreen(onSignIn: provider.signIn);

      case AppStep.details:
        return PatientRegistrationScreen(
          onBack: () => provider.goTo(AppStep.signIn),
          onContinue: provider.submitDetails,
        );

      case AppStep.analyzeStart:
        return AnalyzeStartScreen(
          onBack: () => provider.goTo(AppStep.details),
          onUploadPhoto: provider.goToUpload,
        );

      case AppStep.upload:
        return UploadScreen(
          onBack: () => provider.goTo(AppStep.analyzeStart),
          onAnalyze: provider.startQuestions,
        );

      case AppStep.report:
        return ReportScreen(
          onBack: () => provider.goTo(AppStep.upload),
          onDetailedReport: provider.viewDetailedReport,
        );

      case AppStep.assistant:
        return AssistantScreen(
          onBack: () => provider.goTo(AppStep.report),
        );
    }
  }
}
