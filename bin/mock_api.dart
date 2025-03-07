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

import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:mock_api/mock_api.dart' as mock_api;

var _config = mock_api.Configuration();

final _router = Router()
  ..get('/', _rootHandler)
  ..mount('/api/bulk-download/s3', mock_api.SimFinApiService().router.call);

Response _rootHandler(Request req) {
  return Response.ok('SimFin Download API Mock Server!\n');
}

void main(List<String> arguments) async {
  final ip = InternetAddress.anyIPv4;

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware((innerHandler) => (request) async {
        var path = request.requestedUri.path;

        if (path.contains('/api/bulk-download/s3')) {
          var requiredApiKey = 'api-key ${_config.apiService.key}';
          var apiKey = request.headers['Authorization'];
          if (apiKey != requiredApiKey) {
            return Response.unauthorized('Invalid API key provided');
          }
        }

        return await innerHandler(request);
      }).addHandler(_router.call);

  final server = await serve(handler, ip, _config.webServer.port);
  print('Server listening on port ${server.port}\n');
  print('Direct your browser to: http://localhost:${server.port}/');
}
