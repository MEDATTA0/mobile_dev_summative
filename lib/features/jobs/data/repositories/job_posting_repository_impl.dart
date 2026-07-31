import 'package:mobile_dev_summative/core/repositories/base_repository.dart';
import 'package:mobile_dev_summative/features/jobs/domain/repositories/job_posting_repository.dart';
import 'package:mobile_dev_summative/features/jobs/models/employment_type.dart';
import 'package:mobile_dev_summative/features/jobs/models/job_posting.dart';

class JobPostingRepositoryImpl extends BaseRepository<JobPosting>
    implements JobPostingRepository {
  JobPostingRepositoryImpl() : super('job_postings', JobPosting.fromMap);

  Future<void> _seedIfEmpty() async {
    final existing = await collectionRef.limit(1).get();
    if (existing.docs.isNotEmpty) return;

    final now = DateTime.now();
    final mockPostings = [
      JobPosting(
        id: '',
        createdAt: now,
        updatedAt: now,
        title: 'ERP Analyst',
        company: 'TechBridge Kigali',
        employmentType: EmploymentType.fullTime,
        location: 'Kigali, Rwanda',
        description:
            'Support and optimize our ERPNext deployment, working closely '
            'with finance and operations teams to streamline business '
            'processes.',
        postedAt: now.subtract(const Duration(days: 2)),
      ),
      JobPosting(
        id: '',
        createdAt: now,
        updatedAt: now,
        title: 'Frappe Developer',
        company: 'Digital Solutions Ltd',
        employmentType: EmploymentType.contract,
        location: 'Remote',
        description:
            'Build and customize Frappe framework apps for clients across '
            'East Africa, contributing to open-source modules where '
            'possible.',
        postedAt: now.subtract(const Duration(days: 3)),
      ),
      JobPosting(
        id: '',
        createdAt: now,
        updatedAt: now,
        title: 'ERPNext Consultant',
        company: 'BizTech Africa',
        employmentType: EmploymentType.fullTime,
        location: 'Kigali, Rwanda',
        description:
            'Guide clients through ERPNext implementation, configuration, '
            'and training as part of our consulting team.',
        postedAt: now.subtract(const Duration(days: 5)),
      ),
      JobPosting(
        id: '',
        createdAt: now,
        updatedAt: now,
        title: 'Junior ERP Support',
        company: 'InnovateCo',
        employmentType: EmploymentType.internship,
        location: 'Kigali, Rwanda',
        description:
            'Provide first-line support for ERP users, troubleshoot issues, '
            'and assist with data entry and reporting tasks. A great entry '
            'point for recent graduates.',
        postedAt: now.subtract(const Duration(days: 7)),
      ),
    ];

    for (final posting in mockPostings) {
      await create(posting);
    }
  }

  @override
  Future<List<JobPosting>> getAll() async {
    await _seedIfEmpty();
    return findAll();
  }

  @override
  Future<JobPosting?> getById(String id) {
    return findById(id);
  }
}
