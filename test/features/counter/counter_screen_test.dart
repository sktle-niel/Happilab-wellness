import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:happilab/app/app.dart';
import 'package:happilab/app/di/app_dependencies.dart';
import 'package:happilab/core/config/app_config.dart';

import '../../support/fake_http_transport.dart';

void main() {
  AppDependencies buildDependencies() => AppDependencies.withTransport(
    config: AppConfig(
      environment: AppEnvironment.dev,
      apiBaseUrl: Uri.parse('https://api.test.local'),
    ),
    transport: FakeHttpTransport(),
  );

  testWidgets('counter starts at zero and increments on tap', (tester) async {
    await tester.pumpWidget(HappilabApp(dependencies: buildDependencies()));

    expect(find.text('0'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('1'), findsOneWidget);
    expect(find.text('0'), findsNothing);
  });

  testWidgets('reset is disabled until the counter moves', (tester) async {
    await tester.pumpWidget(HappilabApp(dependencies: buildDependencies()));

    final resetButton = find.widgetWithText(OutlinedButton, 'Reset');
    expect(tester.widget<OutlinedButton>(resetButton).onPressed, isNull);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(tester.widget<OutlinedButton>(resetButton).onPressed, isNotNull);

    await tester.tap(resetButton);
    await tester.pump();
    expect(find.text('0'), findsOneWidget);
  });
}
