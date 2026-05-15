import 'package:flutter/foundation.dart';

import '../models/analysis_result.dart';

enum AppStep {
  signIn,
  details,
  analyzeStart,
  upload,
  report,
  assistant,
}

enum ActiveTab { home, reports }

class PatientModel {
  String name;
  String gender;
  String age;
  String phone;

  PatientModel({
    this.name = '',
    this.gender = 'Male',
    this.age = '',
    this.phone = '',
  });

  PatientModel copyWith({
    String? name,
    String? gender,
    String? age,
    String? phone,
  }) {
    return PatientModel(
      name: name ?? this.name,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      phone: phone ?? this.phone,
    );
  }
}

class ReportItem {
  final String label;
  final String value;
  final int? score;
  final bool isSuccess;

  const ReportItem({
    required this.label,
    required this.value,
    this.score,
    required this.isSuccess,
  });
}

class AppProvider extends ChangeNotifier {
  AppStep _step = AppStep.signIn;
  ActiveTab _activeTab = ActiveTab.home;
  int _currentQuestionIndex = 0;
  PatientModel _patient = PatientModel();
  final List<bool> _answers = [];
  AnalysisResult? _analysisResult;

  static const List<String> questions = [
    'Do you experience tooth pain?',
    'Do your gums bleed when brushing?',
  ];

  static const List<ReportItem> reportItems = [
    ReportItem(
      label: 'Teeth Alignment',
      value: 'Slightly Irregular',
      score: 75,
      isSuccess: false,
    ),
    ReportItem(
      label: 'Smile Symmetry',
      value: 'Moderate',
      score: 72,
      isSuccess: false,
    ),
    ReportItem(
      label: 'Gum Health',
      value: 'Healthy',
      score: null,
      isSuccess: true,
    ),
  ];

  // Getters
  AppStep get step => _step;
  ActiveTab get activeTab => _activeTab;
  int get currentQuestionIndex => _currentQuestionIndex;
  PatientModel get patient => _patient;
  List<bool> get answers => _answers;
  AnalysisResult? get analysisResult => _analysisResult;

  String get currentQuestion => questions[_currentQuestionIndex];
  int get totalQuestions => questions.length;

  void setAnalysisResult(AnalysisResult result) {
    _analysisResult = result;
    notifyListeners();
  }

  String? get floatingMessage {
    if (_activeTab == ActiveTab.reports) return null;
    switch (_step) {
      case AppStep.signIn:
        return 'Hello! Upload a smile photo to begin your analysis.';
      case AppStep.details:
        return 'Please fill in your details to continue.';
      case AppStep.analyzeStart:
        return 'Please take a clear photo of your smile!';
      case AppStep.upload:
        return 'Your photo is ready for analysis!';
      case AppStep.report:
        return 'Here is your provisional dental analysis report!';
      default:
        return null;
    }
  }

  bool get showFloatingMessage {
    if (_activeTab != ActiveTab.home) return false;
    return [
      AppStep.signIn,
      AppStep.details,
      AppStep.analyzeStart,
      AppStep.upload,
    ].contains(_step);
  }

  // Navigation methods
  void goTo(AppStep step) {
    _step = step;
    notifyListeners();
  }

  void setActiveTab(ActiveTab tab) {
    _activeTab = tab;
    notifyListeners();
  }

  void signIn() {
    _step = AppStep.details;
    notifyListeners();
  }

  void submitDetails() {
    _step = AppStep.analyzeStart;
    notifyListeners();
  }

  void goToUpload() {
    _step = AppStep.upload;
    notifyListeners();
  }

  void startQuestions() {
    _step = AppStep.report;
    notifyListeners();
  }

  void answerQuestion(bool answer) {
    _answers.add(answer);
    if (_currentQuestionIndex < questions.length - 1) {
      _currentQuestionIndex++;
    } else {
      _step = AppStep.report;
    }
    notifyListeners();
  }

  void goBackQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      if (_answers.isNotEmpty) _answers.removeLast();
    } else {
      _step = AppStep.upload;
    }
    notifyListeners();
  }

  void viewDetailedReport() {
    _step = AppStep.assistant;
    notifyListeners();
  }

  void updatePatient(PatientModel patient) {
    _patient = patient;
    notifyListeners();
  }

  void back() {
    switch (_step) {
      case AppStep.details:
        _step = AppStep.signIn;
        break;
      case AppStep.analyzeStart:
        _step = AppStep.details;
        break;
      case AppStep.upload:
        _step = AppStep.analyzeStart;
        break;
      case AppStep.report:
        _step = AppStep.upload;
        break;
      case AppStep.assistant:
        _step = AppStep.report;
        break;
      default:
        break;
    }
    notifyListeners();
  }
}
