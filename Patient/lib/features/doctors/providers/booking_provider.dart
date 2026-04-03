import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/payments/payment_service.dart';

class BookingState {
  final String? selectedSlot;
  final bool isProcessingPayment;
  final bool isPaymentSuccess;
  final bool isGeneratingHandoff;
  final String? bookingId;
  final String? jitsiRoomId;
  final String? doctorName;
  final String? doctorSpecialty;
  final String? errorMessage;

  const BookingState({
    this.selectedSlot,
    this.isProcessingPayment = false,
    this.isPaymentSuccess = false,
    this.isGeneratingHandoff = false,
    this.bookingId,
    this.jitsiRoomId,
    this.doctorName,
    this.doctorSpecialty,
    this.errorMessage,
  });

  BookingState copyWith({
    String? selectedSlot,
    bool? isProcessingPayment,
    bool? isPaymentSuccess,
    bool? isGeneratingHandoff,
    String? bookingId,
    String? jitsiRoomId,
    String? doctorName,
    String? doctorSpecialty,
    String? errorMessage,
  }) {
    return BookingState(
      selectedSlot: selectedSlot ?? this.selectedSlot,
      isProcessingPayment: isProcessingPayment ?? this.isProcessingPayment,
      isPaymentSuccess: isPaymentSuccess ?? this.isPaymentSuccess,
      isGeneratingHandoff: isGeneratingHandoff ?? this.isGeneratingHandoff,
      bookingId: bookingId ?? this.bookingId,
      jitsiRoomId: jitsiRoomId ?? this.jitsiRoomId,
      doctorName: doctorName ?? this.doctorName,
      doctorSpecialty: doctorSpecialty ?? this.doctorSpecialty,
      errorMessage: errorMessage,
    );
  }
}

class BookingNotifier extends Notifier<BookingState> {
  late final PaymentService _paymentService;
  final _supabase = Supabase.instance.client;

  @override
  BookingState build() {
    _paymentService = PaymentService();
    _paymentService.initializeRazorpay(
      onSuccess: (response) => _onPaymentSuccess(response),
      onFailure: (response) {
        debugPrint('Payment failed: $response');
        state = state.copyWith(
          isProcessingPayment: false,
          errorMessage: 'Payment failed. Please try again.',
        );
      },
      onExternalWallet: (response) {
        debugPrint('External wallet: $response');
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

  /// Full booking lifecycle:
  /// 1. Create pending booking in DB
  /// 2. Create Razorpay order
  /// 3. Open payment checkout
  /// 4. On success → confirm booking + generate Jitsi room
  Future<void> initiatePayment(String doctorId, int amount, {String? doctorName, String? doctorSpecialty}) async {
    state = state.copyWith(
      isProcessingPayment: true,
      errorMessage: null,
      doctorName: doctorName,
      doctorSpecialty: doctorSpecialty,
    );
    
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      state = state.copyWith(isProcessingPayment: false, errorMessage: 'Not logged in');
      return;
    }

    try {
      // Step 1: Create a pending booking in the database
      final bookingResponse = await _supabase.from('bookings').insert({
        'patient_id': userId,
        'doctor_id': doctorId,
        'slot_time': state.selectedSlot ?? 'Unscheduled',
        'amount': amount,
        'status': 'pending',
        'payment_status': 'pending',
        'doctor_name': doctorName,
        'doctor_specialty': doctorSpecialty,
      }).select('id').single();

      final bookingId = bookingResponse['id'] as String;
      final jitsiRoom = 'medassist_${bookingId.substring(0, 8)}';

      state = state.copyWith(bookingId: bookingId, jitsiRoomId: jitsiRoom);

      // Step 2: Create Razorpay order
      final String basicAuth = 'Basic ${base64Encode(utf8.encode('rzp_test_SYx8m2q2MRhIEe:yj5dXG7HlNRuERi32Dhymgg5'))}';
      
      final response = await http.post(
        Uri.parse('https://api.razorpay.com/v1/orders'),
        headers: {
          'Authorization': basicAuth,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'amount': amount * 100, // paise
          'currency': 'INR',
          'receipt': 'booking_$bookingId',
          'notes': {
            'booking_id': bookingId,
            'doctor_id': doctorId,
          },
        }),
      );

      if (response.statusCode == 200) {
        final orderData = jsonDecode(response.body);
        final realOrderId = orderData['id'];

        // Store the Razorpay order ID in the booking
        await _supabase.from('bookings').update({
          'razorpay_order_id': realOrderId,
        }).eq('id', bookingId);

        // Step 3: Open payment checkout
        _paymentService.openCheckout(orderId: realOrderId, amount: amount);
      } else {
        debugPrint('Razorpay API Error: ${response.statusCode} - ${response.body}');
        state = state.copyWith(
          isProcessingPayment: false,
          errorMessage: 'Failed to create payment order.',
        );
      }
    } catch (e) {
      debugPrint('Booking error: $e');
      state = state.copyWith(
        isProcessingPayment: false,
        errorMessage: 'Booking failed: ${e.toString().substring(0, 80)}',
      );
    }
  }

  /// Called when payment succeeds (from Razorpay callback)
  Future<void> _onPaymentSuccess(dynamic response) async {
    state = state.copyWith(isProcessingPayment: false, isPaymentSuccess: true, isGeneratingHandoff: true);
    
    final bookingId = state.bookingId;
    final jitsiRoom = state.jitsiRoomId;
    
    if (bookingId != null) {
      try {
        // Determine payment ID from response
        String paymentId = 'unknown';
        if (response is Map) {
          paymentId = response['paymentId']?.toString() ?? response['razorpay_payment_id']?.toString() ?? 'sim_${DateTime.now().millisecondsSinceEpoch}';
        }

        // Confirm the booking in the database
        await _supabase.from('bookings').update({
          'status': 'confirmed',
          'payment_status': 'paid',
          'razorpay_payment_id': paymentId,
          'jitsi_room_id': jitsiRoom,
          'meeting_url': 'https://meet.jit.si/$jitsiRoom',
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', bookingId);

        debugPrint('Booking $bookingId confirmed with Jitsi room: $jitsiRoom');
      } catch (e) {
        debugPrint('Failed to confirm booking: $e');
      }
    }

    // Simulate AI handoff generation delay
    await Future.delayed(const Duration(seconds: 2));
    state = state.copyWith(isGeneratingHandoff: false);
  }

  /// Reset state for a new booking
  void reset() {
    state = const BookingState();
  }
}

final bookingProvider = NotifierProvider<BookingNotifier, BookingState>(BookingNotifier.new);
