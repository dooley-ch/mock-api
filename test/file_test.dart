// ╔═════════════════════════════════════════════════════════════════════════════════════════════════
// ║     file_test.dart
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
  late Process webServer;

  setUp(() async {
    webServer = await Process.start(
        'dart', ['run', 'bin/mock_api.dart']);
    await webServer.stdout.first;
  });

  tearDown(() => webServer.kill());

  test('markets.zip', () async {
    var requestHeaders = <String, String>{};
    requestHeaders['Authorization'] = 'api-key 1234567890';
    requestHeaders['Accept'] = 'application/zip';

    var requestUrl = Uri(
        scheme: 'http',
        host: 'localhost',
        port: 8080,
        path: '/api/bulk-download/s3',
        queryParameters: {'dataset': 'markets', 'variant': 'null', 'market': 'null'});

    final response = await http.get(requestUrl, headers: requestHeaders);

    var contentDisposition = response.headers['content-disposition'];

    expect(response.statusCode, 200);
    expect(contentDisposition!.contains('markets.zip'), isTrue);
  });

  test('industries.zip', () async {
    var requestHeaders = <String, String>{};
    requestHeaders['Authorization'] = 'api-key 1234567890';
    requestHeaders['Accept'] = 'application/zip';

    var requestUrl = Uri(
        scheme: 'http',
        host: 'localhost',
        port: 8080,
        path: '/api/bulk-download/s3',
        queryParameters: {'dataset': 'industries', 'variant': 'null', 'market': 'null'});

    final response = await http.get(requestUrl, headers: requestHeaders);

    var contentDisposition = response.headers['content-disposition'];

    expect(response.statusCode, 200);
    expect(contentDisposition!.contains('industries.zip'), isTrue);
  });

  test('404 - file not found', () async {
    var requestHeaders = <String, String>{};
    requestHeaders['Authorization'] = 'api-key 1234567890';
    requestHeaders['Accept'] = 'application/zip';

    var requestUrl = Uri(
        scheme: 'http',
        host: 'localhost',
        port: 8080,
        path: '/api/bulk-download/s3',
        queryParameters: {'dataset': 'missing-dataset', 'variant': 'null', 'market': 'null'});

    final response = await http.get(requestUrl, headers: requestHeaders);

    var contentDisposition = response.headers['content-disposition'];

    expect(response.statusCode, 404);
  });

  test('401 - Invalid api key', () async {
    var requestHeaders = <String, String>{};
    requestHeaders['Authorization'] = 'api-key 123';
    requestHeaders['Accept'] = 'application/zip';

    var requestUrl = Uri(
        scheme: 'http',
        host: 'localhost',
        port: 8080,
        path: '/api/bulk-download/s3',
        queryParameters: {'dataset': 'missing-dataset', 'variant': 'null', 'market': 'null'});

    final response = await http.get(requestUrl, headers: requestHeaders);

    var contentDisposition = response.headers['content-disposition'];

    expect(response.statusCode, 401);
  });
}
