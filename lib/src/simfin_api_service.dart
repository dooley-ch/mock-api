// ╔═════════════════════════════════════════════════════════════════════════════════════════════════
// ║     simfin_api_service.dart
// ╠═════════════════════════════════════════════════════════════════════════════════════════════════
// ║     Created: 07.03.2025
// ║
// ║     Copyright (c) 2025 James Dooley <james@dooley.ch>
// ║
// ║     History:
// ║     07.03.2025: Initial version
// ╚═════════════════════════════════════════════════════════════════════════════════════════════════

import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:mock_api/mock_api.dart';
import 'exceptions.dart';

/// Implements the SimFin Mock Api
class SimFinApiService {
  static const _noMoreRequestsAllowed = 'You have exhausted your API Request Quota';

  late final Configuration _config;
  late final String _filesFolder;
  int _requestCount = 0;

  SimFinApiService() {
    _config = Configuration();
    _filesFolder = _config.webServer.filesFolder;
    _requestCount = 0;
  }

  /// Builds the list of headers to be returned with the downloaded file
  Map<String, Object> _getResponseHeaders({required String fileName, required int fileSize}) {
    var headers = <String, Object>{};

    headers['Pragma'] = 'public';
    headers['Expires'] = '0';
    headers['Cache-Control'] = 'must-revalidate, post-check=0, pre-check=0';
    headers['Cache-Control'] = 'public';
    headers['Content-Description'] = 'Transfer';
    headers['Content-type'] = 'application/octet-stream';
    headers['Content-Transfer-Encoding'] = 'Binary';
    headers['Content-Length'] = fileSize.toString();
    headers['Content-Disposition'] = 'attachment; filename="$fileName"';

    return headers;
  }

  /// Builds the name of the requested download file from the query parameters
  String _buildFileName({required Map<String, String> queryParams}) {
    String dataSet = '';
    String market = '';
    String variant = '';
    final fileName = StringBuffer();

    if (queryParams.containsKey('dataset')) {
      dataSet = queryParams['dataset']!;
    } else {
      throw MissingParameterException(parameter: 'dataset');
    }

    if (queryParams.containsKey('market')) {
      market = queryParams['market']!;
      if (market == "null") {
        market = '';
      }
    }

    if (queryParams.containsKey('variant')) {
      variant = queryParams['variant']!;
      if (variant == "null") {
        variant = '';
      }
    }

    if (market.isNotEmpty) {
      fileName.writeAll([market, "-"]);
    }
    fileName.write(dataSet);
    if (variant.isNotEmpty) {
      fileName.writeAll(["-", variant]);
    }
    fileName.write(".zip");

    return fileName.toString();
  }

  Router get router {
    final router = Router();

    router.get('/', (Request request) {
      // Check that we can still process requests
      if (_requestCount >= _config.apiService.maxCalls) {
        return Response(429, body: _noMoreRequestsAllowed);
      }

      // Process the request
      try {
        var requestedFileName = _buildFileName(queryParams: request.requestedUri.queryParameters);

        var file = File(path.join(_filesFolder, requestedFileName));
        if (!file.existsSync()) {
          return Response.internalServerError(body: '{"timestamp":"2025-03-14T22:13:30.144909355","status":"500","error":"Dataset not found","message":"Dataset not found"}');
        }

        var fileContents = file.readAsBytesSync();
        var responseHeaders = _getResponseHeaders(fileName: requestedFileName, fileSize: fileContents.length);

        _requestCount++;

        return Response.ok(fileContents, headers: responseHeaders);
      } on MissingParameterException catch (e) {
        return Response.badRequest(body: 'The query is missing a parameter: ${e.parameter}');
      } on FolderNotFoundException catch (e) {
        return Response.internalServerError(body: 'Failed to locate the folder: ${e.folder}');
      } catch (e) {
        return Response.internalServerError(body: 'Unexpected Error: ${e.toString()}');
      }
    });

    return router;
  }
}