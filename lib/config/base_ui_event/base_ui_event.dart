sealed class BaseUiEvent {}

class ShowLoadingEvent extends BaseUiEvent {}

class HideLoadingEvent extends BaseUiEvent {}

class DisplayErrorEvent extends BaseUiEvent {
  final String errorMessage;
  DisplayErrorEvent(this.errorMessage);
}

class DisplaySuccessEvent extends BaseUiEvent {
  final String successMessage;
  DisplaySuccessEvent(this.successMessage);
}

class NavigateEvent extends BaseUiEvent {
  final String routeName;
  NavigateEvent(this.routeName);
}
