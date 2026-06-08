// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'Autoprompter';

  @override
  String get searchPromptsHint => 'البحث في الموجّهات…';

  @override
  String get closeSearch => 'إغلاق البحث';

  @override
  String get search => 'بحث';

  @override
  String get sortTooltip => 'ترتيب';

  @override
  String get menuTooltip => 'القائمة';

  @override
  String get importMarkdown => 'استيراد Markdown…';

  @override
  String get backupData => 'نسخ احتياطي للبيانات…';

  @override
  String get restoreBackup => 'استعادة نسخة احتياطية…';

  @override
  String get settings => 'الإعدادات';

  @override
  String get newPrompt => 'موجّه جديد';

  @override
  String get moreActions => 'إجراءات أخرى';

  @override
  String get openTeleprompter => 'فتح التيليبرومبتر';

  @override
  String get untitled => 'بدون عنوان';

  @override
  String get edit => 'تعديل';

  @override
  String get duplicate => 'تكرار';

  @override
  String get shareMd => 'مشاركة (.md)';

  @override
  String get delete => 'حذف';

  @override
  String get cancel => 'إلغاء';

  @override
  String get deletePromptTitle => 'حذف الموجّه؟';

  @override
  String deletePromptMessage(String title) {
    return 'هل تريد حذف «$title»؟ لا يمكن التراجع عن هذا الإجراء.';
  }

  @override
  String get promptDuplicated => 'تم تكرار الموجّه';

  @override
  String get copySuffix => '(نسخة)';

  @override
  String shareFailed(String error) {
    return 'فشلت المشاركة: $error';
  }

  @override
  String importFailed(String error) {
    return 'فشل الاستيراد: $error';
  }

  @override
  String get noPromptsToBackup => 'لا توجد موجّهات للحفظ';

  @override
  String backupFailed(String error) {
    return 'فشل النسخ الاحتياطي: $error';
  }

  @override
  String promptsRestored(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تمت استعادة $count موجّه',
      one: 'تمت استعادة موجّه واحد',
    );
    return '$_temp0';
  }

  @override
  String restoreFailed(String error) {
    return 'فشلت الاستعادة: $error';
  }

  @override
  String get noContent => 'لا يوجد محتوى';

  @override
  String get noPromptsMatchFilters => 'لا توجد موجّهات مطابقة للفلاتر';

  @override
  String get clearFilters => 'مسح الفلاتر';

  @override
  String get noPrompts => 'لا توجد موجّهات';

  @override
  String get emptyStateMessage =>
      'انقر على «موجّه جديد» لإنشاء أول نص تقرؤه على التيليبرومبتر.';

  @override
  String get sortUpdatedDesc => 'المعدَّلة مؤخرًا';

  @override
  String get sortUpdatedAsc => 'الأقدم تعديلًا';

  @override
  String get sortTitleAsc => 'العنوان أ→ي';

  @override
  String get sortTitleDesc => 'العنوان ي→أ';

  @override
  String get sortCreatedDesc => 'المُنشأة مؤخرًا';

  @override
  String get editPrompt => 'تعديل الموجّه';

  @override
  String get markdownPreview => 'معاينة Markdown';

  @override
  String get hidePreview => 'إخفاء المعاينة';

  @override
  String get save => 'حفظ';

  @override
  String get promptSaved => 'تم حفظ الموجّه';

  @override
  String get titleHint => 'العنوان';

  @override
  String get voiceLanguage => 'لغة الصوت:';

  @override
  String get editorPlaceholder => 'اكتب هنا نص الموجّه…';

  @override
  String get addTagHint => 'إضافة وسم…';

  @override
  String get emptyMarkdownPreview => '_(فارغ)_';

  @override
  String get appearance => 'المظهر';

  @override
  String get theme => 'السمة';

  @override
  String get themeSystem => 'النظام';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get themeSystemSubtitle => 'اتّباع النظام';

  @override
  String get teleprompterDefaults => 'التيليبرومبتر (القيم الافتراضية)';

  @override
  String get textSize => 'حجم النص';

  @override
  String get autoscrollSpeed => 'سرعة التمرير التلقائي';

  @override
  String get readingLinePosition => 'موضع سطر القراءة';

  @override
  String get decreaseText => 'تصغير النص';

  @override
  String get increaseText => 'تكبير النص';

  @override
  String get restart => 'إعادة البدء';

  @override
  String get readingSettings => 'إعدادات القراءة';

  @override
  String get mirrorHorizontal => 'انعكاس أفقي';

  @override
  String get mirrorHorizontalSubtitle => 'لزجاج التيليبرومبتر';

  @override
  String get mirrorVertical => 'انعكاس رأسي';

  @override
  String get emptyPromptMessage => 'هذا الموجّه فارغ. عدّله لإضافة نص.';

  @override
  String get stop => 'إيقاف';

  @override
  String get startReading => 'بدء القراءة';

  @override
  String get speechUnavailable =>
      'التعرّف على الكلام غير متاح على هذا الجهاز أو تم رفض إذن الميكروفون.';

  @override
  String readingStatsLabel(int count, String time) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count كلمة',
      one: 'كلمة واحدة',
    );
    return '$_temp0 · ~$time';
  }
}
