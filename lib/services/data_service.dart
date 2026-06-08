import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/prompt.dart';

/// Result of a restore from backup.
class RestoreResult {
  const RestoreResult({required this.prompts});
  final List<Prompt> prompts;
  int get count => prompts.length;
}

/// Prompt import/export: sharing as `.md` files, importing existing Markdown,
/// and JSON backup/restore of all local data.
class DataService {
  DataService._();
  static final DataService instance = DataService._();

  static const int backupVersion = 1;

  /// Extensions accepted when importing text.
  static const List<String> markdownExtensions = ['md', 'markdown', 'txt'];

  /// Extensions accepted when restoring a backup.
  static const List<String> backupExtensions = ['json', 'txt'];

  /// Shares a prompt as a `.md` file through the share sheet.
  Future<void> sharePrompt(Prompt prompt) async {
    final fileName = '${_safeFileName(prompt.title)}.md';
    final dir = await getTemporaryDirectory();
    final file = File(p.join(dir.path, fileName));
    await file.writeAsString(promptToMarkdownFile(prompt));
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'text/markdown')],
        subject: prompt.title.isEmpty ? 'Prompt' : prompt.title,
      ),
    );
  }

  /// Imports a Markdown file chosen by the user and turns it into a new
  /// [Prompt] (not yet saved). Returns null if the user cancels.
  Future<Prompt?> importMarkdown() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: markdownExtensions,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return null;
    final picked = result.files.single;
    final content = await _readPicked(picked);
    if (content == null) return null;
    final title = _titleFromMarkdown(content, fallback: picked.name);
    return Prompt.create(title: title, contentMarkdown: content.trim());
  }

  /// Creates a JSON backup of all [prompts] and shares it as a file.
  Future<void> backup(List<Prompt> prompts) async {
    final dir = await getTemporaryDirectory();
    final file = File(p.join(dir.path, 'autoprompter-backup.json'));
    await file.writeAsString(encodeBackup(prompts));
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/json')],
        subject: 'Autoprompter backup',
      ),
    );
  }

  /// Restores the prompts from a backup file chosen by the user.
  /// Returns null if the user cancels.
  Future<RestoreResult?> restore() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: backupExtensions,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return null;
    final content = await _readPicked(result.files.single);
    if (content == null) return null;
    return RestoreResult(prompts: decodeBackup(content));
  }

  // --- pure logic (testable) ---

  /// Exported `.md` file content: title as H1 + Markdown body.
  static String promptToMarkdownFile(Prompt prompt) {
    final body = prompt.contentMarkdown.trim();
    final title = prompt.title.trim();
    if (title.isEmpty) return body.isEmpty ? '' : '$body\n';
    return '# $title\n\n$body\n';
  }

  /// Serializes a list of prompts into the backup format.
  static String encodeBackup(List<Prompt> prompts) {
    final map = {
      'app': 'autoprompter',
      'version': backupVersion,
      'prompts': prompts.map((p) => p.toMap()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(map);
  }

  /// Deserializes a backup, tolerating both the wrapped format
  /// (`{"prompts": [...]}`) and a plain list of prompts.
  static List<Prompt> decodeBackup(String content) {
    final decoded = jsonDecode(content);
    final List rawPrompts;
    if (decoded is Map && decoded['prompts'] is List) {
      rawPrompts = decoded['prompts'] as List;
    } else if (decoded is List) {
      rawPrompts = decoded;
    } else {
      throw const FormatException('Invalid backup');
    }
    return rawPrompts
        .whereType<Map>()
        .map((m) => Prompt.fromMap(Map<String, Object?>.from(m)))
        .toList();
  }

  /// Derives a title from the Markdown: first `# Title` line, otherwise the
  /// first non-empty line, otherwise the file name without extension.
  static String _titleFromMarkdown(String content, {required String fallback}) {
    for (final line in const LineSplitter().convert(content)) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      final heading = RegExp(r'^#{1,6}\s+(.*)$').firstMatch(trimmed);
      if (heading != null) return heading.group(1)!.trim();
      return trimmed.length > 80 ? trimmed.substring(0, 80) : trimmed;
    }
    return p.basenameWithoutExtension(fallback);
  }

  static String _safeFileName(String title) {
    final base = title.trim().isEmpty ? 'prompt' : title.trim();
    final sanitized = base.replaceAll(RegExp(r'[^\w\s\-]'), '').trim();
    final collapsed = sanitized.replaceAll(RegExp(r'\s+'), '-');
    return collapsed.isEmpty ? 'prompt' : collapsed;
  }

  Future<String?> _readPicked(PlatformFile picked) async {
    if (picked.bytes != null) {
      return utf8.decode(picked.bytes!, allowMalformed: true);
    }
    final path = picked.path;
    if (path != null) return File(path).readAsString();
    return null;
  }
}
