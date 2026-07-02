import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/config/error_handler/error_handler.dart';
import 'package:flowery_rider_app/core/utils/app_constants.dart';
import 'package:flowery_rider_app/core/utils/app_end_points.dart';
import 'package:flowery_rider_app/features/notification/data/data_sources/notification_remote_data_source_contract.dart';
import 'package:flowery_rider_app/features/notification/data/models/order_firestore_model.dart';
import 'package:flowery_rider_app/features/notification/data/models/user_firestore_model.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: NotificationRemoteDataSourceContract)
class NotificationRemoteDataSourceImpl
    implements NotificationRemoteDataSourceContract {
  final FirebaseFirestore _firestore;
  final Dio _dio;

  NotificationRemoteDataSourceImpl(
    this._firestore,
    @Named('external') this._dio,
  );

  @override
  Future<UserFirestoreModel?> getUserData(String userId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();
      if (doc.exists && doc.data() != null) {
        return UserFirestoreModel.fromFirestore(doc.data()!);
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  @override
  Future<Map<String, dynamic>?> getFcmConfig() async {
    try {
      final doc = await _firestore
          .collection(AppConstants.appConfigsCollection)
          .doc(AppConstants.fcmDoc)
          .get();
      if (doc.exists && doc.data() != null) {
        return doc.data();
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  @override
  Future<BaseResponse<bool>> sendPushNotification({
    required String token,
    required String title,
    required String body,
    required String accessToken,
    required String projectId,
    String? orderId,
  }) async {
    return ErrorHandler.handleApiCall(() async {
      final response = await _dio.post(
        AppEndPoints.fcmSendUrl(projectId),
        options: Options(
          headers: {
            AppConstants.contentTypeHeader: AppConstants.applicationJson,
            AppConstants.authorizationHeader:
                '${AppConstants.bearer} $accessToken',
          },
        ),
        data: {
          AppConstants.messageField: {
            AppConstants.tokenField: token,
            AppConstants.notificationField: {
              AppConstants.titleField: title,
              AppConstants.bodyField: body,
            },
            AppConstants.dataField: {
              AppConstants.clickActionField: AppConstants.clickActionValue,
              AppConstants.typeField: AppConstants.orderUpdateValue,
              AppConstants.orderIdField: orderId ?? '',
            },
          },
        },
      );
      return response.statusCode == 200;
    });
  }

  @override
  Future<void> updateOrderInFirestore(OrderFirestoreModel model) async {
    try {
      await _firestore
          .collection(AppConstants.ordersCollection)
          .doc(model.orderId)
          .set(model.toJson(), SetOptions(merge: true));
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> saveNotificationToHistory({
    required String userId,
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({
            AppConstants.notificationsField: FieldValue.arrayUnion([
              {
                AppConstants.titleField: title,
                AppConstants.bodyField: body,
                AppConstants.sentTimeField: DateTime.now().toIso8601String(),
                AppConstants.dataField: data,
              },
            ]),
          });
    } catch (e) {
      if (kDebugMode) {
        print("Error saving notification to history: $e");
      }
    }
  }
}
