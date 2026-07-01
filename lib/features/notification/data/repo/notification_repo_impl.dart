import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/config/cache/secure_cache_helper.dart';
import 'package:flowery_rider_app/core/utils/app_constants.dart';
import 'package:flowery_rider_app/core/utils/app_keys.dart';
import 'package:flowery_rider_app/features/notification/core/notification_strings.dart';
import 'package:flowery_rider_app/features/notification/data/data_sources/notification_remote_data_source_contract.dart';
import 'package:flowery_rider_app/features/notification/domain/entities/user_notification_state.dart';
import 'package:flowery_rider_app/features/notification/domain/repo/notification_repo_contract.dart';
import 'package:flutter/foundation.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:injectable/injectable.dart';

import '../models/order_firestore_model.dart';

@Injectable(as: NotificationRepoContract)
class NotificationRepoImpl implements NotificationRepoContract {
  final NotificationRemoteDataSourceContract _remoteDataSource;
  final SecureCacheHelper _secureCacheHelper;
  final FirebaseCrashlytics _crashlytics;

  NotificationRepoImpl(
    this._remoteDataSource,
    this._secureCacheHelper,
    this._crashlytics,
  );

  @override
  Future<BaseResponse<void>> updateOrderProgress({
    required String userId,
    required String orderId,
    required UserNotificationState state,
  }) async {
    try {
      // 1. Sync to Firestore (Rider Side)
      await _syncToFirestore(orderId, state);

      // 2. Fetch FCM Config from Firestore
      final fcmConfig = await _remoteDataSource.getFcmConfig();
      if (fcmConfig == null) {
        _logError('FCM Config not found in Firestore', userId, orderId);
        return SuccessBaseResponse(null);
      }

      // Debug: Print keys to console to verify matching with AppConstants
      if (kDebugMode) {
        print('FCM Config Keys: ${fcmConfig.keys.toList()}');
      }

      // 3. Generate Access Token
      final String? accessToken = await _generateAccessToken(fcmConfig);
      final String? projectId = fcmConfig[AppConstants.projectIdField];

      if (accessToken == null || projectId == null) {
        _logError(
          'Failed to generate FCM Access Token or ProjectId missing',
          userId,
          orderId,
        );
        return SuccessBaseResponse(null);
      }

      // 4. Fetch User Data
      final userData = await _remoteDataSource.getUserData(userId);
      if (userData == null || userData.fcmToken.isEmpty) {
        _logError('User FCM token not found', userId, orderId);
        return SuccessBaseResponse(null);
      }

      // 5. Send Notification
      final lang = userData.language == 'ar' ? 'ar' : 'en';
      final notificationResult = await _remoteDataSource.sendPushNotification(
        token: userData.fcmToken,
        title: NotificationStrings.titles[state]?[lang] ?? '',
        body: NotificationStrings.bodies[state]?[lang] ?? '',
        accessToken: accessToken,
        projectId: projectId,
        orderId: orderId,
      );

      switch (notificationResult) {
        case SuccessBaseResponse<bool>():
          await _remoteDataSource.saveNotificationToHistory(
            userId: userId,
            title: NotificationStrings.titles[state]?[lang] ?? '',
            body: NotificationStrings.bodies[state]?[lang] ?? '',
            data: {
              'type': 'order_update',
              'orderId': orderId,
              'state': state.name,
            },
          );
          return SuccessBaseResponse(null);
        case ErrorBaseResponse<bool>():
          _logError(
            'FCM Send failed: ${notificationResult.errorMessage}',
            userId,
            orderId,
          );
          return SuccessBaseResponse(null);
      }
    } catch (e, s) {
      _crashlytics.recordError(e, s, reason: 'Sync/Notify failed for $orderId');
      return SuccessBaseResponse(null);
    }
  }

  Future<String?> _generateAccessToken(Map<String, dynamic> config) async {
    try {
      final privateKey = config[AppConstants.privateKeyField] as String?;
      final clientEmail = config[AppConstants.clientEmailField] as String?;
      final projectId = config[AppConstants.projectIdField] as String?;

      if (privateKey == null || clientEmail == null || projectId == null) {
        return null;
      }

      // Ensure correct format for the private key
      String formattedPrivateKey = privateKey.replaceAll('\\n', '\n');
      if (!formattedPrivateKey.contains('-----BEGIN PRIVATE KEY-----')) {
        formattedPrivateKey =
            '-----BEGIN PRIVATE KEY-----\n$formattedPrivateKey\n-----END PRIVATE KEY-----';
      }

      final accountCredentials = ServiceAccountCredentials.fromJson({
        "private_key": formattedPrivateKey,
        "client_email": clientEmail,
        "project_id": projectId,
        "type": "service_account",
        "client_id":
            "118258260233682735322", // Mandatory placeholder for validation
      });

      final scopes = [AppConstants.fcmScope];

      final client = await clientViaServiceAccount(accountCredentials, scopes);
      final accessToken = client.credentials.accessToken.data;
      client.close();

      return accessToken;
    } catch (e, s) {
      _crashlytics.recordError(e, s, reason: 'AccessToken generation failed');
      return null;
    }
  }

  Future<void> _syncToFirestore(
    String orderId,
    UserNotificationState state,
  ) async {
    final riderId =
        await _secureCacheHelper.readData(key: AppKeys.userIdKey) ?? '';
    final riderName =
        await _secureCacheHelper.readData(key: AppKeys.riderNameKey) ?? 'Rider';
    final riderPhone =
        await _secureCacheHelper.readData(key: AppKeys.riderPhoneKey) ?? '';

    // Fallback logic to avoid sync failure while logging the issue
    final effectiveRiderId = riderId.isEmpty ? 'TEMP_RIDER_ID' : riderId;
    final effectiveRiderName = riderName == 'Rider'
        ? 'Flowery Rider'
        : riderName;

    await _remoteDataSource.updateOrderInFirestore(
      OrderFirestoreModel(
        orderId: orderId,
        status: state.name,
        riderId: effectiveRiderId,
        riderName: effectiveRiderName,
        riderPhone: riderPhone,
      ),
    );
  }

  void _logError(String reason, String userId, String orderId) {
    _crashlytics.recordError(
      Exception(reason),
      StackTrace.current,
      reason: 'Notification failed for $userId on $orderId',
      fatal: false,
    );
  }
}
