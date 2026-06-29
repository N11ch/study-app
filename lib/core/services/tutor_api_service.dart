import 'dart:convert';

import '../network/api_client.dart';
import 'auth_state.dart';

// ─── Result types ─────────────────────────────────────────────────────────────

class TutorOfferListResult {
  final bool success;
  final List<Map<String, dynamic>>? offers;
  final String? errorMessage;

  const TutorOfferListResult._({required this.success, this.offers, this.errorMessage});

  factory TutorOfferListResult.success(List<Map<String, dynamic>> offers) =>
      TutorOfferListResult._(success: true, offers: offers);

  factory TutorOfferListResult.error(String message) =>
      TutorOfferListResult._(success: false, errorMessage: message);
}

class TutorOfferResult {
  final bool success;
  final Map<String, dynamic>? offer;
  final String? errorMessage;

  const TutorOfferResult._({required this.success, this.offer, this.errorMessage});

  factory TutorOfferResult.success(Map<String, dynamic> offer) =>
      TutorOfferResult._(success: true, offer: offer);

  factory TutorOfferResult.error(String message) =>
      TutorOfferResult._(success: false, errorMessage: message);
}

class TutorAvailabilityResult {
  final bool success;
  final Map<String, dynamic>? slot;
  final String? errorMessage;

  const TutorAvailabilityResult._({required this.success, this.slot, this.errorMessage});

  factory TutorAvailabilityResult.success(Map<String, dynamic> slot) =>
      TutorAvailabilityResult._(success: true, slot: slot);

  factory TutorAvailabilityResult.error(String message) =>
      TutorAvailabilityResult._(success: false, errorMessage: message);
}

class TutorSimpleResult {
  final bool success;
  final String? message;

  const TutorSimpleResult({required this.success, this.message});

  factory TutorSimpleResult.ok([String? message]) =>
      TutorSimpleResult(success: true, message: message);

  factory TutorSimpleResult.fail(String message) =>
      TutorSimpleResult(success: false, message: message);
}

class WithdrawalResult {
  final bool success;
  final Map<String, dynamic>? withdrawal;
  final String? errorMessage;

  const WithdrawalResult._({required this.success, this.withdrawal, this.errorMessage});

  factory WithdrawalResult.success(Map<String, dynamic> data) =>
      WithdrawalResult._(success: true, withdrawal: data);

  factory WithdrawalResult.error(String message) =>
      WithdrawalResult._(success: false, errorMessage: message);
}

class WithdrawalHistoryResult {
  final bool success;
  final List<Map<String, dynamic>>? withdrawals;
  final String? errorMessage;

  const WithdrawalHistoryResult._({required this.success, this.withdrawals, this.errorMessage});

  factory WithdrawalHistoryResult.success(List<Map<String, dynamic>> data) =>
      WithdrawalHistoryResult._(success: true, withdrawals: data);

  factory WithdrawalHistoryResult.error(String message) =>
      WithdrawalHistoryResult._(success: false, errorMessage: message);
}

class VerificationResult {
  final bool success;
  final String? errorMessage;

  const VerificationResult._({required this.success, this.errorMessage});

  factory VerificationResult.success() => const VerificationResult._(success: true);

  factory VerificationResult.error(String message) =>
      VerificationResult._(success: false, errorMessage: message);
}

// ─── TutorApiService — singleton ──────────────────────────────────────────────

class TutorApiService {
  TutorApiService._();
  static final TutorApiService instance = TutorApiService._();

  // ── GET /user/tutor/offer/mine ─────────────────────────────────────────────

  Future<TutorOfferListResult> getMyOffers() async {
    if (!AuthState.instance.isLoggedIn) {
      return TutorOfferListResult.error('Not authenticated.');
    }
    try {
      final response = await ApiClient.instance.get(
        '/user/tutor/offer/mine',
        requiresAuth: true,
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final list = (data as List?)?.cast<Map<String, dynamic>>() ?? [];
        return TutorOfferListResult.success(list);
      }
      return TutorOfferListResult.error(_msg(data, response.statusCode, 'Failed to load offers.'));
    } on StateError catch (e) {
      return TutorOfferListResult.error(e.message);
    } catch (e) {
      return TutorOfferListResult.error(ApiClient.instance.friendlyError(e));
    }
  }

