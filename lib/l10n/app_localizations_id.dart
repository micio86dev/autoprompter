// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Autoprompter';

  @override
  String get searchPromptsHint => 'Cari prompt…';

  @override
  String get closeSearch => 'Tutup pencarian';

  @override
  String get search => 'Cari';

  @override
  String get sortTooltip => 'Urutkan';

  @override
  String get menuTooltip => 'Menu';

  @override
  String get importMarkdown => 'Impor Markdown…';

  @override
  String get backupData => 'Cadangkan data…';

  @override
  String get restoreBackup => 'Pulihkan cadangan…';

  @override
  String get settings => 'Pengaturan';

  @override
  String get newPrompt => 'Prompt baru';

  @override
  String get moreActions => 'Tindakan lainnya';

  @override
  String get openTeleprompter => 'Buka teleprompter';

  @override
  String get untitled => 'Tanpa judul';

  @override
  String get edit => 'Edit';

  @override
  String get duplicate => 'Duplikat';

  @override
  String get shareMd => 'Bagikan (.md)';

  @override
  String get delete => 'Hapus';

  @override
  String get cancel => 'Batal';

  @override
  String get deletePromptTitle => 'Hapus prompt?';

  @override
  String deletePromptMessage(String title) {
    return 'Apakah Anda ingin menghapus \"$title\"? Tindakan ini tidak dapat dibatalkan.';
  }

  @override
  String get promptDuplicated => 'Prompt diduplikasi';

  @override
  String get copySuffix => '(salinan)';

  @override
  String shareFailed(String error) {
    return 'Gagal membagikan: $error';
  }

  @override
  String importFailed(String error) {
    return 'Gagal mengimpor: $error';
  }

  @override
  String get noPromptsToBackup => 'Tidak ada prompt untuk dicadangkan';

  @override
  String backupFailed(String error) {
    return 'Pencadangan gagal: $error';
  }

  @override
  String promptsRestored(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count prompt dipulihkan',
    );
    return '$_temp0';
  }

  @override
  String restoreFailed(String error) {
    return 'Gagal memulihkan: $error';
  }

  @override
  String get noContent => 'Tidak ada konten';

  @override
  String get noPromptsMatchFilters =>
      'Tidak ada prompt yang cocok dengan filter';

  @override
  String get clearFilters => 'Hapus filter';

  @override
  String get noPrompts => 'Tidak ada prompt';

  @override
  String get emptyStateMessage =>
      'Ketuk \"Prompt baru\" untuk membuat teks pertama yang akan dibaca di teleprompter.';

  @override
  String get sortUpdatedDesc => 'Baru saja diedit';

  @override
  String get sortUpdatedAsc => 'Paling lama diedit';

  @override
  String get sortTitleAsc => 'Judul A→Z';

  @override
  String get sortTitleDesc => 'Judul Z→A';

  @override
  String get sortCreatedDesc => 'Baru saja dibuat';

  @override
  String get editPrompt => 'Edit prompt';

  @override
  String get markdownPreview => 'Pratinjau Markdown';

  @override
  String get hidePreview => 'Sembunyikan pratinjau';

  @override
  String get save => 'Simpan';

  @override
  String get promptSaved => 'Prompt disimpan';

  @override
  String get titleHint => 'Judul';

  @override
  String get voiceLanguage => 'Bahasa suara:';

  @override
  String get editorPlaceholder => 'Tulis teks prompt di sini…';

  @override
  String get addTagHint => 'Tambah tag…';

  @override
  String get emptyMarkdownPreview => '_(kosong)_';

  @override
  String get appearance => 'Tampilan';

  @override
  String get theme => 'Tema';

  @override
  String get themeSystem => 'Sistem';

  @override
  String get themeLight => 'Terang';

  @override
  String get themeDark => 'Gelap';

  @override
  String get themeSystemSubtitle => 'Ikuti sistem';

  @override
  String get teleprompterDefaults => 'Teleprompter (nilai bawaan)';

  @override
  String get textSize => 'Ukuran teks';

  @override
  String get autoscrollSpeed => 'Kecepatan gulir otomatis';

  @override
  String get readingLinePosition => 'Posisi baris baca';

  @override
  String get decreaseText => 'Perkecil teks';

  @override
  String get increaseText => 'Perbesar teks';

  @override
  String get restart => 'Mulai ulang';

  @override
  String get readingSettings => 'Pengaturan baca';

  @override
  String get mirrorHorizontal => 'Cermin horizontal';

  @override
  String get mirrorHorizontalSubtitle => 'Untuk kaca teleprompter';

  @override
  String get mirrorVertical => 'Cermin vertikal';

  @override
  String get emptyPromptMessage =>
      'Prompt ini kosong. Edit untuk menambahkan teks.';

  @override
  String get stop => 'Berhenti';

  @override
  String get startReading => 'Mulai membaca';

  @override
  String get speechUnavailable =>
      'Pengenalan suara tidak tersedia di perangkat ini atau izin mikrofon ditolak.';

  @override
  String get micPermissionTitle => 'Akses mikrofon';

  @override
  String get micPermissionRationale =>
      'Autoprompter menggunakan mikrofon untuk mengikuti suara Anda dan menggulir teks secara otomatis. Audio diproses di perangkat Anda untuk pengenalan suara — tidak direkam atau dibagikan.';

  @override
  String get continueLabel => 'Lanjutkan';

  @override
  String get micPermissionDenied =>
      'Izin mikrofon ditolak. Aktifkan di Pengaturan untuk menggunakan gulir suara.';

  @override
  String get openSettings => 'Buka pengaturan';

  @override
  String readingStatsLabel(int count, String time) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kata',
    );
    return '$_temp0 · ~$time';
  }
}
