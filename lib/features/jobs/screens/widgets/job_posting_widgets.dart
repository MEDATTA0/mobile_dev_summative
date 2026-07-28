import 'package:flutter/material.dart';
import 'package:mobile_dev_summative/features/jobs/domain/entities/employment_type.dart';

class CompanyAvatar extends StatelessWidget {
  const CompanyAvatar({super.key, required this.company});

  final String company;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.teal.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(
        company.isNotEmpty ? company[0].toUpperCase() : '?',
        style: TextStyle(
          color: Colors.teal.shade800,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }
}

class EmploymentTypeChip extends StatelessWidget {
  const EmploymentTypeChip({super.key, required this.type});

  final EmploymentType type;

  @override
  Widget build(BuildContext context) {
    final (background, foreground, label) = switch (type) {
      EmploymentType.fullTime => (
        Colors.green.shade100,
        Colors.green.shade800,
        'Full-time',
      ),
      EmploymentType.contract => (
        Colors.deepPurple.shade50,
        Colors.deepPurple.shade700,
        'Contract',
      ),
      EmploymentType.internship => (
        Colors.teal.shade50,
        Colors.teal.shade700,
        'Internship',
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

String formatPostedAgo(DateTime postedAt) {
  final diff = DateTime.now().difference(postedAt);
  if (diff.inDays <= 0) return 'today';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
  return '${(diff.inDays / 30).floor()}mo ago';
}
