import 'package:equatable/equatable.dart';

sealed class LogoutEvents extends Equatable {
  const LogoutEvents();

  @override
  List<Object?> get props => [];
}

/// Triggers the logout request after the user confirms the action.
class LogoutEvent extends LogoutEvents {
  const LogoutEvent();
}
