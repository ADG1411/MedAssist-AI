import 'package:flutter/foundation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

/// Service wrapper representing the real Razorpay SDK integration.
class PaymentService {
  final Razorpay _razorpay = Razorpay();

  void initializeRazorpay({
    required Function(PaymentSuccessResponse) onSuccess,
    required Function(PaymentFailureResponse) onFailure,
    required Function(ExternalWalletResponse) onExternalWallet,
  }) {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, onSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, onFailure);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, onExternalWallet);
    debugPrint('Razorpay Initialized (SDK)');
  }

  void openCheckout({required String orderId, required int amount}) {
    var options = {
      'key': 'rzp_test_SYx8m2q2MRhIEe', // Hardcoded for this environment per user request
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
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error opening Razorpay checkout: $e');
    }
  }

  void dispose() {
    _razorpay.clear();
    debugPrint('Razorpay Disposed (SDK)');
  }
}
