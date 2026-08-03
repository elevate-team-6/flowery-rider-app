abstract class AppConstants {
  static const String translationsPath = 'assets/translations';
  static const String arabicCode = 'ar';
  static const String englishCode = 'en';

  // api images base url
  static const String imageBaseUrl = 'https://flower.elevateegy.com/uploads/';

  // Firestore Collections
  static const String usersCollection = "users";
  static const String ordersCollection = "orders";
  static const String appConfigsCollection = "app_configs";

  // Firestore Fields
  static const String fcmTokenField = "fcmToken";
  static const String languageField = "language";
  static const String statusField = "status";
  static const String riderIdField = "riderId";
  static const String riderNameField = "riderName";
  static const String riderPhoneField = "riderPhone";
  static const String shippingAddressField = "shippingAddress";
  static const String riderLocationField = "riderLocation";
  static const String updatedAtField = "updatedAt";
  static const String streetField = "street";
  static const String cityField = "city";
  static const String phoneField = "phone";
  static const String latField = "lat";
  static const String longField = "long";

  // Firestore Documents
  static const String fcmDoc = "fcm";
  static const String privateKeyField = "privateKey";
  static const String clientEmailField = "clientEmail";
  static const String projectIdField = "projectId";
  static const String serverKeyField = "serverKey";
  static const String typeField = "type";
  static const String clientIdField = "client_id";
  static const String notificationsField = "notifications";
  static const String titleField = "title";
  static const String bodyField = "body";
  static const String sentTimeField = "sentTime";
  static const String dataField = "data";
  static const String clickActionField = "click_action";
  static const String orderIdField = "orderId";
  static const String messageField = "message";
  static const String tokenField = "token";
  static const String notificationField = "notification";
  static const String stateField = "state";

  // Firestore Values
  static const String serviceAccountValue = "service_account";
  static const String clickActionValue = "FLUTTER_NOTIFICATION_CLICK";
  static const String orderUpdateValue = "order_update";
  static const String defaultClientId = "118258260233682735322";

  // PEM Formatting
  static const String pemHeader = "-----BEGIN PRIVATE KEY-----";
  static const String pemFooter = "-----END PRIVATE KEY-----";
  static const String newline = "\n";
  static const String escapedNewline = "\\n";

  // Headers
  static const String contentTypeHeader = "Content-Type";
  static const String applicationJson = "application/json";
  static const String authorizationHeader = "Authorization";
  static const String bearer = "Bearer";

  // FCM Scopes
  static const String fcmScope =
      'https://www.googleapis.com/auth/firebase.messaging';
}
