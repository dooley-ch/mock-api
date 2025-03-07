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

/// Holds the application's config information
class Configuration {
  static Configuration? _configuration;

  final WebServer _webServer;
  final SimFinApi _apiService;
  final ThrowError _throwError;
  final MockErrorsMap _mockErrors;

  WebServer get webServer => _webServer;
  SimFinApi get apiService => _apiService;
  ThrowError get throwError => _throwError;

  MockError get errorToThrow  {
    if (_mockErrors.containsKey(throwError.statusCode)) {
      return _mockErrors[_throwError.statusCode]!;
    }

    throw ConfigurationException(message: 'Invalid errorToThrow configuration');
  }

  Configuration._internal({required WebServer webServer, required SimFinApi apiService,
      required ThrowError throwError, required MockErrorsMap mockErrors }) :
      _webServer = webServer, _apiService = apiService, _throwError = throwError, _mockErrors = mockErrors;

  factory Configuration() {
    if (_configuration == null) {
      var configFile = _findConfigFile();
      var configData = TomlDocument.loadSync(configFile).toMap();

      var serverData = configData['server'];
      var apiData= configData['api'];
      var throwErrorData = configData['throw-error'];
      var mockErrorsData = configData['mock-error'];

      var webServer = WebServer(port: serverData['port']);
      var apiService = SimFinApi(key: apiData['key'], maxCalls: apiData['max-calls']);
      var throwError = ThrowError(active: throwErrorData['active'], statusCode: throwErrorData['error']);

      var errors = <int, MockError>{};
      for (var error in mockErrorsData) {
        var status = error['status'];
        var message = error['message'];

        errors[status] = MockError(statusCode: status, message: message);
      }

      _configuration = Configuration._internal(webServer: webServer, apiService: apiService,
          throwError: throwError, mockErrors: errors);
    }

    return _configuration!;
  }

}
/// Holds configuration information for the web server
class WebServer {
  final int _port;

  int get port => _port;

  WebServer({required int port}) : _port = port;

  @override
  String toString() {
    return 'WebServer(port: $_port)';
  }

  @override
  bool operator == (Object other) =>
      identical(this, other) ||
      other is WebServer &&
          runtimeType == other.runtimeType &&
          _port == other._port;

  @override
  int get hashCode => _port.hashCode;
}

/// Holds information about the service offered
class SimFinApi {
  final String _key;
  final int _maxCalls;

  String get key => _key;
  int get maxCalls => _maxCalls;

  SimFinApi({required String key, required int maxCalls}) :
        _key = key, _maxCalls = maxCalls;

  @override
  bool operator == (Object other) =>
      identical(this, other) ||
      other is SimFinApi &&
          runtimeType == other.runtimeType &&
          _key == other._key;

  @override
  int get hashCode => _key.hashCode;

  @override
  String toString() {
    return 'SimFinApi(key: $_key)';
  }
}

/// Holds details about throwing an error
class ThrowError {
  final bool _active;
  final int _statusCode;

  bool get active => _active;
  int get statusCode => _statusCode;

  ThrowError({required bool active, required int statusCode}) :
      _active = active, _statusCode = statusCode;

  @override
  String toString() {
    return 'ThrowError(active: $_active, statusCode: $_statusCode)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThrowError &&
          runtimeType == other.runtimeType &&
          _active == other._active &&
          _statusCode == other._statusCode;

  @override
  int get hashCode => _active.hashCode ^ _statusCode.hashCode;
}

/// Holds details of an error the server can return
class MockError {
  final int _statusCode;
  final String _message;

  int get statusCode => _statusCode;
  String get message => _message;

  MockError({required int statusCode, required String message}) :
      _statusCode = statusCode, _message = message;

  @override
  String toString() {
    return 'MockError(statusCode: $_statusCode, message: $_message)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is MockError &&
              runtimeType == other.runtimeType &&
              _statusCode == other._statusCode &&
              _message == other._message;

  @override
  int get hashCode => _statusCode.hashCode ^ _message.hashCode;
}

/// A collection of MockError instances
typedef MockErrorsMap = Map<int, MockError>;