  // ── POST /user/tutor/offer ─────────────────────────────────────────────────

  Future<TutorOfferResult> createOffer({
    required String title,
    String? summary,
    String? about,
    required int coinsPerHour,
    int? durationMinutes,
    List<String>? subjectIds,
    String? thumbnailUrl,
  }) async {
    if (!AuthState.instance.isLoggedIn) {
      return TutorOfferResult.error('Not authenticated.');
    }
    final body = <String, dynamic>{
      'title': title,
      'coins_per_session': coinsPerHour,
      if (summary != null) 'summary': summary,
      if (about != null) 'about': about,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
      if (subjectIds != null && subjectIds.isNotEmpty) 'subject_ids': subjectIds,
      if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
    };
    try {
      final response = await ApiClient.instance.post(
        '/user/tutor/offer',
        body,
        requiresAuth: true,
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final offer = data['offer'] as Map<String, dynamic>? ?? data as Map<String, dynamic>;
        return TutorOfferResult.success(offer);
      }
      return TutorOfferResult.error(_msg(data, response.statusCode, 'Failed to create offer.'));
    } on StateError catch (e) {
      return TutorOfferResult.error(e.message);
    } catch (e) {
      return TutorOfferResult.error(ApiClient.instance.friendlyError(e));
    }
  }

  // ── PATCH /user/tutor/offer/:id ────────────────────────────────────────────

  Future<TutorOfferResult> updateOffer(
    String offerId, {
    String? title,
    String? summary,
    String? about,
    int? coinsPerHour,
    int? durationMinutes,
    List<String>? subjectIds,
    String? thumbnailUrl,
  }) async {
    if (!AuthState.instance.isLoggedIn) {
      return TutorOfferResult.error('Not authenticated.');
    }
    final body = <String, dynamic>{
      if (title != null) 'title': title,
      if (summary != null) 'summary': summary,
      if (about != null) 'about': about,
      if (coinsPerHour != null) 'coins_per_session': coinsPerHour,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
      if (subjectIds != null) 'subject_ids': subjectIds,
      if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
    };
    try {
      final response = await ApiClient.instance.patch(
        '/user/tutor/offer/$offerId',
        body,
        requiresAuth: true,
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final offer = data['offer'] as Map<String, dynamic>? ?? data as Map<String, dynamic>;
        return TutorOfferResult.success(offer);
      }
      return TutorOfferResult.error(_msg(data, response.statusCode, 'Failed to update offer.'));
    } on StateError catch (e) {
      return TutorOfferResult.error(e.message);
    } catch (e) {
      return TutorOfferResult.error(ApiClient.instance.friendlyError(e));
    }
  }

  // ── DELETE /user/tutor/offer/:id ───────────────────────────────────────────

  Future<TutorSimpleResult> deleteOffer(String offerId) async {
    if (!AuthState.instance.isLoggedIn) {
      return TutorSimpleResult.fail('Not authenticated.');
    }
    try {
      final response = await ApiClient.instance.delete(
        '/user/tutor/offer/$offerId',
        requiresAuth: true,
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        return TutorSimpleResult.ok('Offer deleted.');
      }
      final data = jsonDecode(response.body);
      return TutorSimpleResult.fail(_msg(data, response.statusCode, 'Failed to delete offer.'));
    } on StateError catch (e) {
      return TutorSimpleResult.fail(e.message);
    } catch (e) {
      return TutorSimpleResult.fail(ApiClient.instance.friendlyError(e));
    }
  }

  // ── POST /user/tutor/availability ──────────────────────────────────────────

  Future<TutorAvailabilityResult> createAvailabilitySlot({
    required String availableFrom,
    required String availableTo,
    String? timezone,
  }) async {
    if (!AuthState.instance.isLoggedIn) {
      return TutorAvailabilityResult.error('Not authenticated.');
    }
    final body = <String, dynamic>{
      'available_from': availableFrom,
      'available_to': availableTo,
      if (timezone != null) 'timezone': timezone,
    };
    try {
      final response = await ApiClient.instance.post(
        '/user/tutor/availability',
        body,
        requiresAuth: true,
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final slot = data['slot'] as Map<String, dynamic>? ?? data as Map<String, dynamic>;
        return TutorAvailabilityResult.success(slot);
      }
      return TutorAvailabilityResult.error(
          _msg(data, response.statusCode, 'Failed to create availability slot.'));
    } on StateError catch (e) {
      return TutorAvailabilityResult.error(e.message);
    } catch (e) {
      return TutorAvailabilityResult.error(ApiClient.instance.friendlyError(e));
    }
  }

