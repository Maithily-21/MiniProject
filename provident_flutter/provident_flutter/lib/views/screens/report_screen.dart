import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/app_header.dart';
import '../../widgets/primary_button.dart';

class ReportScreen extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onDetailedReport;

  const ReportScreen({
    super.key,
    required this.onBack,
    required this.onDetailedReport,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final analysis = provider.analysisResult;

    final reportItems = analysis != null
        ? [
            ReportItem(
                label: 'Alignment',
                value: analysis.alignmentTip,
                score: null,
                isSuccess: true),
            ReportItem(
                label: 'Symmetry',
                value: analysis.symmetryTip,
                score: null,
                isSuccess: true),
            ReportItem(
                label: 'Staining',
                value: analysis.stainingStatus,
                score: null,
                isSuccess: true),
            ReportItem(
                label: 'Gum Health',
                value: analysis.gumHealth,
                score: null,
                isSuccess: true),
          ]
        : AppProvider.reportItems;

    final cavityText = analysis?.cavityStatus ?? 'No Cavities Detected';
    final recommendations = analysis?.report['recommendations']?.toString() ??
        'Minor alignment irregularities detected. Please consult a dentist for a detailed evaluation.';

    return Column(
      children: [
        AppHeader(title: 'Provisional Analysis Report', onBack: onBack),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            children: [
              ...reportItems.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ReportCard(item: item),
                ),
              ),
              // Cavity detection card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderLight),
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0x0F1E60DC),
                        blurRadius: 10,
                        offset: Offset(0, 2)),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryEnd,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.location_on_outlined,
                            color: Colors.white, size: 12),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Cavity Detection',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 32),
                child: Text(
                  cavityText,
                  style: const TextStyle(
                    color: Color(0xFF8A9EB5),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Recommendations.',
                style: TextStyle(
                  color: AppColors.primaryEnd,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                recommendations,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'View Detailed Report',
                onTap: onDetailedReport,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReportCard extends StatelessWidget {
  final ReportItem item;

  const _ReportCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final statusColor = item.isSuccess ? AppColors.success : AppColors.warning;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0F1E60DC), blurRadius: 10, offset: Offset(0, 2)),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(Icons.check, color: Colors.white, size: 12),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    item.label,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  if (item.score != null) ...[
                    const Spacer(),
                    Text(
                      '${item.score}%',
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(left: 32),
                child: Text(
                  item.value,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          if (item.score != null)
            Positioned(
              right: 0,
              bottom: 0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  width: 80,
                  height: 6,
                  child: LinearProgressIndicator(
                    value: item.score! / 100,
                    backgroundColor: const Color(0xFFF0F0F0),
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
