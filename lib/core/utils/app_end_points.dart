abstract class AppEndPoints {
  // Base URL:
  static const String baseUrl = "https://flower.elevateegy.com/api/v1";

  // API EndPoints:-

  // Driver Authentication:
  static const String apply = "$baseUrl/drivers/apply";
  static const String signin = "$baseUrl/drivers/signin";
  static const String forgetPassword = "$baseUrl/drivers/forgotPassword";
  static const String verifyResetCode = "$baseUrl/drivers/verifyResetCode";
  static const String resetPassword = "$baseUrl/drivers/resetPassword";
  static const String changePassword = '$baseUrl/drivers/change-password';
  static const String logout = "$baseUrl/drivers/logout";
  static const String vehcicls = "$baseUrl/vehicles";

  // Driver Profile:
  static const String profileData = "$baseUrl/drivers/profile-Data";
  static const String editProfile = "$baseUrl/drivers/editProfile";
  static const String uploadPhoto = "$baseUrl/drivers/upload-photo";

  // Tracking:
  static const String driverOrders = "$baseUrl/orders/driver-orders";
  static const String startOrder = '$baseUrl/orders/start/';
  static const String updateOrderState = '$baseUrl/orders/state/';

  // Orders:
  static const String pendingOrders = "$baseUrl/orders/pending-orders";

  // General:
  static const String addresses = "$baseUrl/addresses";

  // Web Views:
  static const String termsAndConditionsUrl =
      "https://elevate-flutter-team.github.io/flower_app_web_views/terms.html";
  static const String aboutUsUrl =
      "https://elevate-flutter-team.github.io/flower_app_web_views/about.html";

  // FCM Send Notification Endpoint:
  static String fcmSendUrl(String projectId) =>
      'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';

  // ---------------------------------------------------------------------------
  // TO ADD NEW ENDPOINTS:
  // 1. Group them by feature (e.g., // Products, // Cart).
  // 2. Use 'static const String' with camelCase naming.
  // 3. Always prefix the path with '$baseUrl'.
  // Example: static const String getProducts = "$baseUrl/products";
  // ---------------------------------------------------------------------------
}
