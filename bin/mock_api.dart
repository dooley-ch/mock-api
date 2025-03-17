// ╔═════════════════════════════════════════════════════════════════════════════════════════════════
// ║     mock_api.dart
// ╠═════════════════════════════════════════════════════════════════════════════════════════════════
// ║     Created: 07.03.2025
// ║
// ║     Copyright (c) 2025 James Dooley <james@dooley.ch>
// ║
// ║     History:
// ║     07.03.2025: Initial version
// ╚═════════════════════════════════════════════════════════════════════════════════════════════════

import 'package:mock_api/mock_api.dart';

final _config = Configuration();

const customHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, OPTIONS',
  'Access-Control-Allow-Headers': 'Origin, Content-Type, Authorization',
  'Access-Control-Allow-Credentials': 'true',
};

final _router = Router()
  ..get('/', _rootHandler)
  ..options('/', _optionsHandler)
  ..mount('/api/bulk-download/s3', SimFinApiService().router.call);

Response _rootHandler(Request req) {
  return Response.ok('SimFin Download API Mock Server!\n');
}

Response _optionsHandler(Request req) {
  return Response.ok('', headers: customHeaders);
}

void main(List<String> arguments) async {
  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders(headers: customHeaders))
      .addMiddleware(validateApiKeyHandler())
      .addMiddleware(badRequestHandler())
      .addHandler(_router.call);

  final server = await serve(handler, 'localhost', _config.webServer.port);
  print('Server listening on port ${server.port}\n');
  print('Direct your browser to: http://${server.address.host}:${server.port}/');
  print('For API Calls: http://${server.address.host}:${server.port}/api/bulk-download/s3');
  print('Serving files from: ${_config.webServer.filesFolder}');
}
