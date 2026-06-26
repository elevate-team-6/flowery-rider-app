sealed class ChangePasswordEvent {
  const ChangePasswordEvent();
}

class SubmitChangePasswordEvent extends ChangePasswordEvent {
  final String currentPassword;
  final String newPassword;

  const SubmitChangePasswordEvent({
    required this.currentPassword,
    required this.newPassword,
  });
}
