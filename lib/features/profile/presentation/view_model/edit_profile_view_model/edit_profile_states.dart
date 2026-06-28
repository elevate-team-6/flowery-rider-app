import 'package:equatable/equatable.dart';

import '../../../../../config/base_state/base_state.dart';
import '../../../domain/entities/driver_entity.dart';
import 'edit_profile_form.dart';

class EditProfileStates extends Equatable {
  final DriverEntity? driver;
  final String gender;
  final EditProfileForm? form;
  final BaseState<DriverEntity> editState;
  final BaseState<DriverEntity> uploadState;

  const EditProfileStates({
    this.driver,
    this.gender = '',
    this.form,
    this.editState = const BaseState(),
    this.uploadState = const BaseState(),
  });

  /// Derived from the form so the cubit never tracks this by hand.
  bool get isFormChanged => form?.hasChanges ?? false;

  EditProfileStates copyWith({
    DriverEntity? driver,
    String? gender,
    EditProfileForm? form,
    BaseState<DriverEntity>? editState,
    BaseState<DriverEntity>? uploadState,
  }) {
    return EditProfileStates(
      driver: driver ?? this.driver,
      gender: gender ?? this.gender,
      form: form ?? this.form,
      editState: editState ?? this.editState,
      uploadState: uploadState ?? this.uploadState,
    );
  }

  @override
  List<Object?> get props => [driver, gender, form, editState, uploadState];
}
