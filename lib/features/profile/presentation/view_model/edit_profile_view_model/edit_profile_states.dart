import 'package:equatable/equatable.dart';
import 'package:flowery_rider_app/core/entities/driver_entity.dart';

import '../../../../../config/base_state/base_state.dart';

class EditProfileStates extends Equatable {
  final DriverEntity? driver;
  final String gender;
  final bool isFormChanged;
  final BaseState<DriverEntity> editState;
  final BaseState<DriverEntity> uploadState;

  const EditProfileStates({
    this.driver,
    this.gender = '',
    this.isFormChanged = false,
    this.editState = const BaseState(),
    this.uploadState = const BaseState(),
  });

  EditProfileStates copyWith({
    DriverEntity? driver,
    String? gender,
    bool? isFormChanged,
    BaseState<DriverEntity>? editState,
    BaseState<DriverEntity>? uploadState,
  }) {
    return EditProfileStates(
      driver: driver ?? this.driver,
      gender: gender ?? this.gender,
      isFormChanged: isFormChanged ?? this.isFormChanged,
      editState: editState ?? this.editState,
      uploadState: uploadState ?? this.uploadState,
    );
  }

  @override
  List<Object?> get props => [
    driver,
    gender,
    isFormChanged,
    editState,
    uploadState,
  ];
}
