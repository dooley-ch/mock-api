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

  String get folderName => _folderName;

  FolderNotFoundException({required String folderName}) : _folderName = folderName;

  @override
  String toString() {
    return 'Folder not found: $_folderName';
  }
}