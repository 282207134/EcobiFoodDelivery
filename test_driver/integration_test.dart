import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  await integrationDriver(
    onScreenshot: (name, bytes, [args]) async {
      final folder = Directory('docs/screenshots')..createSync(recursive: true);
      File('${folder.path}/$name.png').writeAsBytesSync(bytes);
      return true;
    },
    responseDataCallback: (_) async {
      final sdk =
          Platform.environment['ANDROID_HOME'] ??
          '${Platform.environment['LOCALAPPDATA']}\\Android\\Sdk';
      final result = await Process.run('$sdk\\platform-tools\\adb.exe', [
        '-s',
        Platform.environment['ECOBI_DEVICE_ID'] ?? 'emulator-5556',
        'exec-out',
        'run-as',
        'com.ecobi.ecobi',
        'tar',
        '-C',
        'files/screenshots',
        '-cf',
        '-',
        '.',
      ], stdoutEncoding: null);
      if (result.exitCode != 0) {
        throw StateError('Screenshot export failed: ${result.stderr}');
      }
      final archive = File('build/screen-captures.tar');
      await archive.writeAsBytes(result.stdout as List<int>);
      Directory('docs/screenshots').createSync(recursive: true);
      final extracted = await Process.run('tar', [
        '-xf',
        archive.path,
        '-C',
        'docs/screenshots',
      ]);
      if (extracted.exitCode != 0) {
        throw StateError('Screenshot extraction failed: ${extracted.stderr}');
      }
      await archive.delete();
    },
  );
}
