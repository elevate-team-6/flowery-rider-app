abstract class BaseUiEvent {}

enum NavigationType { push, pushReplacement, pushAndRemoveUntil, pop }

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
  final NavigationType navigationType;
  final Object? arguments;
  final bool Function(dynamic)? predicate;

  NavigateEvent(
    this.routeName, {
    this.navigationType = NavigationType.push,
    this.arguments,
    this.predicate,
  });
}
