#!/usr/bin/env dart

import 'dart:io';

/// Automated i18n checker script
/// Scans all Dart files for hardcoded English strings that should be localized
///
/// Usage: dart scripts/check_i18n.dart
///
/// This script will:
/// 1. Search for hardcoded English text in Text() widgets
/// 2. Search for hardcoded strings in common widget properties
/// 3. Report files and line numbers where issues are found
/// 4. Suggest translation keys for found strings
/// 5. Exit with code 1 if issues found (for CI/CD integration)

void main(List<String> args) async {
  print('🔍 Starting i18n compliance check...\n');

  final libPath = Directory('lib');
  if (!await libPath.exists()) {
    print('❌ Error: lib directory not found');
    print('   Please run this script from the project root');
    exit(1);
  }

  final issues = <I18nIssue>[];

  // Scan all Dart files
  await for (final file in libPath.list(recursive: true)) {
    if (file is File && file.path.endsWith('.dart')) {
      final fileIssues = await checkFile(file);
      issues.addAll(fileIssues);
    }
  }

  // Report results
  if (issues.isEmpty) {
    print('✅ No i18n issues found! All user-facing strings are properly localized.\n');
    exit(0);
  } else {
    print('❌ Found ${issues.length} potential i18n issue(s):\n');

    // Group by file
    final byFile = <String, List<I18nIssue>>{};
    for (final issue in issues) {
      byFile.putIfAbsent(issue.file, () => []).add(issue);
    }

    // Print results
    for (final entry in byFile.entries) {
      print('📄 ${entry.key}:');
      for (final issue in entry.value) {
        print('   Line ${issue.line}: ${issue.message}');
        print('   Found: "${issue.text}"');
        print('   Suggested key: ${issue.suggestedKey}');
        print('');
      }
    }

    print('💡 To fix these issues:');
    print('   1. Add translation keys to lib/core/localization/app_localizations.dart');
    print('   2. Replace hardcoded strings with l10n.translate(\'key_name\')');
    print('   3. Add AppLocalizations import if missing');
    print('');
    exit(1);
  }
}

Future<List<I18nIssue>> checkFile(File file) async {
  final issues = <I18nIssue>[];

  // Skip generated files, tests, and localization file itself
  if (file.path.contains('.g.dart') ||
      file.path.contains('_test.dart') ||
      file.path.contains('app_localizations.dart') ||
      file.path.contains('/l10n/')) {
    return issues;
  }

  final lines = await file.readAsLines();

  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    final lineNum = i + 1;

    // Check for Text() widgets with hardcoded strings
    final textMatches = RegExp(r'''Text\(\s*['"]([^'"]+)['"]\s*[,\)]''').allMatches(line);
    for (final match in textMatches) {
      final text = match.group(1)!;
      if (_isLikelyUserFacingEnglish(text) && !_isException(text)) {
        issues.add(I18nIssue(
          file: file.path,
          line: lineNum,
          text: text,
          message: 'Hardcoded string in Text() widget',
          suggestedKey: _suggestKey(text),
        ));
      }
    }

    // Check for hardcoded strings in common properties
    final propPatterns = [
      RegExp(r'''(hintText|labelText|title|subtitle|label|tooltip):\s*['"]([^'"]+)['"]'''),
      RegExp(r'''content:\s*Text\(\s*['"]([^'"]+)['"]'''),
      RegExp(r'''SnackBar\([^)]*content:\s*Text\(\s*['"]([^'"]+)['"]'''),
    ];

    for (final pattern in propPatterns) {
      final matches = pattern.allMatches(line);
      for (final match in matches) {
        final text = match.groupCount >= 2 ? match.group(2)! : match.group(1)!;
        if (_isLikelyUserFacingEnglish(text) && !_isException(text)) {
          issues.add(I18nIssue(
            file: file.path,
            line: lineNum,
            text: text,
            message: 'Hardcoded string in widget property',
            suggestedKey: _suggestKey(text),
          ));
        }
      }
    }
  }

  return issues;
}

/// Check if a string looks like user-facing English text
bool _isLikelyUserFacingEnglish(String text) {
  // Ignore if it's already a translation key or method call
  if (text.contains('.translate(') || text.contains('l10n.')) {
    return false;
  }

  // Ignore technical strings
  if (text.startsWith('http') ||
      text.startsWith('www.') ||
      text.startsWith('/') ||
      text.contains('://')) {
    return false;
  }

  // Ignore very short strings (likely to be symbols or technical)
  if (text.length < 3) {
    return false;
  }

  // Check if it contains English words
  final commonEnglishWords = [
    'the', 'a', 'an', 'and', 'or', 'but', 'is', 'are', 'was', 'were',
    'has', 'have', 'had', 'do', 'does', 'did', 'can', 'could', 'will',
    'would', 'should', 'may', 'might', 'must', 'for', 'to', 'of', 'in',
    'on', 'at', 'by', 'with', 'from', 'about', 'after', 'before',
    'no', 'not', 'yes', 'please', 'thank', 'welcome', 'hello', 'hi',
    'good', 'great', 'bad', 'start', 'stop', 'add', 'remove', 'delete',
    'save', 'cancel', 'ok', 'loading', 'error', 'success', 'failed',
  ];

  final lowerText = text.toLowerCase();
  for (final word in commonEnglishWords) {
    if (lowerText.contains(RegExp(r'\b' + word + r'\b'))) {
      return true;
    }
  }

  // Check if it looks like a sentence (capital letter start)
  if (RegExp(r'^[A-Z][a-z]+ .+').hasMatch(text)) {
    return true;
  }

  return false;
}

/// Check if string should be excluded from checking
bool _isException(String text) {
  // Exception patterns that are OK to be hardcoded
  final exceptions = [
    // Version numbers, numbers only
    RegExp(r'^\d+(\.\d+)*$'),
    // Single characters
    RegExp(r'^.$'),
    // Icon descriptions (often just icon names)
    RegExp(r'^Icons\.\w+$'),
    // Emoji only
    RegExp(r'^[\u{1F300}-\u{1F9FF}]+$', unicode: true),
    // Technical identifiers
    RegExp(r'^[A-Z_][A-Z0-9_]*$'),
  ];

  for (final pattern in exceptions) {
    if (pattern.hasMatch(text)) {
      return true;
    }
  }

  return false;
}

/// Suggest a translation key name based on the text
String _suggestKey(String text) {
  // Clean and convert to snake_case
  var key = text.toLowerCase()
      .replaceAll(RegExp(r'[^\w\s]'), '')
      .replaceAll(RegExp(r'\s+'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .trim();

  // Limit length
  if (key.length > 50) {
    final words = key.split('_');
    key = words.take(5).join('_');
  }

  return key;
}

class I18nIssue {
  final String file;
  final int line;
  final String text;
  final String message;
  final String suggestedKey;

  I18nIssue({
    required this.file,
    required this.line,
    required this.text,
    required this.message,
    required this.suggestedKey,
  });
}
