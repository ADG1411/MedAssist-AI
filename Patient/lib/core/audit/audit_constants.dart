/// Typed constants for audit action types.
abstract class AuditAction {
  static const login = 'login';
  static const logout = 'logout';
  static const profileUpdated = 'profile_updated';
  static const reportUploaded = 'report_uploaded';
  static const doctorBooked = 'doctor_booked';
  static const paymentSuccess = 'payment_success';
  static const paymentFailed = 'payment_failed';
  static const recordShared = 'record_shared';
  static const sosTriggered = 'sos_triggered';
  static const ocrExtracted = 'ocr_extracted';
  static const aiQuery = 'ai_query';
  static const vitalLogged = 'vital_logged';
  static const medicineChecked = 'medicine_checked';
  static const onboardingCompleted = 'onboarding_completed';
  static const recordViewed = 'record_viewed';
  static const qrShared = 'qr_shared';
  static const guardianAdded = 'guardian_added';
}

/// Typed constants for audit modules.
abstract class AuditModule {
  static const auth = 'auth';
  static const profile = 'profile';
  static const records = 'records';
  static const doctors = 'doctors';
  static const payments = 'payments';
  static const sos = 'sos';
  static const ai = 'ai';
  static const vitals = 'vitals';
  static const nutrition = 'nutrition';
  static const healthIdentity = 'health_identity';
  static const onboarding = 'onboarding';
}
