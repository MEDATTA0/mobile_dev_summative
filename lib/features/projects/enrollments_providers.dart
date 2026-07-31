import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_dev_summative/features/projects/data/repositories/enrollment_repository_impl.dart';
import 'package:mobile_dev_summative/features/projects/domain/repositories/enrollment_repository.dart';
import 'package:mobile_dev_summative/features/projects/models/enrollment.dart';

// TODO: replace with the real authenticated uid from Member 1's auth provider
const kCurrentUserId = 'demo-user';

final enrollmentRepositoryProvider = Provider<EnrollmentRepository>((ref) {
  return EnrollmentRepositoryImpl();
});

final enrollmentsProvider = FutureProvider<List<Enrollment>>((ref) {
  return ref.watch(enrollmentRepositoryProvider).getAllForUser(kCurrentUserId);
});