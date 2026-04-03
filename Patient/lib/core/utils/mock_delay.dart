import '../constants/app_constants.dart';

class MockDelay {
  MockDelay._();

  static Future<void> simulateDelay([int ms = AppConstants.defaultMockDelayMs]) async {
    await Future.delayed(Duration(milliseconds: ms));
  }
}