  // ── DELETE /user/tutor/availability/:id ────────────────────────────────────

  Future<TutorSimpleResult> deleteAvailabilitySlot(String slotId) async {
    if (!AuthState.instance.isLoggedIn) {
      return TutorSimpleResult.fail('Not authenticated.');
    }
    try {
      final response = await ApiClient.instance.delete(
        '/user/tutor/availability/$slotId',
        requiresAuth: true,
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        return TutorSimpleResult.ok('Slot deleted.');
      }
      final data = jsonDecode(response.body);
      return TutorSimpleResult.fail(_msg(data, response.statusCode, 'Failed to delete slot.'));
    } on StateError catch (e) {
      return TutorSimpleResult.fail(e.message);
    } catch (e) {
      return TutorSimpleResult.fail(ApiClient.instance.friendlyError(e));
    }
  }

  // ── POST /user/tutor/verification ─────────────────────────────────────────

  Future<VerificationResult> submitVerification({
    String? phone,
    String? address,
    String? idDocumentUrl,
    List<String>? certificateUrls,
  }) async {
    if (!AuthState.instance.isLoggedIn) {
      return VerificationResult.error('Not authenticated.');
    }
    final body = <String, dynamic>{
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      if (idDocumentUrl != null) 'id_document_url': idDocumentUrl,
      if (certificateUrls != null && certificateUrls.isNotEmpty)
        'certificate_urls': certificateUrls,
    };
    try {
      final response = await ApiClient.instance.post(
        '/user/tutor/verification',
        body,
        requiresAuth: true,
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return VerificationResult.success();
      }
      return VerificationResult.error(
          _msg(data, response.statusCode, 'Failed to submit verification.'));
    } on StateError catch (e) {
      return VerificationResult.error(e.message);
    } catch (e) {
      return VerificationResult.error(ApiClient.instance.friendlyError(e));
    }
  }

  // ── POST /coins/withdraw ───────────────────────────────────────────────────

  Future<WithdrawalResult> requestWithdrawal({
    required int coinsAmount,
    required String accountName,
    required String accountNumber,
    String? paymentMethod,
    String? bankName,
  }) async {
    if (!AuthState.instance.isLoggedIn) {
      return WithdrawalResult.error('Not authenticated.');
    }
    final body = <String, dynamic>{
      'coins_amount': coinsAmount,
      'account_name': accountName,
      'account_number': accountNumber,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (bankName != null) 'bank_name': bankName,
    };
    try {
      final response = await ApiClient.instance.post(
        '/coins/withdraw',
        body,
        requiresAuth: true,
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return WithdrawalResult.success(data as Map<String, dynamic>);
      }
      return WithdrawalResult.error(
          _msg(data, response.statusCode, 'Failed to request withdrawal.'));
    } on StateError catch (e) {
      return WithdrawalResult.error(e.message);
    } catch (e) {
      return WithdrawalResult.error(ApiClient.instance.friendlyError(e));
    }
  }

  // ── GET /coins/withdrawals ─────────────────────────────────────────────────

  Future<WithdrawalHistoryResult> getWithdrawalHistory() async {
    if (!AuthState.instance.isLoggedIn) {
      return WithdrawalHistoryResult.error('Not authenticated.');
    }
    try {
      final response = await ApiClient.instance.get(
        '/coins/withdrawals',
        requiresAuth: true,
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final list = (data as List?)?.cast<Map<String, dynamic>>() ?? [];
        return WithdrawalHistoryResult.success(list);
      }
      return WithdrawalHistoryResult.error(
          _msg(data, response.statusCode, 'Failed to load withdrawal history.'));
    } on StateError catch (e) {
      return WithdrawalHistoryResult.error(e.message);
    } catch (e) {
      return WithdrawalHistoryResult.error(ApiClient.instance.friendlyError(e));
    }
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  String _msg(dynamic data, int statusCode, String fallback) {
    if (data is Map) {
      final raw = data['message'];
      if (raw is List) return raw.first.toString();
      if (raw is String) return raw;
    }
    return '$fallback (HTTP $statusCode)';
  }
}
