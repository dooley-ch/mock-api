// ╔═════════════════════════════════════════════════════════════════════════════════════════════════
// ║     exceptions.dart
// ╠═════════════════════════════════════════════════════════════════════════════════════════════════
// ║     Created: 07.03.2025
// ║
// ║     Copyright (c) 2025 James Dooley <james@dooley.ch>
// ║
// ║     History:
// ║     07.03.2025: Initial version
// ╚═════════════════════════════════════════════════════════════════════════════════════════════════

import 'dart:io';

/// Raised when the application can't find a required file
class FileNotFoundException implements IOException {
  final String _fileName;

  String get fileName => _fileName;

  FileNotFoundException({required String fileName}) : _fileName = fileName;

  @override
  String toString() {
    return 'File not found: $_fileName';
  }
}

/// Raised when the application can't find a required file
class FolderNotFoundException implements IOException {
  final String _folderName;

  String get folder => _folderName;

  FolderNotFoundException({required String folderName}) : _folderName = folderName;

  @override
  String toString() {
    return 'Folder not found: $_folderName';
  }
}

/// Raised when the application is misconfigured
class ConfigurationException implements Exception {
  final String _message;

  ConfigurationException({required String message}) : _message = message;

  @override
  String toString() => _message;
}

/// Raised when a request is missing a parameter
class MissingParameterException implements Exception {
  final String _param;

  MissingParameterException({required String parameter}) : _param = parameter;

  @override
  String toString() => 'Missing parameter: $_param';

  String get parameter => _param;
}