import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ecobi/app.dart';
import 'package:ecobi/data/app_state.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Capture every implemented Pixso screen on Android', (
    tester,
  ) async {
    await tester.pumpWidget(EcobiApp(state: AppState(), initialRoute: 'home'));
    await tester.pumpAndSettle();
    final context = tester.element(find.byType(EcobiApp));
    await tester.runAsync(() async {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      await Future.wait(
        manifest
            .listAssets()
            .where((p) => p.startsWith('assets/images/') && p.endsWith('.png'))
            .map((p) => precacheImage(AssetImage(p), context)),
      );
    });
    await tester.pumpAndSettle();
    await binding.convertFlutterSurfaceToImage();
    const selection = String.fromEnvironment('CAPTURE_ROUTES');
    final routes = selection.isEmpty ? pages.keys : selection.split(',');
    for (final route in routes) {
      FocusManager.instance.primaryFocus?.unfocus();
      await SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 500)),
      );
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
      await tester.pumpWidget(EcobiApp(state: AppState(), initialRoute: route));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 250));
      expect(tester.takeException(), isNull, reason: 'Rendering $route');
      final bytes = await binding.takeScreenshot(route);
      final folder = Directory(
        '/data/user/0/com.ecobi.ecobi/files/screenshots',
      );
      await folder.create(recursive: true);
      await File('${folder.path}/$route.png').writeAsBytes(bytes);
      binding.reportData?.remove('screenshots');
      debugPrint('CAPTURED $route');
    }
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });
}
