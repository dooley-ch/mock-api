// ╔═════════════════════════════════════════════════════════════════════════════════════════════════
// ║     configuration.dart
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
  final currentFolder = io.Directory.current.path;

  var file = io.File(path.join(currentFolder, configFileName));
  if (file.existsSync()) {
    return file.path;
  }

  final appFolder = path.dirname(io.Platform.script.toFilePath());
  file = io.File(path.join(appFolder, configFileName));
  if (file.existsSync()) {
    return file.path;
  }

  throw FileNotFoundException(fileName: configFileName);
}

/// Structure to hold the SimFin Api config data
typedef SimFinApiInfo = ({String key, int maxCalls});

/// Structure to hold the server config data
typedef WebServerInfo = ({int port, String filesFolder});

/// Holds the application's config information
class Configuration {
  static Configuration? _configuration;

  late final WebServerInfo _webServer;
  late final SimFinApiInfo _apiService;

  WebServerInfo get webServer => _webServer;
  SimFinApiInfo get apiService => _apiService;

  Configuration._private() {
    final configFile = _findConfigFile();
    final configData = TomlDocument.loadSync(configFile).toMap();
    final serverData = configData['server'];
    final apiData= configData['api'];

    _webServer = (port: serverData['port'], filesFolder: serverData['files']);
    _apiService = (key: apiData['key'], maxCalls: apiData['max-calls']);
  }

  factory Configuration() {
    _configuration ??= Configuration._private();
    return _configuration!;
  }
}
