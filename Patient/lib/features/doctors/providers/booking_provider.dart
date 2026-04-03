import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/payments/payment_service.dart';

class BookingState {
  final String? selectedSlot;
  final bool isProcessingPayment;
  final bool isPaymentSuccess;
  final bool isGeneratingHandoff;

  const BookingState({
    this.selectedSlot,
    this.isProcessingPayment = false,
    this.isPaymentSuccess = false,
    this.isGeneratingHandoff = false,
  });

  BookingState copyWith({
    String? selectedSlot,
    bool? isProcessingPayment,
    bool? isPaymentSuccess,
    bool? isGeneratingHandoff,
  }) {
    return BookingState(
      selectedSlot: selectedSlot ?? this.selectedSlot,
      isProcessingPayment: isProcessingPayment ?? this.isProcessingPayment,
      isPaymentSuccess: isPaymentSuccess ?? this.isPaymentSuccess,
      isGeneratingHandoff: isGeneratingHandoff ?? this.isGeneratingHandoff,
    );
  }
}

class BookingNotifier extends Notifier<BookingState> {
  late final PaymentService _paymentService;

  @override
  BookingState build() {
    _paymentService = PaymentService();
    _paymentService.initializeRazorpay(
      onSuccess: (response) {
        state = state.copyWith(isProcessingPayment: false, isPaymentSuccess: true);
        _generateAiHandoff();
      },
      onFailure: (response) {
        state = state.copyWith(isProcessingPayment: false);
      },
      onExternalWallet: (response) {
        // Handle external wallet
      },
    );
    
    ref.onDispose(() {
      _paymentService.dispose();
    });
    
    return const BookingState();
  }

  void selectSlot(String slot) {
    state = state.copyWith(selectedSlot: slot);
  }

  Future<void> initiatePayment(String doctorId, int amount) async {
    state = state.copyWith(isProcessingPayment: true);
    
    try {
      // Bypassing Deno Edge Function due to offline Docker for testing
      // Direct S2S call to Razorpay from client (TESTING ONLY - SECURITY RISK IN PROD)
      final String basicAuth = 'Basic ${base64Encode(utf8.encode('rzp_test_SYx8m2q2MRhIEe:yj5dXG7HlNRuERi32Dhymgg5'))}';
      
      final response = await http.post(
        Uri.parse('https://api.razorpay.com/v1/orders'),
        headers: {
          'Authorization': basicAuth,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'amount': amount * 100, // exact subunit (paise)
          'currency': 'INR',
          'receipt': 'test_receipt_${DateTime.now().millisecondsSinceEpoch}',
        }),
      );

      if (response.statusCode == 200) {
        final orderData = jsonDecode(response.body);
        final realOrderId = orderData['id'];
        _paymentService.openCheckout(orderId: realOrderId, amount: amount);
      } else {
        debugPrint('Razorpay API Error: ${response.statusCode} - ${response.body}');
        state = state.copyWith(isProcessingPayment: false);
      }
    } catch (e) {
      debugPrint('Failed to generate test order ID: $e');
      state = state.copyWith(isProcessingPayment: false);
    }
  }

  Future<void> _generateAiHandoff() async {
    state = state.copyWith(isGeneratingHandoff: true);
    // Simulate Llama 3.1 generating the brief
    await Future.delayed(const Duration(seconds: 2));
    state = state.copyWith(isGeneratingHandoff: false);
  }
}

final bookingProvider = NotifierProvider<BookingNotifier, BookingState>(BookingNotifier.new);
