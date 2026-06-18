import 'dart:async';

import 'package:flowery_rider_app/config/base_ui_event/base_ui_event.dart';
import 'package:flowery_rider_app/core/utils/app_strings.dart';
import 'package:flowery_rider_app/features/auth/presentation/screens/forget_password_screen.dart';
import 'package:flowery_rider_app/features/auth/presentation/view_model/forget_password_view_model/forget_password_cubit.dart';
import 'package:flowery_rider_app/features/auth/presentation/view_model/forget_password_view_model/forget_password_events.dart';
import 'package:flowery_rider_app/features/auth/presentation/view_model/forget_password_view_model/forget_password_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'forget_password_screen_test.mocks.dart';

@GenerateMocks([ForgetPasswordCubit])
void main() {
  late MockForgetPasswordCubit mockCubit;
  late StreamController<BaseUiEvent> eventController;

  setUp(() {
    mockCubit = MockForgetPasswordCubit();
    eventController = StreamController<BaseUiEvent>.broadcast();

    // Stubbing mandatory streams and initial state
    when(mockCubit.state).thenReturn(const ForgetPasswordState());
    when(
      mockCubit.stream,
    ).thenAnswer((_) => const Stream<ForgetPasswordState>.empty());
    when(mockCubit.eventStream).thenAnswer((_) => eventController.stream);
    when(mockCubit.close()).thenAnswer((_) async => {});
  });

  tearDown(() {
    eventController.close();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<ForgetPasswordCubit>.value(
        value: mockCubit,
        child: const ForgotPasswordScreen(),
      ),
    );
  }

  group('ForgotPasswordScreen Widget Tests', () {
    testWidgets('renders all initial UI elements correctly', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text(AppStrings.password), findsOneWidget);
      expect(find.text(AppStrings.forgetPasswordTitle), findsOneWidget);
      expect(find.text(AppStrings.forgetPasswordSubtitle), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(
        find.widgetWithText(ElevatedButton, AppStrings.confirm),
        findsOneWidget,
      );
    });

    testWidgets(
      'shows validation error when email is empty and confirm is pressed',
      (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());

        await tester.tap(
          find.widgetWithText(ElevatedButton, AppStrings.confirm),
        );
        await tester.pumpAndSettle();

        expect(find.text(AppStrings.emailRequired), findsOneWidget);
      },
    );

    testWidgets('calls doEvent on cubit when valid email is submitted', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      const tEmail = 'test@example.com';
      await tester.enterText(find.byType(TextField), tEmail);
      await tester.tap(find.widgetWithText(ElevatedButton, AppStrings.confirm));
      await tester.pump();

      verify(mockCubit.doEvent(argThat(isA<ForgetPasswordEvent>()))).called(1);
    });
  });
}
