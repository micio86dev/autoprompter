// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'Autoprompter';

  @override
  String get searchPromptsHint => 'प्रॉम्प्ट खोजें…';

  @override
  String get closeSearch => 'खोज बंद करें';

  @override
  String get search => 'खोजें';

  @override
  String get sortTooltip => 'क्रमबद्ध करें';

  @override
  String get menuTooltip => 'मेन्यू';

  @override
  String get importMarkdown => 'Markdown इंपोर्ट करें…';

  @override
  String get backupData => 'डेटा का बैकअप लें…';

  @override
  String get restoreBackup => 'बैकअप पुनर्स्थापित करें…';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get newPrompt => 'नया प्रॉम्प्ट';

  @override
  String get moreActions => 'अधिक क्रियाएँ';

  @override
  String get openTeleprompter => 'टेलीप्रॉम्प्टर खोलें';

  @override
  String get untitled => 'बिना शीर्षक';

  @override
  String get edit => 'संपादित करें';

  @override
  String get duplicate => 'डुप्लिकेट करें';

  @override
  String get shareMd => 'साझा करें (.md)';

  @override
  String get delete => 'हटाएँ';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get deletePromptTitle => 'प्रॉम्प्ट हटाएँ?';

  @override
  String deletePromptMessage(String title) {
    return 'क्या आप \"$title\" हटाना चाहते हैं? यह क्रिया पूर्ववत नहीं की जा सकती।';
  }

  @override
  String get promptDuplicated => 'प्रॉम्प्ट डुप्लिकेट हो गया';

  @override
  String get copySuffix => '(प्रतिलिपि)';

  @override
  String shareFailed(String error) {
    return 'साझा करना विफल रहा: $error';
  }

  @override
  String importFailed(String error) {
    return 'इंपोर्ट विफल रहा: $error';
  }

  @override
  String get noPromptsToBackup => 'बैकअप के लिए कोई प्रॉम्प्ट नहीं';

  @override
  String backupFailed(String error) {
    return 'बैकअप विफल रहा: $error';
  }

  @override
  String promptsRestored(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count प्रॉम्प्ट पुनर्स्थापित हुए',
      one: '1 प्रॉम्प्ट पुनर्स्थापित हुआ',
    );
    return '$_temp0';
  }

  @override
  String restoreFailed(String error) {
    return 'पुनर्स्थापना विफल रही: $error';
  }

  @override
  String get noContent => 'कोई सामग्री नहीं';

  @override
  String get noPromptsMatchFilters => 'कोई प्रॉम्प्ट फ़िल्टर से मेल नहीं खाता';

  @override
  String get clearFilters => 'फ़िल्टर साफ़ करें';

  @override
  String get noPrompts => 'कोई प्रॉम्प्ट नहीं';

  @override
  String get emptyStateMessage =>
      'टेलीप्रॉम्प्टर पर पढ़ने के लिए अपना पहला टेक्स्ट बनाने हेतु \"नया प्रॉम्प्ट\" पर टैप करें।';

  @override
  String get sortUpdatedDesc => 'हाल ही में संपादित';

  @override
  String get sortUpdatedAsc => 'सबसे पहले संपादित';

  @override
  String get sortTitleAsc => 'शीर्षक A→Z';

  @override
  String get sortTitleDesc => 'शीर्षक Z→A';

  @override
  String get sortCreatedDesc => 'हाल ही में बनाए गए';

  @override
  String get editPrompt => 'प्रॉम्प्ट संपादित करें';

  @override
  String get markdownPreview => 'Markdown पूर्वावलोकन';

  @override
  String get hidePreview => 'पूर्वावलोकन छिपाएँ';

  @override
  String get save => 'सहेजें';

  @override
  String get promptSaved => 'प्रॉम्प्ट सहेजा गया';

  @override
  String get titleHint => 'शीर्षक';

  @override
  String get voiceLanguage => 'आवाज़ की भाषा:';

  @override
  String get editorPlaceholder => 'यहाँ प्रॉम्प्ट का टेक्स्ट लिखें…';

  @override
  String get addTagHint => 'टैग जोड़ें…';

  @override
  String get emptyMarkdownPreview => '_(खाली)_';

  @override
  String get appearance => 'दिखावट';

  @override
  String get theme => 'थीम';

  @override
  String get themeSystem => 'सिस्टम';

  @override
  String get themeLight => 'हल्का';

  @override
  String get themeDark => 'गहरा';

  @override
  String get themeSystemSubtitle => 'सिस्टम का अनुसरण करें';

  @override
  String get teleprompterDefaults => 'टेलीप्रॉम्प्टर (डिफ़ॉल्ट मान)';

  @override
  String get textSize => 'टेक्स्ट का आकार';

  @override
  String get autoscrollSpeed => 'ऑटो-स्क्रॉल गति';

  @override
  String get readingLinePosition => 'पठन रेखा की स्थिति';

  @override
  String get decreaseText => 'टेक्स्ट छोटा करें';

  @override
  String get increaseText => 'टेक्स्ट बड़ा करें';

  @override
  String get restart => 'फिर से शुरू करें';

  @override
  String get readingSettings => 'पठन सेटिंग्स';

  @override
  String get mirrorHorizontal => 'क्षैतिज मिरर';

  @override
  String get mirrorHorizontalSubtitle => 'टेलीप्रॉम्प्टर ग्लास के लिए';

  @override
  String get mirrorVertical => 'लंबवत मिरर';

  @override
  String get emptyPromptMessage =>
      'यह प्रॉम्प्ट खाली है। टेक्स्ट जोड़ने के लिए इसे संपादित करें।';

  @override
  String get stop => 'रोकें';

  @override
  String get startReading => 'पठन शुरू करें';

  @override
  String get speechUnavailable =>
      'इस डिवाइस पर वाक् पहचान उपलब्ध नहीं है या माइक्रोफ़ोन की अनुमति अस्वीकृत है।';

  @override
  String get micPermissionTitle => 'माइक्रोफ़ोन एक्सेस';

  @override
  String get micPermissionRationale =>
      'Autoprompter आपकी आवाज़ का अनुसरण करने और टेक्स्ट को स्वचालित रूप से स्क्रॉल करने के लिए माइक्रोफ़ोन का उपयोग करता है। ऑडियो को वाक् पहचान के लिए आपके डिवाइस पर ही संसाधित किया जाता है — इसे रिकॉर्ड या साझा नहीं किया जाता।';

  @override
  String get continueLabel => 'जारी रखें';

  @override
  String get micPermissionDenied =>
      'माइक्रोफ़ोन अनुमति अस्वीकृत। वॉइस स्क्रॉलिंग उपयोग करने के लिए इसे सेटिंग्स में सक्षम करें।';

  @override
  String get openSettings => 'सेटिंग्स खोलें';

  @override
  String readingStatsLabel(int count, String time) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count शब्द',
      one: '1 शब्द',
    );
    return '$_temp0 · ~$time';
  }
}
