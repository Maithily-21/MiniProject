import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../widgets/app_header.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reports = [
      {
        'id': 1,
        'date': 'April 10, 2024',
        'title': 'Slightly Irregular Alignment',
        'status': 'Provisional',
        'isReviewed': false,
      },
      {
        'id': 2,
        'date': 'March 15, 2024',
        'title': 'Healthy Gums & Detection',
        'status': 'Reviewed',
        'isReviewed': true,
      },
    ];

    return Column(
      children: [
        const AppHeader(title: 'My Reports', showBack: false),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ReportCard(report: report),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ReportCard extends StatelessWidget {
  final Map<String, dynamic> report;

  const _ReportCard({required this.report});

  @override
  Widget build(BuildContext context) {
    final bool isReviewed = report['isReviewed'] as bool;
    final statusColor = isReviewed ? AppColors.success : AppColors.primaryEnd;
    final statusBg = isReviewed
        ? AppColors.success.withOpacity(0.1)
        : AppColors.primaryEnd.withOpacity(0.1);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: const [
          BoxShadow(color: Color(0x0F1E60DC), blurRadius: 10, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, color: AppColors.textLight, size: 14),
              const SizedBox(width: 6),
              Text(
                (report['date'] as String).toUpperCase(),
                style: const TextStyle(
                  color: AppColors.textLight,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  report['status'] as String,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceLight,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_circle_outline_rounded,
                    color: AppColors.primaryEnd,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report['title'] as String,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Full scan complete',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textLight, size: 22),
            ],
          ),
        ],
      ),
    );
  }
}
