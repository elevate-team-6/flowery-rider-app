sealed class ForgetPasswordEvents {}

class ForgetPasswordEvent extends ForgetPasswordEvents {
  final String email;

  ForgetPasswordEvent({required this.email});
}

class VerifyResetCodeEvent extends ForgetPasswordEvents {
  final String resetCode;
  final String email;

  VerifyResetCodeEvent({required this.resetCode, required this.email});
}

class ResetPasswordEvent extends ForgetPasswordEvents {
  final String email;
  final String newPassword;

  ResetPasswordEvent({required this.email, required this.newPassword});
}
