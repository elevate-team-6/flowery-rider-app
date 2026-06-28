import 'dart:io';
import '../../../data/models/request/edit_profile_request.dart';
import '../../../domain/entities/driver_entity.dart';

sealed class EditProfileEvents {
  const EditProfileEvents();
}

class InitEditProfileEvent extends EditProfileEvents {
  final DriverEntity driver;
  const InitEditProfileEvent(this.driver);
}

class EditProfileFormChangedEvent extends EditProfileEvents {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;

  const EditProfileFormChangedEvent({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
  });
}

class PickAndUploadPhotoEvent extends EditProfileEvents {
  final File photo;
  const PickAndUploadPhotoEvent(this.photo);
}

class SubmitEditProfileEvent extends EditProfileEvents {
  final EditProfileRequest request;
  const SubmitEditProfileEvent(this.request);
}
