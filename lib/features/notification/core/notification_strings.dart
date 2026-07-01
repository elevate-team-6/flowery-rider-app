import '../domain/entities/user_notification_state.dart';

class NotificationStrings {
  static const Map<UserNotificationState, Map<String, String>> titles = {
    UserNotificationState.accepted: {
      'ar': 'تم قبول طلبك',
      'en': 'Order Accepted',
    },
    UserNotificationState.preparing: {
      'ar': 'جاري التجهيز',
      'en': 'Preparing Order',
    },
    UserNotificationState.onWay: {
      'ar': 'طلبك في الطريق',
      'en': 'Out for Delivery',
    },
    UserNotificationState.delivered: {
      'ar': 'تم التوصيل',
      'en': 'Order Delivered',
    },
    UserNotificationState.canceled: {
      'ar': 'تحديث بخصوص طلبك',
      'en': 'Order Update',
    },
  };

  static const Map<UserNotificationState, Map<String, String>> bodies = {
    UserNotificationState.accepted: {
      'ar': 'تم قبول طلبك بواسطة مندوبنا وجاري التحرك.',
      'en': 'Your order has been accepted and the rider is moving.',
    },
    UserNotificationState.preparing: {
      'ar': 'المندوب وصل للمتجر ويقوم باستلام طلبك.',
      'en': 'The rider reached the store and is picking up your order.',
    },
    UserNotificationState.onWay: {
      'ar': 'المندوب استلم الطلب وهو في طريقه إليك.',
      'en': 'The rider picked up your order and is on the way.',
    },
    UserNotificationState.delivered: {
      'ar': 'تم توصيل طلبك بنجاح. نتمنى لك يوماً سعيداً!',
      'en': 'Your order has been delivered successfully!',
    },
    UserNotificationState.canceled: {
      'ar': 'حدثت مشكلة في التوصيل وسيتم إسناد طلبك لمندوب آخر فوراً.',
      'en':
          'There was an issue with delivery; a new rider will be assigned shortly.',
    },
  };
}
