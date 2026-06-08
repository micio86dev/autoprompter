import 'dart:convert';

import 'package:uuid/uuid.dart';

/// A prompt (text to be read on the teleprompter).
///
/// The content is stored as **Markdown**; [localeId] is the language used by
/// speech recognition for this prompt (e.g. `it_IT`). [tags] are free-form
/// labels used to organize and filter prompts.
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

  /// Creates a new empty prompt with a generated id and timestamps.
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

  /// Serializes the tags as a JSON array (robust to commas and special chars).
  static String encodeTags(List<String> tags) {
    final cleaned = normalizeTags(tags);
    return cleaned.isEmpty ? '' : jsonEncode(cleaned);
  }

  /// Decodes the tags from storage, tolerating legacy/CSV formats and null or
  /// malformed values.
  static List<String> decodeTags(String? raw) {
    if (raw == null || raw.trim().isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return normalizeTags(decoded.map((e) => e.toString()));
      }
    } catch (_) {
      // Non-JSON format (e.g. legacy CSV): fall back to comma splitting.
    }
    return normalizeTags(raw.split(','));
  }

  /// Cleans and de-duplicates a list of tags (trim, drop empties, preserve
  /// order, case-insensitive comparison).
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
