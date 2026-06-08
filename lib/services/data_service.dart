import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/prompt.dart';

/// Risultato di un ripristino da backup.
class RestoreResult {
  const RestoreResult({required this.prompts});
  final List<Prompt> prompts;
  int get count => prompts.length;
}

/// Import/export dei prompt: condivisione come file `.md`, importazione di
/// Markdown esistente e backup/ripristino JSON di tutti i dati locali.
class DataService {
  DataService._();
  static final DataService instance = DataService._();

  static const int backupVersion = 1;

  /// Estensioni accettate per l'importazione di testo.
  static const List<String> markdownExtensions = ['md', 'markdown', 'txt'];

  /// Estensioni accettate per il ripristino del backup.
  static const List<String> backupExtensions = ['json', 'txt'];

  /// Condivide un prompt come file `.md` tramite il foglio di condivisione.
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

  /// Importa un file Markdown scelto dall'utente e lo trasforma in un nuovo
  /// [Prompt] (non ancora salvato). Ritorna null se l'utente annulla.
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

  /// Crea un backup JSON di tutti i [prompts] e lo condivide come file.
  Future<void> backup(List<Prompt> prompts) async {
    final dir = await getTemporaryDirectory();
    final file = File(p.join(dir.path, 'autoprompter-backup.json'));
    await file.writeAsString(encodeBackup(prompts));
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/json')],
        subject: 'Backup Autoprompter',
      ),
    );
  }

  /// Ripristina i prompt da un file di backup scelto dall'utente.
  /// Ritorna null se l'utente annulla.
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

  // --- logica pura (testabile) ---

  /// Contenuto del file `.md` esportato: titolo come H1 + corpo Markdown.
  static String promptToMarkdownFile(Prompt prompt) {
    final body = prompt.contentMarkdown.trim();
    final title = prompt.title.trim();
    if (title.isEmpty) return body.isEmpty ? '' : '$body\n';
    return '# $title\n\n$body\n';
  }

  /// Serializza una lista di prompt nel formato di backup.
  static String encodeBackup(List<Prompt> prompts) {
    final map = {
      'app': 'autoprompter',
      'version': backupVersion,
      'prompts': prompts.map((p) => p.toMap()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(map);
  }

  /// Deserializza un backup, tollerando sia il formato con involucro
  /// (`{"prompts": [...]}`) sia una semplice lista di prompt.
  static List<Prompt> decodeBackup(String content) {
    final decoded = jsonDecode(content);
    final List rawPrompts;
    if (decoded is Map && decoded['prompts'] is List) {
      rawPrompts = decoded['prompts'] as List;
    } else if (decoded is List) {
      rawPrompts = decoded;
    } else {
      throw const FormatException('Backup non valido');
    }
    return rawPrompts
        .whereType<Map>()
        .map((m) => Prompt.fromMap(Map<String, Object?>.from(m)))
        .toList();
  }

  /// Ricava un titolo dal Markdown: prima riga `# Titolo`, altrimenti la prima
  /// riga non vuota, altrimenti il nome del file senza estensione.
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
