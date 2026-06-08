import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:markdown_quill/markdown_quill.dart';

/// Conversioni tra Markdown, il formato Delta di Quill e testo semplice.
class MarkdownService {
  MarkdownService._();

  static final md.Document _mdDocument = md.Document(
    encodeHtml: false,
    extensionSet: md.ExtensionSet.gitHubFlavored,
  );

  static final MarkdownToDelta _mdToDelta =
      MarkdownToDelta(markdownDocument: _mdDocument);
  static final DeltaToMarkdown _deltaToMd = DeltaToMarkdown();

  /// Markdown -> Delta (per popolare l'editor Quill).
  static Delta markdownToDelta(String markdown) {
    final delta = _mdToDelta.convert(markdown);
    return _ensureTrailingNewline(delta);
  }

  /// Delta -> Markdown (per il salvataggio).
  static String deltaToMarkdown(Delta delta) {
    return _deltaToMd.convert(delta).trimRight();
  }

  /// Markdown -> documento Quill pronto per l'editor.
  static Document documentFromMarkdown(String markdown) {
    if (markdown.trim().isEmpty) {
      return Document();
    }
    return Document.fromDelta(markdownToDelta(markdown));
  }

  /// Markdown -> testo semplice (usato dal teleprompter per la lettura).
  static String markdownToPlainText(String markdown) {
    if (markdown.trim().isEmpty) return '';
    return documentFromMarkdown(markdown).toPlainText().trimRight();
  }

  /// Quill richiede che il Delta termini con un newline.
  static Delta _ensureTrailingNewline(Delta delta) {
    final ops = delta.toList();
    if (ops.isEmpty) {
      return Delta()..insert('\n');
    }
    final last = ops.last;
    final data = last.data;
    if (data is String && data.endsWith('\n')) {
      return delta;
    }
    return Delta.from(delta)..insert('\n');
  }
}
