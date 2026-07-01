import 'package:flowery_rider_app/features/auth/domain/entities/vehicle_type_entity.dart';

sealed class EditVehicleEvent {
  const EditVehicleEvent();
}

class InitializeEditVehicleEvent extends EditVehicleEvent {
  final String vehicleTypeId;
  final String vehicleNumber;
  final String? vehicleLicenseUrl;

  const InitializeEditVehicleEvent({
    required this.vehicleTypeId,
    required this.vehicleNumber,
    this.vehicleLicenseUrl,
  });
}

class GetVehicleTypesEvent extends EditVehicleEvent {
  const GetVehicleTypesEvent();
}

class ChangeVehicleTypeEvent extends EditVehicleEvent {
  final VehicleTypeEntity vehicleType;

  const ChangeVehicleTypeEvent(this.vehicleType);
}

class ChangeVehicleNumberEvent extends EditVehicleEvent {
  const ChangeVehicleNumberEvent();
}

class PickDrivingLicenseImageEvent extends EditVehicleEvent {
  const PickDrivingLicenseImageEvent();
}

class RemoveDrivingLicenseImageEvent extends EditVehicleEvent {
  const RemoveDrivingLicenseImageEvent();
}

class EditVehicleSubmitEvent extends EditVehicleEvent {
  final String vehicleNumber;

  const EditVehicleSubmitEvent({required this.vehicleNumber});
}
