import 'package:flowery_rider_app/core/utils/app_constants.dart';

class UserFirestoreModel {
  final String fcmToken;
  final String language;

  UserFirestoreModel({required this.fcmToken, required this.language});

  factory UserFirestoreModel.fromFirestore(Map<String, dynamic> json) {
    return UserFirestoreModel(
      fcmToken: json[AppConstants.fcmTokenField] ?? '',
      language: json[AppConstants.languageField] ?? 'en',
    );
  }
}
