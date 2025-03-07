// ╔═════════════════════════════════════════════════════════════════════════════════════════════════
// ║     server_root_test.dart
// ╠═════════════════════════════════════════════════════════════════════════════════════════════════
// ║     Created: 07.03.2025
// ║
// ║     Copyright (c) 2025 James Dooley <james@dooley.ch>
// ║
// ║     History:
// ║     07.03.2025: Initial version
// ╚═════════════════════════════════════════════════════════════════════════════════════════════════

import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

void main() {
  final port = '8080';
  final host = 'http://localhost:$port';
  late Process webSvr;

  setUp(() async {
    webSvr = await Process.start('dart', ['run', 'bin/mock_api.dart']);
    await webSvr.stdout.first;
  });

  tearDown(() => webSvr.kill());

  test('Root', () async {
    final response = await http.get(Uri.parse('$host/'));
    expect(response.statusCode, 200);
    expect(response.body, 'SimFin Download API Mock Server!\n');
  });

  test('404', () async {
    final response = await http.get(Uri.parse('$host/foobar'));
    expect(response.statusCode, 404);
  });
}
