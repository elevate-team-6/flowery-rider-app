import '../../../domain/entities/order_entity.dart';
import '../../../domain/use_cases/open_communication_use_case.dart';
import '../order_details/order_details_events.dart' show LocationType;

sealed class MapEvents {
  const MapEvents();
}

class MapInitializeEvent extends MapEvents {
  final OrderEntity order;
  final LocationType locationType;
  final String targetLat;
  final String targetLong;

  const MapInitializeEvent({
    required this.order,
    required this.locationType,
    required this.targetLat,
    required this.targetLong,
  });
}

class MapRetryLocationEvent extends MapEvents {
  const MapRetryLocationEvent();
}

class MapRetryRouteEvent extends MapEvents {
  const MapRetryRouteEvent();
}

class MapContactEvent extends MapEvents {
  final String phone;
  final CommunicationType type;

  const MapContactEvent(this.phone, this.type);
}
