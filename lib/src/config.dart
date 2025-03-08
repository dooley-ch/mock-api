// ╔═════════════════════════════════════════════════════════════════════════════════════════════════
// ║     config.dart
// ╠═════════════════════════════════════════════════════════════════════════════════════════════════
// ║     Created: 07.03.2025
// ║
// ║     Copyright (c) 2025 James Dooley <james@dooley.ch>
// ║
// ║     History:
// ║     07.03.2025: Initial version
// ╚═════════════════════════════════════════════════════════════════════════════════════════════════

import 'dart:io' as io;
import 'package:path/path.dart' as path;
import 'package:toml/toml.dart' show TomlDocument;
import 'exceptions.dart';

String _findConfigFile() {
  const configFileName = 'mock-api.toml';

  var currentFolder = io.Directory.current.path;
  var appFolder = path.dirname(io.Platform.script.toFilePath());

  var file = io.File(path.join(currentFolder, configFileName));
  if (file.existsSync()) {
    return file.path;
  }

  file = io.File(path.join(appFolder, configFileName));
  if (file.existsSync()) {
    return file.path;
  }

  throw FileNotFoundException(fileName: configFileName);
}

String findFilesFolder() {
  const filesFolderName = 'files';

  var currentFolder = io.Directory.current.path;
  var appFolder = path.dirname(io.Platform.script.toFilePath());

  var folder = io.Directory(path.join(currentFolder, filesFolderName));
  if (folder.existsSync()) {
    return folder.path;
  }

  folder = io.Directory(path.join(appFolder, filesFolderName));
  if (folder.existsSync()) {
    return folder.path;
  }

  throw FolderNotFoundException(folderName: filesFolderName);
}

typedef SimFinApiInfo = ({String key, int maxCalls});
typedef WebServerInfo = ({int port});
typedef ThrowErrorInfo = ({bool active, int statusCode});
typedef MockErrorInfo = ({int statusCode, String message});
typedef MockErrorInfoMap = Map<int, MockErrorInfo>;

/// Holds the application's config information
class Configuration {
  static Configuration? _configuration;

  final WebServerInfo _webServer;
  final SimFinApiInfo _apiService;
  final ThrowErrorInfo _throwError;
  final MockErrorInfoMap _mockErrors;

  WebServerInfo get webServer => _webServer;
  SimFinApiInfo get apiService => _apiService;
  ThrowErrorInfo get throwError => _throwError;

  MockErrorInfo get errorToThrow  {
    if (_mockErrors.containsKey(throwError.statusCode)) {
      return _mockErrors[_throwError.statusCode]!;
    }

    throw ConfigurationException(message: 'Invalid errorToThrow configuration');
  }

  Configuration._internal({required WebServerInfo webServer, required SimFinApiInfo apiService,
      required ThrowErrorInfo throwError, required MockErrorInfoMap mockErrors }) :
      _webServer = webServer, _apiService = apiService, _throwError = throwError, _mockErrors = mockErrors;

  factory Configuration() {
    if (_configuration == null) {
      var configFile = _findConfigFile();
      var configData = TomlDocument.loadSync(configFile).toMap();

      var serverData = configData['server'];
      var apiData= configData['api'];
      var throwErrorData = configData['throw-error'];
      var mockErrorsData = configData['mock-error'];

      var errors = <int, MockErrorInfo>{};
      for (var error in mockErrorsData) {
        var status = error['status'];
        var message = error['message'];

        errors[status] = (statusCode: status, message:  message);
      }

      _configuration = Configuration._internal(webServer: (port: serverData['port']),
          apiService: (key: apiData['key'], maxCalls: apiData['max-calls']),
          throwError: (active: throwErrorData['active'], statusCode: throwErrorData['error']), mockErrors: errors);
    }

    return _configuration!;
  }

}
