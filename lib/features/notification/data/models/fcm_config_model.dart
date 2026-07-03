import 'package:flowery_rider_app/core/utils/app_constants.dart';

class FcmConfigModel {
  final String privateKey;
  final String clientEmail;
  final String projectId;
  final String? clientId;

  FcmConfigModel({
    required this.privateKey,
    required this.clientEmail,
    required this.projectId,
    this.clientId,
  });

  factory FcmConfigModel.fromFirestore(Map<String, dynamic> json) {
    return FcmConfigModel(
      privateKey: json[AppConstants.privateKeyField] ?? '',
      clientEmail: json[AppConstants.clientEmailField] ?? '',
      projectId: json[AppConstants.projectIdField] ?? '',
      clientId: json[AppConstants.clientIdField],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      AppConstants.privateKeyField: privateKey,
      AppConstants.clientEmailField: clientEmail,
      AppConstants.projectIdField: projectId,
      if (clientId != null) AppConstants.clientIdField: clientId,
    };
  }
}
