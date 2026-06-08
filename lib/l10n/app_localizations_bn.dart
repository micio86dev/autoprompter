// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appTitle => 'Autoprompter';

  @override
  String get searchPromptsHint => 'প্রম্পট খুঁজুন…';

  @override
  String get closeSearch => 'খোঁজ বন্ধ করুন';

  @override
  String get search => 'খুঁজুন';

  @override
  String get sortTooltip => 'সাজান';

  @override
  String get menuTooltip => 'মেনু';

  @override
  String get importMarkdown => 'Markdown ইমপোর্ট করুন…';

  @override
  String get backupData => 'ডেটা ব্যাকআপ করুন…';

  @override
  String get restoreBackup => 'ব্যাকআপ পুনরুদ্ধার করুন…';

  @override
  String get settings => 'সেটিংস';

  @override
  String get newPrompt => 'নতুন প্রম্পট';

  @override
  String get moreActions => 'আরও অ্যাকশন';

  @override
  String get openTeleprompter => 'টেলিপ্রম্পটার খুলুন';

  @override
  String get untitled => 'শিরোনামহীন';

  @override
  String get edit => 'সম্পাদনা';

  @override
  String get duplicate => 'নকল করুন';

  @override
  String get shareMd => 'শেয়ার করুন (.md)';

  @override
  String get delete => 'মুছুন';

  @override
  String get cancel => 'বাতিল';

  @override
  String get deletePromptTitle => 'প্রম্পট মুছবেন?';

  @override
  String deletePromptMessage(String title) {
    return 'আপনি কি \"$title\" মুছতে চান? এই কাজটি পূর্বাবস্থায় ফেরানো যাবে না।';
  }

  @override
  String get promptDuplicated => 'প্রম্পট নকল করা হয়েছে';

  @override
  String get copySuffix => '(অনুলিপি)';

  @override
  String shareFailed(String error) {
    return 'শেয়ার করা ব্যর্থ হয়েছে: $error';
  }

  @override
  String importFailed(String error) {
    return 'ইমপোর্ট ব্যর্থ হয়েছে: $error';
  }

  @override
  String get noPromptsToBackup => 'ব্যাকআপ করার মতো কোনো প্রম্পট নেই';

  @override
  String backupFailed(String error) {
    return 'ব্যাকআপ ব্যর্থ হয়েছে: $error';
  }

  @override
  String promptsRestored(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি প্রম্পট পুনরুদ্ধার করা হয়েছে',
      one: '1টি প্রম্পট পুনরুদ্ধার করা হয়েছে',
    );
    return '$_temp0';
  }

  @override
  String restoreFailed(String error) {
    return 'পুনরুদ্ধার ব্যর্থ হয়েছে: $error';
  }

  @override
  String get noContent => 'কোনো বিষয়বস্তু নেই';

  @override
  String get noPromptsMatchFilters => 'কোনো প্রম্পট ফিল্টারের সাথে মেলে না';

  @override
  String get clearFilters => 'ফিল্টার মুছুন';

  @override
  String get noPrompts => 'কোনো প্রম্পট নেই';

  @override
  String get emptyStateMessage =>
      'টেলিপ্রম্পটারে পড়ার জন্য আপনার প্রথম টেক্সট তৈরি করতে \"নতুন প্রম্পট\"-এ ট্যাপ করুন।';

  @override
  String get sortUpdatedDesc => 'সম্প্রতি সম্পাদিত';

  @override
  String get sortUpdatedAsc => 'সবচেয়ে আগে সম্পাদিত';

  @override
  String get sortTitleAsc => 'শিরোনাম A→Z';

  @override
  String get sortTitleDesc => 'শিরোনাম Z→A';

  @override
  String get sortCreatedDesc => 'সম্প্রতি তৈরি';

  @override
  String get editPrompt => 'প্রম্পট সম্পাদনা';

  @override
  String get markdownPreview => 'Markdown প্রিভিউ';

  @override
  String get hidePreview => 'প্রিভিউ লুকান';

  @override
  String get save => 'সংরক্ষণ';

  @override
  String get promptSaved => 'প্রম্পট সংরক্ষিত হয়েছে';

  @override
  String get titleHint => 'শিরোনাম';

  @override
  String get voiceLanguage => 'কণ্ঠস্বরের ভাষা:';

  @override
  String get editorPlaceholder => 'এখানে প্রম্পটের টেক্সট লিখুন…';

  @override
  String get addTagHint => 'ট্যাগ যোগ করুন…';

  @override
  String get emptyMarkdownPreview => '_(খালি)_';

  @override
  String get appearance => 'চেহারা';

  @override
  String get theme => 'থিম';

  @override
  String get themeSystem => 'সিস্টেম';

  @override
  String get themeLight => 'হালকা';

  @override
  String get themeDark => 'গাঢ়';

  @override
  String get themeSystemSubtitle => 'সিস্টেম অনুসরণ করুন';

  @override
  String get teleprompterDefaults => 'টেলিপ্রম্পটার (ডিফল্ট মান)';

  @override
  String get textSize => 'টেক্সটের আকার';

  @override
  String get autoscrollSpeed => 'অটো-স্ক্রোল গতি';

  @override
  String get readingLinePosition => 'পড়ার লাইনের অবস্থান';

  @override
  String get decreaseText => 'টেক্সট ছোট করুন';

  @override
  String get increaseText => 'টেক্সট বড় করুন';

  @override
  String get restart => 'আবার শুরু করুন';

  @override
  String get readingSettings => 'পড়ার সেটিংস';

  @override
  String get mirrorHorizontal => 'অনুভূমিক মিরর';

  @override
  String get mirrorHorizontalSubtitle => 'টেলিপ্রম্পটার গ্লাসের জন্য';

  @override
  String get mirrorVertical => 'উল্লম্ব মিরর';

  @override
  String get emptyPromptMessage =>
      'এই প্রম্পটটি খালি। টেক্সট যোগ করতে এটি সম্পাদনা করুন।';

  @override
  String get stop => 'থামান';

  @override
  String get startReading => 'পড়া শুরু করুন';

  @override
  String get speechUnavailable =>
      'এই ডিভাইসে ভয়েস শনাক্তকরণ উপলব্ধ নয় বা মাইক্রোফোনের অনুমতি প্রত্যাখ্যান করা হয়েছে।';

  @override
  String get micPermissionTitle => 'মাইক্রোফোন অ্যাক্সেস';

  @override
  String get micPermissionRationale =>
      'Autoprompter আপনার কণ্ঠস্বর অনুসরণ করতে এবং টেক্সট স্বয়ংক্রিয়ভাবে স্ক্রোল করতে মাইক্রোফোন ব্যবহার করে। অডিও ভয়েস শনাক্তকরণের জন্য আপনার ডিভাইসেই প্রক্রিয়া করা হয় — এটি রেকর্ড বা শেয়ার করা হয় না।';

  @override
  String get continueLabel => 'চালিয়ে যান';

  @override
  String get micPermissionDenied =>
      'মাইক্রোফোন অনুমতি প্রত্যাখ্যান করা হয়েছে। ভয়েস স্ক্রোলিং ব্যবহার করতে সেটিংসে এটি সক্ষম করুন।';

  @override
  String get openSettings => 'সেটিংস খুলুন';

  @override
  String readingStatsLabel(int count, String time) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি শব্দ',
      one: '1টি শব্দ',
    );
    return '$_temp0 · ~$time';
  }
}
