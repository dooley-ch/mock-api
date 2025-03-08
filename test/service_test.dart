// ╔═════════════════════════════════════════════════════════════════════════════════════════════════
// ║     service_test.dart
// ╠═════════════════════════════════════════════════════════════════════════════════════════════════
// ║     Created: 08.03.2025
// ║
// ║     Copyright (c) 2025 James Dooley <james@dooley.ch>
// ║
// ║     History:
// ║     08.03.2025: Initial version
// ╚═════════════════════════════════════════════════════════════════════════════════════════════════

import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

Future<void> main() async {
  const endPoint = 'http://localhost:8080';
  late Process webServer;

  setUp(() async {
    webServer = await Process.start(
      'dart', ['run', 'bin/mock_api.dart']);
    await webServer.stdout.first;
  });

  tearDown(() => webServer.kill());

  test('Root', () async {
    final response = await http.get(Uri.parse('$endPoint/'));
    expect(response.statusCode, 200);
    expect(response.body, 'SimFin Download API Mock Server!\n');
  });

  test('404', () async {
    final response = await http.get(Uri.parse('$endPoint/foobar'));
    expect(response.statusCode, 404);
  });
}
