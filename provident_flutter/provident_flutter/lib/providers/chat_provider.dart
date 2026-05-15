import 'package:flutter/widgets.dart';
import '../models/analysis_result.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<Map<String, String>>? reportCards;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.reportCards,
  });
}

class ChatProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  final TextEditingController textController = TextEditingController();
  final AnalysisResult? analysisResult;
  String currentLanguage = 'English'; // English, Hindi, Marathi
  bool showTellMeMoreChips = false;

  ChatProvider(this.analysisResult) {
    _initFirstMessage();
  }

  void refreshChat() {
    _messages.clear();
    _isTyping = false;
    showTellMeMoreChips = false;
    textController.clear();
    _initFirstMessage(isRefresh: true);
    notifyListeners();
  }

  void setLanguage(String lang) {
    if (currentLanguage != lang) {
      currentLanguage = lang;
      refreshChat();
    }
  }

  void _initFirstMessage({bool isRefresh = false}) {
    if (analysisResult == null) {
      _messages.add(ChatMessage(
          text: translate(
              'Hello! I am your specialized AI Dental Assistant. How can I help you today?'),
          isUser: false,
          timestamp: DateTime.now()));
      return;
    }

    String rec =
        analysisResult!.report['recommendations'] ?? 'Consult a dentist';
    if (currentLanguage == 'Hindi' && rec.length > 30) {
      rec = 'हमेशा अच्छे दंत स्वास्थ्य के लिए एक पेशेवर डेंटिस्ट से परामर्श लें और व्यक्तिगत सलाह प्राप्त करें।';
    } else if (currentLanguage == 'Marathi' && rec.length > 30) {
      rec = 'नेहमी चांगल्या दंत आरोग्यासाठी व्यावसायिक डेंटिस्टचा सल्ला घ्या आणि वैयक्तिक मार्गदर्शन मिळवा.';
    } else {
      rec = translate(rec);
    }

    List<Map<String, String>> cards = [
      {'title': translate('Alignment'), 'value': translate(analysisResult!.alignmentTip)},
      {'title': translate('Symmetry'), 'value': translate(analysisResult!.symmetryTip)},
      {'title': translate('Spacing'), 'value': translate(analysisResult!.spacingTip)},
      {'title': translate('Gum Health'), 'value': translate(analysisResult!.gumHealth)},
      {'title': translate('Cavity Detection'), 'value': translate(analysisResult!.cavityStatus)},
      {'title': translate('Staining'), 'value': translate(analysisResult!.stainingStatus)},
      {'title': translate('Gum Visibility'), 'value': translate(analysisResult!.gumVisibility)},
      {'title': translate('Recommendations'), 'value': rec},
    ];

    String msg = _getInitialMessage(isRefresh) +
        translate('Feel free to ask if you need more details on your analysis!');

    _messages.add(ChatMessage(
        text: msg,
        isUser: false,
        timestamp: DateTime.now(),
        reportCards: cards,
    ));
  }

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isTyping => _isTyping;

  String translate(String text) {
    if (text.isEmpty) return text;

    // Multilingual dictionary for static labels and backend metrics
    Map<String, Map<String, String>> dict = {
      'Alignment': {'Hindi': 'अलाइनमेंट', 'Marathi': 'अलाइनमेंट'},
      'Symmetry': {'Hindi': 'सममिति', 'Marathi': 'सममिती'},
      'Spacing': {'Hindi': 'स्पेसिंग', 'Marathi': 'स्पेसिंग'},
      'Gum Health': {'Hindi': 'मसूड़ों का स्वास्थ्य', 'Marathi': 'हिरड्यांचे आरोग्य'},
      'Cavity Detection': {'Hindi': 'कैविटी डिटेक्शन', 'Marathi': 'कॅव्हिटी डिटेक्शन'},
      'Staining': {'Hindi': 'दाग', 'Marathi': 'दाग'},
      'Gum Visibility': {'Hindi': 'मसूड़ों की दृश्यता', 'Marathi': 'हिरड्यांची दृश्यता'},
      'Recommendations': {'Hindi': 'सिफारिशें', 'Marathi': 'शिफारसी'},
      'Alignment:': {'Hindi': 'अलाइनमेंट:', 'Marathi': 'अलाइनमेंट:'},
      'Symmetry:': {'Hindi': 'सममिति:', 'Marathi': 'सममिती:'},
      'Spacing:': {'Hindi': 'स्पेसिंग:', 'Marathi': 'स्पेसिंग:'},
      'Gum Health:': {
        'Hindi': 'मसूड़ों का स्वास्थ्य:',
        'Marathi': 'हिरड्यांचे आरोग्य:'
      },
      'Cavity:': {'Hindi': 'कैविटी:', 'Marathi': 'कॅव्हिटी:'},
      'Staining:': {'Hindi': 'दाग:', 'Marathi': 'दाग:'},
      'Gum Visibility:': {
        'Hindi': 'मसूड़ों की दृश्यता:',
        'Marathi': 'हिरड्यांची दृश्यता:'
      },
      'Recommendations:': {'Hindi': 'सिफारिशें:', 'Marathi': 'शिफारसी:'},
      'Consult a dentist': {
        'Hindi': 'एक डेंटिस्ट से सलाह लें',
        'Marathi': 'डेंटिस्टचा सल्ला घ्या'
      },
      'Feel free to ask if you need more details on your analysis!': {
        'Hindi': 'यदि आपको अपने विश्लेषण पर अधिक विवरण चाहिए तो बेझिझक पूछें!',
        'Marathi':
            'आपल्या विश्लेषणाबद्दल अधिक माहिती हवी असल्यास मोकळेपणाने विचारा!'
      },
      'I am a specialized AI Dental Assistant and can only answer questions related to dental analysis, oral health, cavity detection, gum health, alignment, and report interpretation.':
          {
        'Hindi':
            'मैं एक विशेष एआई डेंटल असिस्टेंट हूँ और केवल डेंटल विश्लेषण, ओरल हेल्थ, कैविटी डिटेक्शन, मसूड़ों के स्वास्थ्य, अलाइनमेंट और रिपोर्ट से संबंधित सवालों के जवाब दे सकता हूँ।',
        'Marathi':
            'मी एक विशेष AI डेंटल असिस्टंट आहे आणि केवळ डेंटल विश्लेषण, ओरल हेल्थ, कॅव्हिटी डिटेक्शन, हिरड्यांचे आरोग्य, अलाइनमेंट आणि रिपोर्टशी संबंधित प्रश्नांची उत्तरे देऊ शकतो.'
      },
      'I can explain your dental analysis in more detail. Which part would you like to understand better?':
          {
        'Hindi':
            'मैं आपके दंत विश्लेषण को अधिक विस्तार से समझा सकता हूँ। आप किस भाग को बेहतर ढंग से समझना चाहेंगे?',
        'Marathi':
            'मी तुमचे डेंटल विश्लेषण अधिक तपशीलवार समजावून सांगू शकतो. तुम्हाला कोणता भाग अधिक चांगल्या प्रकारे समजून घ्यायला आवडेल?'
      },
      'Tell me more': {'Hindi': 'मुझे और बताएं', 'Marathi': 'मला आणखी सांगा'},
      'Explain Alignment': {
        'Hindi': 'अलाइनमेंट समझाएँ',
        'Marathi': 'अलाइनमेंट समजावून सांगा'
      },
      'Gum Health Tips': {
        'Hindi': 'मसूड़ों के स्वास्थ्य के सुझाव',
        'Marathi': 'हिरड्यांच्या आरोग्यासाठी टिप्स'
      },
      'Explain Symmetry': {
        'Hindi': 'सममिति समझाएँ',
        'Marathi': 'सममिती समजावून सांगा'
      },
      'Cavity Detection Help': {
        'Hindi': 'कैविटी डिटेक्शन मदद',
        'Marathi': 'कॅव्हिटी डिटेक्शन मदत'
      },
      'Prevention Advice': {
        'Hindi': 'रोकथाम की सलाह',
        'Marathi': 'प्रतिबंधात्मक सल्ला'
      },
      'Explain My Report': {
        'Hindi': 'मेरी रिपोर्ट समझाएँ',
        'Marathi': 'माझा रिपोर्ट समजावून सांगा'
      },
      'Oral Hygiene Tips': {
        'Hindi': 'ओरल हाइजीन टिप्स',
        'Marathi': 'ओरल हायजीन टिप्स'
      },
      'Should I Visit Dentist?': {
        'Hindi': 'क्या मुझे डेंटिस्ट के पास जाना चाहिए?',
        'Marathi': 'मी डेंटिस्टकडे जावे का?'
      },
      'Treatment Suggestions': {
        'Hindi': 'उपचार के सुझाव',
        'Marathi': 'उपचारासाठी सूचना'
      },
      'Improve Gum Health': {
        'Hindi': 'मसूड़ों का स्वास्थ्य सुधारें',
        'Marathi': 'हिरड्यांचे आरोग्य सुधारा'
      },
      'Hello! I am your specialized AI Dental Assistant. How can I help you today?':
          {
        'Hindi':
            'नमस्ते! मैं आपका विशेष एआई डेंटल असिस्टेंट हूँ। आज मैं आपकी कैसे मदद कर सकता हूँ?',
        'Marathi':
            'नमस्कार! मी तुमचा विशेष AI डेंटल असिस्टंट आहे. मी आज तुमची कशी मदत करू शकतो?'
      },
      // Exact matching for backend dynamic values
      'Slightly Irregular': {
        'Hindi': 'थोड़ा अनियमित',
        'Marathi': 'किंचित अनियमित'
      },
      'Irregular': {'Hindi': 'अनियमित', 'Marathi': 'अनियमित'},
      'Normal': {'Hindi': 'सामान्य', 'Marathi': 'सामान्य'},
      'Moderate': {'Hindi': 'मध्यम', 'Marathi': 'मध्यम'},
      'Symmetrical': {'Hindi': 'सममित', 'Marathi': 'सममित'},
      'Low': {'Hindi': 'कम', 'Marathi': 'कमी'},
      'Asymmetric': {'Hindi': 'असममित', 'Marathi': 'असममित'},
      'Healthy': {'Hindi': 'स्वस्थ', 'Marathi': 'निरोगी'},
      'Mild Inflammation': {'Hindi': 'हल्की सूजन', 'Marathi': 'सौम्य सूज'},
      'Severe Inflammation': {'Hindi': 'गंभीर सूजन', 'Marathi': 'गंभीर सूज'},
      'Not Detected': {'Hindi': 'नहीं मिला', 'Marathi': 'आढळले नाही'},
      'Detected': {'Hindi': 'पाया गया', 'Marathi': 'आढळले'},
      'Minimal': {'Hindi': 'न्यूनतम', 'Marathi': 'किमान'},
      'Significant': {'Hindi': 'महत्वपूर्ण', 'Marathi': 'लक्षणीय'},
      'Plaque': {'Hindi': 'प्लाक', 'Marathi': 'प्लाक'},
      'High': {'Hindi': 'अधिक', 'Marathi': 'जास्त'},
      'Clean': {'Hindi': 'साफ', 'Marathi': 'स्वच्छ'},
      'Mild': {'Hindi': 'हल्का', 'Marathi': 'सौम्य'},
      'Severe': {'Hindi': 'गंभीर', 'Marathi': 'गंभीर'},
    };

    if (currentLanguage == 'English') return text;

    // Exact match
    if (dict.containsKey(text) && dict[text]!.containsKey(currentLanguage)) {
      return dict[text]![currentLanguage]!;
    }

    // Sentence / Substring matching for dynamic text fallback if exact match fails
    String lowerText = text.toLowerCase();

    if (lowerText.contains('potential crowding') ||
        lowerText.contains('misalignment')) {
      return currentLanguage == 'Hindi'
          ? 'आपके वर्तमान स्कोर से दांतों में हल्की भीड़ या असंतुलन का संकेत मिलता है। एक ऑर्थोडॉन्टिक परामर्श या स्पष्ट एलाइनर्स पर विचार करें।'
          : 'तुमच्या सध्याच्या स्कोअरनुसार दातांमध्ये हलकी विसंगती किंवा गर्दी दिसून येते. ऑर्थोडॉन्टिक सल्ला किंवा क्लिअर अलाइनर्सचा विचार करा.';
    }
    if (lowerText.contains('slight shifting') ||
        lowerText.contains('occlusal check')) {
      return currentLanguage == 'Hindi'
          ? 'कम सममिति स्कोर अक्सर थोड़े बदलाव का संकेत देता है। संतुलित बाइट सुनिश्चित करने के लिए एक ऑक्लुसल जांच की सिफारिश की जाती है।'
          : 'कमी सममिती स्कोअर बऱ्याचदा थोडा बदल दर्शवितो. संतुलित बाइटची खात्री करण्यासाठी ऑक्लुसल तपासणीची शिफारस केली जाते.';
    }
    if (lowerText.contains('higher gum exposure') ||
        lowerText.contains('smile aesthetics')) {
      return currentLanguage == 'Hindi'
          ? 'अधिक मसूड़े दिखाई दे रहे हैं। कॉस्मेटिक दंत मूल्यांकन मुस्कान सौंदर्य का आकलन करने में मदद कर सकता है।'
          : 'जास्त हिरड्या दिसत आहेत. कॉस्मेटिक दंत मूल्यमापन हास्याचे सौंदर्य ठरविण्यास मदत करू शकते.';
    }

    if (lowerText.contains('irregular'))
      return currentLanguage == 'Hindi' ? 'अनियमित' : 'अनियमित';
    if (lowerText.contains('normal'))
      return currentLanguage == 'Hindi' ? 'सामान्य' : 'सामान्य';
    if (lowerText.contains('moderate'))
      return currentLanguage == 'Hindi' ? 'मध्यम' : 'मध्यम';
    if (lowerText.contains('symmetric'))
      return currentLanguage == 'Hindi' ? 'सममित' : 'सममित';
    if (lowerText.contains('health'))
      return currentLanguage == 'Hindi' ? 'स्वस्थ' : 'निरोगी';
    if (lowerText.contains('inflam'))
      return currentLanguage == 'Hindi' ? 'सूजन' : 'सूज';
    if (lowerText.contains('not detect'))
      return currentLanguage == 'Hindi' ? 'नहीं मिला' : 'आढळले नाही';
    if (lowerText.contains('detect'))
      return currentLanguage == 'Hindi' ? 'पाया गया' : 'आढळले';
    if (lowerText.contains('minim'))
      return currentLanguage == 'Hindi' ? 'न्यूनतम' : 'किमान';
    if (lowerText.contains('signific'))
      return currentLanguage == 'Hindi' ? 'महत्वपूर्ण' : 'लक्षणीय';
    if (lowerText.contains('clean'))
      return currentLanguage == 'Hindi' ? 'साफ' : 'स्वच्छ';
    if (lowerText.contains('mild'))
      return currentLanguage == 'Hindi' ? 'हल्का' : 'सौम्य';

    return text;
  }

  void triggerTellMeMore() {
    sendMessage(translate('Tell me more'), isHiddenUserMsg: true);
  }

  void sendMessage(String text, {bool isHiddenUserMsg = false}) {
    if (text.trim().isEmpty) return;

    showTellMeMoreChips = false;

    if (!isHiddenUserMsg) {
      _messages.add(ChatMessage(
          text: text.trim(), isUser: true, timestamp: DateTime.now()));
    }
    textController.clear();
    _isTyping = true;
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 1500), () {
      _isTyping = false;
      _handleBotResponse(text.trim().toLowerCase(), isHiddenUserMsg);
    });
  }

  void _handleBotResponse(String query, bool isHiddenUserMsg) {
    String response = "";

    // Restricted domain check
    List<String> keywords = [
      'tell me more',
      'align',
      'gum',
      'cavity',
      'symmetry',
      'stain',
      'plaque',
      'oral',
      'health',
      'tooth',
      'teeth',
      'dentist',
      'prevent',
      'report',
      'score',
      'advice',
      'clean',
      'brush',
      'अलाइनमेंट',
      'मसूड़ों',
      'सममिति',
      'कैविटी',
      'रोकथाम',
      'ओरल',
      'डेंटिस्ट',
      'रिपोर्ट',
      'उपचार',
      'मुझे और बताएं',
      'दाग',
      'हिरड्यांच्या',
      'हिरड्यांचे',
      'सममिती',
      'कॅव्हिटी',
      'प्रतिबंधात्मक',
      'हायजीन',
      'डेंटिस्टकडे',
      'मला आणखी सांगा',
      'उपचारासाठी'
    ];

    bool isRelated =
        keywords.any((k) => query.contains(k)) || _isActionQuery(query);

    if (!isRelated) {
      response = translate(
          'I am a specialized AI Dental Assistant and can only answer questions related to dental analysis, oral health, cavity detection, gum health, alignment, and report interpretation.');
    } else if (query.contains('tell me more') ||
        query.contains('मुझे और बताएं') ||
        query.contains('मला आणखी सांगा') ||
        query.contains('report') ||
        query.contains('रिपोर्ट')) {
      response = translate(
          'I can explain your dental analysis in more detail. Which part would you like to understand better?');
      showTellMeMoreChips = true;
    } else if (query.contains('align') || query.contains('अलाइनमेंट')) {
      response = _getAlignmentResponse(
          analysisResult?.alignmentTip.toLowerCase() ?? '');
    } else if (query.contains('gum') ||
        query.contains('मसूड़ों') ||
        query.contains('हिरड्यांच्या') ||
        query.contains('हिरड्यांचे')) {
      response = _getGumResponse(analysisResult?.gumHealth.toLowerCase() ?? '');
    } else if (query.contains('cavity') ||
        query.contains('कैविटी') ||
        query.contains('कॅव्हिटी')) {
      response =
          _getCavityResponse(analysisResult?.cavityStatus.toLowerCase() ?? '');
    } else if (query.contains('symmetry') ||
        query.contains('सममिति') ||
        query.contains('सममिती')) {
      response =
          _getSymmetryResponse(analysisResult?.symmetryTip.toLowerCase() ?? '');
    } else if (query.contains('stain') ||
        query.contains('plaque') ||
        query.contains('दाग')) {
      response =
          _getStainResponse(analysisResult?.stainingStatus.toLowerCase() ?? '');
    } else if (query.contains('prevent') ||
        query.contains('advice') ||
        query.contains('रोकथाम') ||
        query.contains('प्रतिबंधात्मक') ||
        query.contains('hygiene') ||
        query.contains('हायजीन')) {
      response = _getPreventionResponse();
    } else {
      response = _getDefaultResponse();
    }

    _messages.add(
        ChatMessage(text: response, isUser: false, timestamp: DateTime.now()));
    notifyListeners();
  }

  bool _isActionQuery(String query) {
    return true;
  }

  String _getInitialMessage(bool isRefresh) {
    if (currentLanguage == 'Hindi') {
      return isRefresh
          ? 'नमस्ते! यहाँ आपके ताज़ा विश्लेषण परिणाम हैं। 😊\n\n'
          : 'नमस्ते! यहाँ आपके विस्तृत विश्लेषण परिणाम हैं। 😊\n\n';
    } else if (currentLanguage == 'Marathi') {
      return isRefresh
          ? 'नमस्कार! येथे तुमचे ताजे विश्लेषण परिणाम आहेत. 😊\n\n'
          : 'नमस्कार! येथे तुमचे तपशीलवार विश्लेषण परिणाम आहेत. 😊\n\n';
    } else {
      return isRefresh
          ? 'Hello! Here are your refreshed dental analysis results. 😊\n\n'
          : 'Hello! Here are your detailed analysis results. 😊\n\n';
    }
  }

  String _getAlignmentResponse(String tip) {
    if (tip.contains('irregular') ||
        tip.contains('misaligned') ||
        tip.contains('crowd')) {
      if (currentLanguage == 'Hindi')
        return 'मैंने आपके स्कैन से देखा है कि आपके दांतों के अलाइनमेंट में कुछ अनियमितता हो सकती है। हल्की क्राउडिंग या गैप बहुत आम हैं। यदि यह आपको परेशान करता है, तो ब्रेसेस या क्लियर अलाइनर्स जैसे ऑर्थोडॉन्टिक उपचार एक बड़ा बदलाव ला सकते हैं। मैं एक ऑर्थोडॉन्टिस्ट से चर्चा करने की सलाह दूंगा।';
      if (currentLanguage == 'Marathi')
        return 'तुमच्या स्कॅनवरून मला असे लक्षात आले आहे की तुमच्या दातांच्या रचनेत थोडी अनियमितता असू शकते. किरकोळ गर्दी किंवा गॅप खूप सामान्य आहेत. जर त्याचा तुम्हाला त्रास होत असेल, तर ब्रेसेस किंवा क्लिअर अलाइनर्ससारखे ऑर्थोडॉन्टिक उपचार खूप फरक करू शकतात. मी ऑर्थोडॉन्टिस्टशी चर्चा करण्याची शिफारस करेन.';
      return 'I noticed from your scan that there might be some irregularity in your teeth alignment. Minor crowding or gaps are very common. If it bothers you or affects your bite, orthodontic treatments like clear aligners or braces can make a big difference. I recommend discussing it with an orthodontist.';
    } else {
      if (currentLanguage == 'Hindi')
        return 'स्कैन के आधार पर आपके दांतों का अलाइनमेंट काफी अच्छा दिख रहा है! अच्छे अलाइनमेंट से ब्रश करना और फ्लॉस करना बहुत आसान हो जाता है, जो कैविटीज़ और मसूड़ों की बीमारी को दूर रखने में मदद करता है। ऐसे ही अपना ख्याल रखें!';
      if (currentLanguage == 'Marathi')
        return 'स्कॅनच्या आधारावर तुमच्या दातांची रचना खूप छान दिसत आहे! योग्य रचनेमुळे ब्रश करणे आणि फ्लॉस करणे खूप सोपे होते, ज्यामुळे कॅव्हिटी आणि हिरड्यांचे आजार दूर राहण्यास मदत होते. असेच लक्ष ठेवा!';
      return 'Your teeth alignment looks quite good based the scan! Good alignment makes brushing and flossing much easier, which helps keep cavities and gum disease away. Keep up the great work!';
    }
  }

  String _getGumResponse(String gum) {
    if (gum.contains('mild') || gum.contains('inflammation')) {
      if (currentLanguage == 'Hindi')
        return 'आपका विश्लेषण मसूड़ों की सूजन के कुछ हल्के संकेत दिखाता है। यह अक्सर जिंजिवाइटिस का प्रारंभिक चरण होता है, जिसे पूरी तरह से ठीक किया जा सकता है! मैं दिन में दो बार धीरे से ब्रश करने, दांतों के बीच से प्लाक हटाने के लिए रोजाना फ्लॉस करने और एक पेशेवर सफाई शेड्यूल करने का सुझाव देता हूँ।';
      if (currentLanguage == 'Marathi')
        return 'तुमच्या विश्लेषणामध्ये हिरड्यांच्या सुजेची काही सौम्य लक्षणे दिसत आहेत. हे बऱ्याचदा जिंजिवाइटिसचे सुरुवातीचे टप्पे असतात, जे पूर्णपणे बरे होऊ शकतात! मी दिवसातून दोनदा हळूवारपणे ब्रश करणे, दातांमधील प्लाक काढण्यासाठी दररोज फ्लॉस करणे आणि व्यावसायिक क्लिनिंगची शिफारस करतो.';
      return 'Your analysis indicates some mild signs of gum inflammation. This is often the early stage of gingivitis, which is completely reversible! I suggest brushing gently twice a day, flossing daily to remove plaque between teeth, and scheduling a professional cleaning.';
    } else if (gum.contains('severe') ||
        gum.contains('disease') ||
        gum.contains('unhealthy')) {
      if (currentLanguage == 'Hindi')
        return 'स्कैन में ऐसे संकेत दिखाई देते हैं जो मसूड़ों की बीमारी का संकेत दे सकते हैं। स्वस्थ मसूड़े दृढ़ और गुलाबी होने चाहिए, बिना सूजन या खून बहने के। कृपया उचित मूल्यांकन और गहरी सफाई के लिए जल्द ही एक डेंटिस्ट से परामर्श लें।';
      if (currentLanguage == 'Marathi')
        return 'स्कॅनमध्ये अशी लक्षणे दिसत आहेत जी हिरड्यांच्या आजाराचे संकेत देऊ शकतात. निरोगी हिरड्या टणक आणि गुलाबी असायला हव्यात, सूज किंवा रक्तस्रावाशिवाय. कृपया योग्य तपासणी आणि डीप क्लिनिंगसाठी लवकरच एका डेंटिस्टचा सल्ला घ्या.';
      return 'The scan shows signs that could indicate gum disease. Healthy gums should be firm and pink, without swelling or bleeding. Please consult a dentist soon for a proper evaluation and deep cleaning to prevent further issues.';
    } else {
      if (currentLanguage == 'Hindi')
        return 'बड़ी खबर! आपके मसूड़े स्वस्थ दिख रहे हैं। स्वस्थ मसूड़े एक मजबूत मुस्कान की नींव हैं। इसे बनाए रखने के लिए, ब्रश करने, फ्लॉस करने और नियमित रूप से अपने डेंटिस्ट के पास जाने की अपनी दिनचर्या जारी रखें।';
      if (currentLanguage == 'Marathi')
        return 'आनंदाची बातमी! तुमच्या हिरड्या निरोगी दिसत आहेत. निरोगी हिरड्या एका मजबूत हास्याचा पाया आहेत. हे टिकवून ठेवण्यासाठी, ब्रश करणे, फ्लॉस करणे आणि नियमितपणे तुमच्या डेंटिस्टला भेटण्याची तुमची दिनचर्या चालू ठेवा.';
      return 'Great news! Your gums appear to be healthy. Healthy gums are the foundation of a strong smile. To maintain this, continue your daily routine of brushing, flossing, and visiting your dentist regularly.';
    }
  }

  String _getCavityResponse(String cavity) {
    if (cavity.contains('detected') || cavity.contains('yes')) {
      if (currentLanguage == 'Hindi')
        return 'मैंने आपके स्कैन से देखा है कि कैविटी के विकास के संकेत हैं। कैविटी तब होती है जब प्लाक का निर्माण दांत की सतह को नुकसान पहुंचाता है। मैं आगे की सड़न को रोकने के लिए जल्द ही एक डेंटिस्ट के पास फिलिंग के लिए जाने की सलाह देता हूँ। इस बीच, सुनिश्चित करें कि आप फ्लोराइड टूथपेस्ट से दिन में दो बार ब्रश कर रहे हैं।';
      if (currentLanguage == 'Marathi')
        return 'तुमच्या स्कॅनवरून मला कॅव्हिटी विकसित होत असल्याची चिन्हे दिसली आहेत. कॅव्हिटी तेव्हा होते जेव्हा प्लाक साचल्यामुळे दाताच्या पृष्ठभागाचे नुकसान होते. मी पुढील सडणे टाळण्यासाठी लवकरच फिलिंगसाठी डेंटिस्टकडे जाण्याचा जोरदार सल्ला देतो. तोपर्यंत, फ्लोराईड टूथपेस्टने दिवसातून दोनदा ब्रश करत असल्याची खात्री करा.';
      return 'I noticed from your scan that there are signs of cavity development. Cavities occur when plaque buildup damages the tooth surface. I strongly advise scheduling a visit with your dentist soon for a filling to prevent further decay. In the meantime, ensure you\'re brushing twice daily with fluoride toothpaste.';
    } else {
      if (currentLanguage == 'Hindi')
        return 'खुशखबरी! आपके स्कैन में कैविटी के कोई स्पष्ट संकेत नहीं दिख रहे हैं। अपने दांतों को स्वस्थ और कैविटी-मुक्त रखने के लिए, फ्लोराइड टूथपेस्ट से दिन में दो बार ब्रश करना, नियमित रूप से फ्लॉस करना और मीठे स्नैक्स को कम करना जारी रखें।';
      if (currentLanguage == 'Marathi')
        return 'आनंदाची बातमी! तुमच्या स्कॅनमध्ये कॅव्हिटीची कोणतीही स्पष्ट चिन्हे दिसत नाहीत. तुमचे दात निरोगी आणि कॅव्हिटी-मुक्त ठेवण्यासाठी, फ्लोराईड टूथपेस्टने दिवसातून दोनदा ब्रश करणे, नियमितपणे फ्लॉस करणे आणि गोड स्नॅक्स कमी खाणे सुरू ठेवा.';
      return 'Good news! Your scan doesn\'t show any obvious signs of cavities. To keep your teeth healthy and cavity-free, continue brushing twice daily with fluoride toothpaste, flossing regularly, and minimizing sugary snacks.';
    }
  }

  String _getSymmetryResponse(String sym) {
    if (sym.contains('low') ||
        sym.contains('moderate') ||
        sym.contains('asymmetric')) {
      if (currentLanguage == 'Hindi')
        return 'आपका सममिति स्कोर चेहरे या दांतों की थोड़ी विषमता का सुझाव देता है। कृपया याद रखें कि मामूली विषमता पूरी तरह से प्राकृतिक है और आपकी मुस्कान को एक अनूठा रूप देती है! यदि आप अचानक कोई बदलाव देखते हैं या बाइट की समस्या महसूस करते हैं, तो अपने डेंटिस्ट से एक बार बात करना अच्छा रहेगा।';
      if (currentLanguage == 'Marathi')
        return 'तुमचा सममिती स्कोअर चेहऱ्याची किंवा दातांची किंचित विषमता सूचित करतो. कृपया लक्षात ठेवा की किरकोळ विषमता पूर्णपणे नैसर्गिक आहे आणि ती तुमच्या हास्याला एक वेगळेपण देते! जर तुम्हाला अचानक बदल जाणवला किंवा चावताना त्रास होत असेल, तर डेंटिस्टशी एकदा बोलणे चांगले होईल.';
      return 'Your symmetry score suggests slight facial or dental asymmetry. Please remember that minor asymmetry is completely natural and gives your smile its unique character! If you notice sudden shifting or experience bite issues, a quick chat with your dentist would be a good idea.';
    } else {
      if (currentLanguage == 'Hindi')
        return 'आपकी मुस्कान शानदार सममिति दिखाती है! सममित मुस्कान दिखने में आकर्षक होती है और आमतौर पर एक अच्छी तरह से संतुलित बाइट का संकेत देती है। अपने दांतों का ऐसे ही बेहतरीन ख्याल रखें।';
      if (currentLanguage == 'Marathi')
        return 'तुमचे हास्य अप्रतिम सममिती दर्शवते! सममित हास्य सौंदर्यदृष्ट्या आकर्षक असते आणि साधारणपणे योग्य प्रकारे संतुलित बाइट दर्शवते. तुमच्या दातांची अशीच उत्तम काळजी घेत राहा.';
      return 'Your smile shows wonderful symmetry! Symmetrical smiles are aesthetically pleasing and usually indicate a well-balanced bite. Keep taking great care of your teeth.';
    }
  }

  String _getStainResponse(String stain) {
    if (stain.contains('significant') ||
        stain.contains('plaque') ||
        stain.contains('detected')) {
      if (currentLanguage == 'Hindi')
        return 'विश्लेषण में कुछ ध्यान देने योग्य सतह के दाग या प्लाक का निर्माण पाया गया है। यह बहुत आम है और अक्सर चाय, कॉफी या कुछ खाद्य पदार्थों के कारण होता है। आपके डेंटल क्लिनिक में एक पेशेवर स्केलिंग और पॉलिशिंग इसे आसानी से साफ कर सकती है और आपकी प्राकृतिक चमक वापस ला सकती है!';
      if (currentLanguage == 'Marathi')
        return 'विश्लेषणामध्ये पृष्ठभागावर काही लक्षणीय दाग किंवा प्लाक साचल्याचे आढळून आले आहे. हे खूप सामान्य आहे आणि अनेकदा चहा, कॉफी किंवा काही विशिष्ट पदार्थांमुळे होते. तुमच्या डेंटल क्लिनिकमधील व्यावसायिक स्केलिंग आणि पॉलिशिंग हे सहजपणे साफ करू शकते आणि तुमची नैसर्गिक चमक परत आणू शकते!';
      return 'The analysis picked up some noticeable surface staining or plaque buildup. This is very common and often caused by tea, coffee, or certain foods. A professional scaling and polishing at your dental clinic can easily clear this up and restore your natural brightness!';
    } else {
      if (currentLanguage == 'Hindi')
        return 'आपके दांत कम दाग के साथ काफी साफ दिखाई देते हैं। उन्हें चमकदार बनाए रखने के लिए, अपनी ओरल हाइजीन की दिनचर्या बनाए रखें और कॉफी या चाय जैसे गहरे रंग के पेय पीने के बाद पानी पीने पर विचार करें।';
      if (currentLanguage == 'Marathi')
        return 'कमी डागांसह तुमचे दात खूप स्वच्छ दिसत आहेत. त्यांना चमकदार ठेवण्यासाठी, तुमची ओरल हायजीनची दिनचर्या चालू ठेवा आणि कॉफी किंवा चहासारखी गडद रंगाची पेये प्यायल्यानंतर पाणी पिण्याचा विचार करा.';
      return 'Your teeth appear quite clean with minimal staining. To keep them looking bright, maintain your oral hygiene routine and consider drinking water after consuming dark beverages like coffee or tea.';
    }
  }

  String _getPreventionResponse() {
    if (currentLanguage == 'Hindi')
      return 'यहाँ मेरी सबसे अच्छी निवारक ओरल हेल्थ सलाह है:\n\n1. दिन में दो बार सॉफ्ट-ब्रिसल वाले ब्रश और फ्लोराइड टूथपेस्ट से ब्रश करें।\n2. जहाँ आपका ब्रश नहीं पहुँच सकता वहाँ साफ करने के लिए दिन में कम से कम एक बार फ्लॉस करें।\n3. खूब पानी पिएं और मीठे या अम्लीय खाद्य पदार्थों को कम करें।\n4. हर 3-4 महीने में अपना टूथब्रश बदलें।\n5. अपने डेंटिस्ट के चेकअप और क्लीनिंग को मिस न करें!';
    if (currentLanguage == 'Marathi')
      return 'येथे माझा सर्वोत्तम प्रतिबंधात्मक ओरल हेल्थ सल्ला आहे:\n\n1. मऊ-ब्रिसल असलेल्या ब्रशने आणि फ्लोराईड टूथपेस्टने दिवसातून दोनदा ब्रश करा.\n2. जिथे तुमचा ब्रश पोहोचू शकत नाही तिथे साफ करण्यासाठी दिवसातून किमान एकदा फ्लॉस करा.\n3. भरपूर पाणी प्या आणि गोड किंवा आम्लयुक्त पदार्थ कमी खा.\n4. दर 3-4 महिन्यांनी तुमचा टूथब्रश बदला.\n5. तुमच्या डेंटिस्टचे चेकअप आणि क्लिनिंग चुकवू नका!';
    return 'Here is my best preventive oral health advice:\n\n1. Brush twice daily with a soft-bristled brush and fluoride toothpaste.\n2. Floss at least once a day to reach where your brush cannot.\n3. Drink plenty of water and limit sugary or acidic foods.\n4. Change your toothbrush every 3-4 months.\n5. Don\'t skip your bi-annual dentist checkups and cleanings!';
  }

  String _getDefaultResponse() {
    if (currentLanguage == 'Hindi')
      return 'आपकी रिपोर्ट के आधार पर, मुझे लगता है कि व्यक्तिगत देखभाल और उपचार के लिए एक पेशेवर डेंटिस्ट से उचित नैदानिक परीक्षा के लिए परामर्श करना सबसे अच्छा है।';
    if (currentLanguage == 'Marathi')
      return 'तुमच्या रिपोर्टच्या आधारावर, मला असे वाटते की वैयक्तिक काळजी आणि उपचारांसाठी योग्य वैद्यकीय तपासणीसाठी व्यावसायिक डेंटिस्टचा सल्ला घेणे उत्तम राहील.';
    return 'Based on your overall report, maintaining good daily oral hygiene is essential. However, AI analysis is just a starting point. I highly recommend consulting a professional dentist for a thorough clinical examination to get personalized care and treatment.';
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }
}
