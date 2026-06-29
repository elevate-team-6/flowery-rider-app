import 'package:equatable/equatable.dart';

import '../../../../../core/utils/phone_formatter.dart';
import '../../../domain/entities/driver_entity.dart';

/// Immutable snapshot of the edit-profile form.
///
/// Holds the editable field values together with the driver they were seeded
/// from, and knows how to tell whether the form has diverged from that
/// baseline. Keeping this out of the cubit means the cubit only depends on use
/// cases and never carries mutable bookkeeping fields.
class EditProfileForm extends Equatable {
  final DriverEntity initialDriver;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final bool photoChanged;

  const EditProfileForm({
    required this.initialDriver,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.photoChanged = false,
  });

  /// Seeds the form from the driver currently being edited.
  factory EditProfileForm.fromDriver(DriverEntity driver) => EditProfileForm(
    initialDriver: driver,
    firstName: driver.firstName ?? '',
    lastName: driver.lastName ?? '',
    email: driver.email ?? '',
    phone: PhoneFormatter.toLocal(driver.phone),
  );

  /// Whether any field (or the photo) differs from the initial driver.
  bool get hasChanges =>
      photoChanged ||
      firstName.trim() != initialDriver.firstName ||
      lastName.trim() != initialDriver.lastName ||
      email.trim() != initialDriver.email ||
      phone.trim() != PhoneFormatter.toLocal(initialDriver.phone);

  EditProfileForm copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    bool? photoChanged,
  }) {
    return EditProfileForm(
      initialDriver: initialDriver,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoChanged: photoChanged ?? this.photoChanged,
    );
  }

  @override
  List<Object?> get props => [
    initialDriver,
    firstName,
    lastName,
    email,
    phone,
    photoChanged,
  ];
}
