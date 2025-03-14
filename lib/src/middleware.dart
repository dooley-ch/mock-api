// ╔═════════════════════════════════════════════════════════════════════════════════════════════════
// ║     middleware.dart
// ╠═════════════════════════════════════════════════════════════════════════════════════════════════
// ║     Created: 14.03.2025
// ║
// ║     Copyright (c) 2025 James Dooley <james@dooley.ch>
// ║
// ║     History:
// ║     14.03.2025: Initial version
// ╚═════════════════════════════════════════════════════════════════════════════════════════════════

import 'package:shelf/shelf.dart';
import 'config.dart';

/// Handles invalid requests to the server
Middleware badRequestHandler() {
  return createMiddleware(
    requestHandler: (Request request) {
      if ((request.method != 'GET') && (request.method != 'OPTIONS')) {
        return Response.badRequest(body: 'Method not allowed');
      }
      return null;
    }
  );
}

/// Validates the api key supplied in the request with that defined in the
/// config file
Middleware validateApiKeyHandler() {
  return createMiddleware(requestHandler: (Request request) {
    final cfg = Configuration();
    final path = request.requestedUri.path;

    if (path.contains('/api/bulk-download/s3')) {
      final requiredApiKey = 'api-key ${cfg.apiService.key}';
      final apiKey = request.headers['Authorization'];
      if (apiKey != requiredApiKey) {
        return Response.unauthorized('Invalid API key provided');
      }
    }
    return null;
  });
}