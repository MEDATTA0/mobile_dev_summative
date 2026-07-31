import 'package:mobile_dev_summative/features/projects/models/enrollment_status.dart';

/// Decides an enrollment's status purely from its step counts.
/// Submitted once every step is done, otherwise in progress.
EnrollmentStatus enrollmentStatusForProgress(int completedSteps, int totalSteps) {
  return (totalSteps > 0 && completedSteps >= totalSteps)
      ? EnrollmentStatus.submitted
      : EnrollmentStatus.inProgress;
}