class AnalysisResult {
  final String alignmentTip;
  final String symmetryTip;
  final String spacingTip;
  final String gumVisibility;
  final String cavityStatus;
  final String gumHealth;
  final String stainingStatus;
  final String imageUrl;
  final String? maskUrl;
  final Map<String, dynamic> report;
  final int reportId;

  AnalysisResult({
    required this.alignmentTip,
    required this.symmetryTip,
    required this.spacingTip,
    required this.gumVisibility,
    required this.cavityStatus,
    required this.gumHealth,
    required this.stainingStatus,
    required this.imageUrl,
    this.maskUrl,
    required this.report,
    required this.reportId,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      alignmentTip: json['alignment_tip'] ?? '',
      symmetryTip: json['symmetry_tip'] ?? '',
      spacingTip: json['spacing_tip'] ?? '',
      gumVisibility: json['gum_visibility'] ?? '',
      cavityStatus: json['cavity_status'] ?? '',
      gumHealth: json['gum_health'] ?? '',
      stainingStatus: json['staining_status'] ?? '',
      imageUrl: json['image_url'] ?? '',
      maskUrl: json['mask_url'],
      report: Map<String, dynamic>.from(json['report'] ?? {}),
      reportId: json['report_id'] ?? 0,
    );
  }
}
