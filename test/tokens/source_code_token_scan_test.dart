import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Strict Source Scan: No off-palette colors, no non-DM-Sans fonts, no dB, no safe listening in lib/', () {
    final libDir = Directory('lib');
    expect(libDir.existsSync(), isTrue, reason: 'lib directory must exist');

    final dartFiles = libDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));

    for (final file in dartFiles) {
      final isAppColors = file.path.endsWith('app_colors.dart') || file.path.endsWith('app_shadows.dart');
      final lines = file.readAsLinesSync();

      for (int i = 0; i < lines.length; i++) {
        final rawLine = lines[i];
        // Strip single-line comments
        final line = rawLine.split('//').first.trim();
        if (line.isEmpty) continue;

        // 1. Off-palette Material colors
        if (line.contains(RegExp(r'Colors\.(red|green|yellow|orange|pink|purple|amber|teal|lime|cyan)'))) {
          fail('Off-palette color detected in ${file.path}:${i + 1}: $rawLine');
        }

        // 2. Hard-coded Color hex constructors outside token definitions
        if (!isAppColors && line.contains(RegExp(r'Color\(0x[0-9a-fA-F]{8}\)'))) {
          fail('Hard-coded Color in ${file.path}:${i + 1}. All colors must reference AppColors: $rawLine');
        }

        // 3. Non-DM-Sans font declaration
        if (line.contains(RegExp(r'fontFamily:\s*[\x27\x22](?!DMSans)[\w\s]+[\x27\x22]'))) {
          fail('Non-DM-Sans font declaration in ${file.path}:${i + 1}: $rawLine');
        }

        // 4. Decibel claims forbidden (dB, dB HL, etc.)
        if (line.contains(RegExp(r'\bdB\b', caseSensitive: false))) {
          fail('Forbidden sound measurement unit "dB" in ${file.path}:${i + 1}: $rawLine');
        }

        // 5. "Safe listening" phrase forbidden
        if (line.contains(RegExp(r'safe\s+listening', caseSensitive: false))) {
          fail('Forbidden phrase "safe listening" in ${file.path}:${i + 1}: $rawLine');
        }

        // 6. Invalid Center.mainAxisSize
        if (line.contains(RegExp(r'Center\s*\([^)]*mainAxisSize'))) {
          fail('Invalid Center.mainAxisSize in ${file.path}:${i + 1}: $rawLine');
        }
      }
    }
  });
}
