import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/config/cache/secure_cache_helper.dart';
import 'package:flowery_rider_app/core/models/rider_session_model.dart';
import 'package:flowery_rider_app/core/utils/app_constants.dart';
import 'package:flowery_rider_app/core/utils/app_keys.dart';
import 'package:flowery_rider_app/core/utils/app_strings.dart';
import 'package:flowery_rider_app/features/notification/core/notification_strings.dart';
import 'package:flowery_rider_app/features/notification/data/data_sources/notification_remote_data_source_contract.dart';
import 'package:flowery_rider_app/features/notification/data/models/fcm_config_model.dart';
import 'package:flowery_rider_app/features/notification/data/models/order_firestore_model.dart';
import 'package:flowery_rider_app/features/notification/domain/entities/user_notification_state.dart';
import 'package:flowery_rider_app/features/notification/domain/repo/notification_repo_contract.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:injectable/injectable.dart';

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

      // 3. Generate Access Token
      final String? accessToken = await _generateAccessToken(fcmConfig);
      final String projectId = fcmConfig.projectId;

      if (accessToken == null || projectId.isEmpty) {
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
      final lang = userData.language == AppConstants.arabicCode
          ? AppConstants.arabicCode
          : AppConstants.englishCode;
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
              AppConstants.typeField: AppConstants.orderUpdateValue,
              AppConstants.orderIdField: orderId,
              AppConstants.stateField: state.name,
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

  Future<String?> _generateAccessToken(FcmConfigModel config) async {
    try {
      final privateKey = config.privateKey;
      final clientEmail = config.clientEmail;
      final projectId = config.projectId;

      if (privateKey.isEmpty || clientEmail.isEmpty || projectId.isEmpty) {
        return null;
      }

      // Ensure correct format for the private key using constants
      String formattedPrivateKey = privateKey.replaceAll(
        AppConstants.escapedNewline,
        AppConstants.newline,
      );
      if (!formattedPrivateKey.contains(AppConstants.pemHeader)) {
        formattedPrivateKey =
            '${AppConstants.pemHeader}${AppConstants.newline}$formattedPrivateKey${AppConstants.newline}${AppConstants.pemFooter}';
      }

      final accountCredentials = ServiceAccountCredentials.fromJson({
        AppConstants.privateKeyField: formattedPrivateKey,
        AppConstants.clientEmailField: clientEmail,
        AppConstants.projectIdField: projectId,
        AppConstants.typeField: AppConstants.serviceAccountValue,
        AppConstants.clientIdField:
            config.clientId ?? AppConstants.defaultClientId,
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
    final session = await _getRiderSession();

    if (!session.hasValidIdentity) {
      _logError(
        'Critical: Missing Rider Identity during Firestore sync',
        'UNKNOWN',
        orderId,
      );
      return;
    }

    // Use localized default if rider name is missing in session
    final displayName = session.name.isEmpty
        ? AppStrings.floweryRider.tr()
        : session.name;

    await _remoteDataSource.updateOrderInFirestore(
      OrderFirestoreModel(
        orderId: orderId,
        status: state.name,
        riderId: session.id,
        riderName: displayName,
        riderPhone: session.phone,
      ),
    );
  }

  Future<RiderSessionModel> _getRiderSession() async {
    final id = await _secureCacheHelper.readData(key: AppKeys.userIdKey) ?? '';
    final name =
        await _secureCacheHelper.readData(key: AppKeys.riderNameKey) ?? '';
    final phone =
        await _secureCacheHelper.readData(key: AppKeys.riderPhoneKey) ?? '';

    return RiderSessionModel(id: id, name: name, phone: phone);
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
