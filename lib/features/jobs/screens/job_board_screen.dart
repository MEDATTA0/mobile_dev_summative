import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_dev_summative/features/jobs/domain/entities/job_posting.dart';
import 'package:mobile_dev_summative/features/jobs/job_postings_providers.dart';
import 'package:mobile_dev_summative/features/jobs/screens/job_posting_detail_screen.dart';
import 'package:mobile_dev_summative/features/jobs/screens/widgets/job_posting_widgets.dart';

class JobBoardScreen extends ConsumerStatefulWidget {
  const JobBoardScreen({super.key});

  @override
  ConsumerState<JobBoardScreen> createState() => _JobBoardScreenState();
}

class _JobBoardScreenState extends ConsumerState<JobBoardScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final postingsAsync = ref.watch(jobPostingsProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Text('Job board', style: textTheme.headlineSmall),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search ERP roles...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: postingsAsync.when(
                data: (postings) {
                  final filtered = postings.where((posting) {
                    if (_query.isEmpty) return true;
                    return posting.title.toLowerCase().contains(_query) ||
                        posting.company.toLowerCase().contains(_query);
                  }).toList();

                  if (postings.isEmpty) {
                    return const Center(child: Text('No job postings yet'));
                  }
                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text('No roles match your search'),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return _JobPostingCard(posting: filtered[index]);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) =>
                    Center(child: Text('Failed to load job postings: $error')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JobPostingCard extends StatelessWidget {
  const _JobPostingCard({required this.posting});

  final JobPosting posting;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => JobPostingDetailScreen(posting: posting),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CompanyAvatar(company: posting.company),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(posting.title, style: textTheme.titleMedium),
                      Text(
                        posting.company,
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            EmploymentTypeChip(type: posting.employmentType),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 16,
                  color: Colors.redAccent,
                ),
                const SizedBox(width: 4),
                Text(
                  posting.location,
                  style: textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade700,
                  ),
                ),
                const Spacer(),
                Text(
                  formatPostedAgo(posting.postedAt),
                  style: textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
