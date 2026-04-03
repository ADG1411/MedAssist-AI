import 'package:flutter/foundation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

/// Native Razorpay payment service for Android/iOS APK.
/// No web simulation — this is APK-first.
class PaymentService {
  late final Razorpay _razorpay;

  Function(PaymentSuccessResponse)? _onSuccess;
  Function(PaymentFailureResponse)? _onFailure;
  Function(ExternalWalletResponse)? _onExternalWallet;

  PaymentService() {
    _razorpay = Razorpay();
  }

  void initializeRazorpay({
    required Function(dynamic) onSuccess,
    required Function(dynamic) onFailure,
    required Function(dynamic) onExternalWallet,
  }) {
    _onSuccess = (PaymentSuccessResponse response) {
      debugPrint('✅ Payment Success: ${response.paymentId}');
      onSuccess({
        'razorpay_payment_id': response.paymentId,
        'razorpay_order_id': response.orderId,
        'razorpay_signature': response.signature,
      });
    };

    _onFailure = (PaymentFailureResponse response) {
      debugPrint('❌ Payment Failed: ${response.code} - ${response.message}');
      onFailure({
        'code': response.code,
        'message': response.message,
      });
    };

    _onExternalWallet = (ExternalWalletResponse response) {
      debugPrint('💳 External Wallet: ${response.walletName}');
      onExternalWallet({
        'walletName': response.walletName,
      });
    };

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onSuccess!);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onFailure!);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet!);

    debugPrint('✅ Razorpay SDK Initialized (Native)');
  }

  /// Open Razorpay checkout with a real order
  void openCheckout({required String orderId, required int amount}) {
    var options = {
      'key': 'rzp_test_SYx8m2q2MRhIEe',
      'amount': amount * 100, // Razorpay expects paise
      'name': 'MedAssist',
      'order_id': orderId,
      'description': 'Doctor Consultation Booking',
      'retry': {'enabled': true, 'max_count': 2},
      'send_sms_hash': true,
      'prefill': {
        'contact': '',
        'email': '',
      },
      'theme': {
        'color': '#2E62F1',
      },
    };

    try {
      debugPrint('🔄 Opening Razorpay Checkout: order=$orderId, amount=₹$amount');
      _razorpay.open(options);
    } catch (e) {
      debugPrint('❌ Razorpay open() error: $e');
    }
  }

  void dispose() {
    _razorpay.clear();
    debugPrint('Razorpay Disposed');
  }
}
