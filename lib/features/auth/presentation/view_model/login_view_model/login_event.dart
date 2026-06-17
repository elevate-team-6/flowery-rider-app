import 'package:equatable/equatable.dart';
import 'package:flowery_rider_app/features/auth/data/models/request/sign_in_request_model.dart';

sealed class LoginEvents extends Equatable {
  const LoginEvents();

  @override
  List<Object?> get props => [];
}

/// Restores the remembered email + checkbox state when the screen opens.
class LoadRememberedEmailEvent extends LoginEvents {
  const LoadRememberedEmailEvent();
}

class TogglePasswordVisibilityEvent extends LoginEvents {
  const TogglePasswordVisibilityEvent();
}

class ToggleRememberMeEvent extends LoginEvents {
  final bool value;

  const ToggleRememberMeEvent(this.value);

  @override
  List<Object?> get props => [value];
}

class LoginEvent extends LoginEvents {
  final SignInRequestModel request;

  const LoginEvent(this.request);

  @override
  List<Object?> get props => [request];
}
