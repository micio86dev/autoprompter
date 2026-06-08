import 'dart:convert';

import 'package:uuid/uuid.dart';

/// Un prompt (testo da leggere al teleprompter).
///
/// Il contenuto è memorizzato in **Markdown**; [localeId] è la lingua usata
/// dal riconoscimento vocale per questo prompt (es. `it_IT`). [tags] sono
/// etichette libere usate per organizzare e filtrare i prompt.
class Prompt {
  Prompt({
    required this.id,
    required this.title,
    required this.contentMarkdown,
    required this.localeId,
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],
  });

  final String id;
  final String title;
  final String contentMarkdown;
  final String localeId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;

  /// Crea un nuovo prompt vuoto con id e timestamp generati.
  factory Prompt.create({
    String title = '',
    String contentMarkdown = '',
    String localeId = 'it_IT',
    List<String> tags = const [],
  }) {
    final now = DateTime.now();
    return Prompt(
      id: const Uuid().v4(),
      title: title,
      contentMarkdown: contentMarkdown,
      localeId: localeId,
      createdAt: now,
      updatedAt: now,
      tags: tags,
    );
  }

  Prompt copyWith({
    String? title,
    String? contentMarkdown,
    String? localeId,
    DateTime? updatedAt,
    List<String>? tags,
  }) {
    return Prompt(
      id: id,
      title: title ?? this.title,
      contentMarkdown: contentMarkdown ?? this.contentMarkdown,
      localeId: localeId ?? this.localeId,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'title': title,
        'content_markdown': contentMarkdown,
        'locale_id': localeId,
        'created_at': createdAt.millisecondsSinceEpoch,
        'updated_at': updatedAt.millisecondsSinceEpoch,
        'tags': encodeTags(tags),
      };

  factory Prompt.fromMap(Map<String, Object?> map) => Prompt(
        id: map['id'] as String,
        title: map['title'] as String? ?? '',
        contentMarkdown: map['content_markdown'] as String? ?? '',
        localeId: map['locale_id'] as String? ?? 'it_IT',
        createdAt: DateTime.fromMillisecondsSinceEpoch(
            (map['created_at'] as int?) ?? 0),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(
            (map['updated_at'] as int?) ?? 0),
        tags: decodeTags(map['tags'] as String?),
      );

  /// Serializza i tag come array JSON (robusto a virgole e caratteri speciali).
  static String encodeTags(List<String> tags) {
    final cleaned = normalizeTags(tags);
    return cleaned.isEmpty ? '' : jsonEncode(cleaned);
  }

  /// Decodifica i tag dallo storage, tollerando formati legacy/CSV e valori
  /// nulli o malformati.
  static List<String> decodeTags(String? raw) {
    if (raw == null || raw.trim().isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return normalizeTags(decoded.map((e) => e.toString()));
      }
    } catch (_) {
      // Formato non-JSON (es. CSV legacy): ripiega sulla virgola.
    }
    return normalizeTags(raw.split(','));
  }

  /// Pulisce e deduplica una lista di tag (trim, scarta i vuoti, ordine
  /// preservato e confronto case-insensitive).
  static List<String> normalizeTags(Iterable<String> tags) {
    final result = <String>[];
    final seen = <String>{};
    for (final tag in tags) {
      final trimmed = tag.trim();
      if (trimmed.isEmpty) continue;
      final key = trimmed.toLowerCase();
      if (seen.add(key)) result.add(trimmed);
    }
    return result;
  }
}
