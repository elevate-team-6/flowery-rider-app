import 'package:flowery_rider_app/config/base_ui_event/base_ui_event.dart';
import 'package:flowery_rider_app/features/profile/presentation/view_model/change_password/change_password_cubit.dart';
import 'package:flowery_rider_app/features/profile/presentation/view_model/change_password/change_password_events.dart';
import 'package:flowery_rider_app/features/profile/presentation/view_model/change_password/change_password_states.dart';
import 'package:flowery_rider_app/features/profile/presentation/widgets/change_password_form.dart';
import 'package:flowery_rider_app/features/profile/presentation/widgets/password_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeChangePasswordCubit extends Cubit<ChangePasswordState>
    implements ChangePasswordCubit {
  FakeChangePasswordCubit() : super(const ChangePasswordState());

  @override
  Future<void> doIntent(ChangePasswordEvent event) async {}

  @override
  void emitUiEvent(BaseUiEvent event) {}

  @override
  Stream<BaseUiEvent> get eventStream => const Stream<BaseUiEvent>.empty();
}

void main() {
  late FakeChangePasswordCubit cubit;

  late GlobalKey<FormState> formKey;
  late TextEditingController currentController;
  late TextEditingController newController;
  late TextEditingController confirmController;

  setUp(() {
    cubit = FakeChangePasswordCubit();

    formKey = GlobalKey<FormState>();

    currentController = TextEditingController();
    newController = TextEditingController();
    confirmController = TextEditingController();
  });

  tearDown(() async {
    currentController.dispose();
    newController.dispose();
    confirmController.dispose();
    await cubit.close();
  });

  Widget buildWidget() {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      child: MaterialApp(
        home: BlocProvider<ChangePasswordCubit>.value(
          value: cubit,
          child: Scaffold(
            body: ChangePasswordForm(
              formKey: formKey,
              currentPasswordController: currentController,
              newPasswordController: newController,
              confirmPasswordController: confirmController,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('renders change password form', (tester) async {
    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    expect(find.byType(ChangePasswordForm), findsOneWidget);
  });

  testWidgets('renders three password fields', (tester) async {
    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    expect(find.byType(PasswordField), findsNWidgets(3));
  });

  testWidgets('updates controllers when text entered', (tester) async {
    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);

    await tester.enterText(fields.at(0), 'Ahmed@123');

    await tester.enterText(fields.at(1), 'GoOo136@');

    await tester.enterText(fields.at(2), 'GoOo136@');

    expect(currentController.text, 'Ahmed@123');

    expect(newController.text, 'GoOo136@');

    expect(confirmController.text, 'GoOo136@');
  });

  testWidgets('form validates successfully when passwords match', (
    tester,
  ) async {
    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);

    await tester.enterText(fields.at(0), 'Ahmed@123');

    await tester.enterText(fields.at(1), 'GoOo136@');

    await tester.enterText(fields.at(2), 'GoOo136@');

    await tester.pump();

    expect(formKey.currentState?.validate(), true);
  });

  testWidgets('form validation fails when passwords do not match', (
    tester,
  ) async {
    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);

    await tester.enterText(fields.at(0), 'Ahmed@123');

    await tester.enterText(fields.at(1), 'GoOo136@');

    await tester.enterText(fields.at(2), 'WrongPassword@');

    await tester.pump();

    expect(formKey.currentState?.validate(), false);
  });
}
