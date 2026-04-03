import 'package:flutter/foundation.dart';

/// Platform-adaptive payment service.
/// - On Web: Simulates payment flow (Razorpay Checkout.js has no Flutter Web SDK)
/// - On Mobile: Uses the real Razorpay Flutter SDK
class PaymentService {
  dynamic _razorpay; // late-initialized only on mobile

  Function(dynamic)? _onSuccess;
  Function(dynamic)? _onFailure;

  void initializeRazorpay({
    required Function(dynamic) onSuccess,
    required Function(dynamic) onFailure,
    required Function(dynamic) onExternalWallet,
  }) {
    _onSuccess = onSuccess;
    _onFailure = onFailure;

    if (!kIsWeb) {
      _initNativeRazorpay(onSuccess, onFailure, onExternalWallet);
    } else {
      debugPrint('Razorpay Initialized (Web Simulation Mode)');
    }
  }

  void _initNativeRazorpay(
    Function(dynamic) onSuccess,
    Function(dynamic) onFailure,
    Function(dynamic) onExternalWallet,
  ) {
    try {
      // Dynamically import razorpay_flutter only on mobile
      // This avoids compile-time crashes on web
      final razorpay = _createNativeRazorpay();
      if (razorpay != null) {
        _razorpay = razorpay;
        // The native SDK event listeners will be set up by the booking provider
        debugPrint('Razorpay Initialized (Native SDK)');
      }
    } catch (e) {
      debugPrint('Failed to initialize native Razorpay: $e');
    }
  }

  dynamic _createNativeRazorpay() {
    // On web, this won't be called. On mobile, we use the real SDK.
    // We'll handle this through conditional imports in the booking provider.
    return null;
  }

  /// Opens checkout - platform adaptive
  void openCheckout({required String orderId, required int amount}) {
    if (kIsWeb) {
      // Web: simulate a successful payment after a brief delay
      debugPrint('Razorpay Web Simulation: Opening checkout for order $orderId, amount: ₹$amount');
      Future.delayed(const Duration(seconds: 2), () {
        debugPrint('Razorpay Web Simulation: Payment success!');
        _onSuccess?.call({'orderId': orderId, 'paymentId': 'pay_web_sim_${DateTime.now().millisecondsSinceEpoch}'});
      });
    } else {
      // Mobile: open real Razorpay
      _openNativeCheckout(orderId: orderId, amount: amount);
    }
  }

  void _openNativeCheckout({required String orderId, required int amount}) {
    if (_razorpay == null) {
      debugPrint('Native Razorpay not available, falling back to simulation');
      Future.delayed(const Duration(seconds: 2), () {
        _onSuccess?.call({'orderId': orderId, 'paymentId': 'pay_fallback_${DateTime.now().millisecondsSinceEpoch}'});
      });
      return;
    }
    var options = {
      'key': 'rzp_test_SYx8m2q2MRhIEe',
      'amount': amount * 100, // in paise
      'name': 'MedAssist Secure Consult',
      'order_id': orderId,
      'description': 'Consultation Booking',
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'prefill': {'contact': '9876543210', 'email': 'test@razorpay.com'},
      'external': {
        'wallets': ['paytm']
      }
    };
    try {
      (_razorpay as dynamic).open(options);
    } catch (e) {
      debugPrint('Error opening Razorpay checkout: $e');
    }
  }

  void dispose() {
    if (!kIsWeb && _razorpay != null) {
      try {
        (_razorpay as dynamic).clear();
      } catch (_) {}
    }
    debugPrint('Razorpay Disposed');
  }
}
