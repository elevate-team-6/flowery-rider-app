import 'package:flowery_rider_app/features/profile/presentation/view_model/change_password/change_password_cubit.dart';
import 'package:flowery_rider_app/features/profile/presentation/view_model/change_password/change_password_events.dart';
import 'package:flowery_rider_app/features/profile/presentation/view_model/change_password/change_password_states.dart';
import 'package:flowery_rider_app/features/profile/presentation/widgets/update_password_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'update_password_button_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ChangePasswordCubit>()])
void main() {
  late MockChangePasswordCubit cubit;
  late GlobalKey<FormState> formKey;

  setUp(() {
    cubit = MockChangePasswordCubit();

    formKey = GlobalKey<FormState>();

    when(cubit.state).thenReturn(const ChangePasswordState());

    when(cubit.stream).thenAnswer((_) => const Stream.empty());

    when(cubit.doIntent(any)).thenAnswer((_) async {});
  });

  Widget buildWidget({required bool isFormValid, required bool isLoading}) {
    return MaterialApp(
      home: BlocProvider<ChangePasswordCubit>.value(
        value: cubit,
        child: Scaffold(
          body: Form(
            key: formKey,
            child: UpdatePasswordButton(
              isFormValid: isFormValid,
              isLoading: isLoading,
              formKey: formKey,
              currentPassword: 'Ahmed@123',
              newPassword: 'GoOo136@',
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('button is disabled when form is invalid', (tester) async {
    await tester.pumpWidget(buildWidget(isFormValid: false, isLoading: false));

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));

    expect(button.onPressed, isNull);

    verifyNever(cubit.doIntent(any));
  });

  testWidgets('button is disabled while loading', (tester) async {
    await tester.pumpWidget(buildWidget(isFormValid: true, isLoading: true));

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));

    expect(button.onPressed, isNull);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    verifyNever(cubit.doIntent(any));
  });

  testWidgets('button is enabled when form is valid and not loading', (
    tester,
  ) async {
    await tester.pumpWidget(buildWidget(isFormValid: true, isLoading: false));

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));

    expect(button.onPressed, isNotNull);
  });

  testWidgets('tap button sends SubmitChangePasswordEvent', (tester) async {
    await tester.pumpWidget(buildWidget(isFormValid: true, isLoading: false));

    await tester.tap(find.byType(ElevatedButton));

    await tester.pump();

    verify(
      cubit.doIntent(
        argThat(
          isA<SubmitChangePasswordEvent>()
              .having((e) => e.currentPassword, 'currentPassword', 'Ahmed@123')
              .having((e) => e.newPassword, 'newPassword', 'GoOo136@'),
        ),
      ),
    ).called(1);
  });
}
