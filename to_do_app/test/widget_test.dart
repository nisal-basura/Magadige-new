// Basic smoke test — verifies the app boots to the welcome screen without
// throwing, without depending on a live SharedPreferences platform channel.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:to_do_app/app.dart';
import 'package:to_do_app/core/theme/theme_cubit.dart';

void main() {
  testWidgets('App boots to the welcome screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      BlocProvider(
        create: (_) => ThemeCubit(prefs),
        child: const MagadigeApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Get started free'), findsOneWidget);
  });
}
