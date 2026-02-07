import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class VoiceService {
  static final VoiceService _instance = VoiceService._internal();
  late stt.SpeechToText _speechToText;
  late FlutterTts _flutterTts;
  bool _isListening = false;
  String _recognizedText = '';

  factory VoiceService() {
    return _instance;
  }

  VoiceService._internal() {
    _speechToText = stt.SpeechToText();
    _flutterTts = FlutterTts();
    _initTts();
  }

  /// Initialize TTS settings
  Future<void> _initTts() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);
  }

  /// Initialize speech recognition
  Future<bool> initializeSpeechRecognition() async {
    if (!await _speechToText.initialize(
      onError: (error) => print('Error: $error'),
      onStatus: (status) => print('Status: $status'),
    )) {
      return false;
    }
    return true;
  }

  bool get isListening => _isListening;
  String get recognizedText => _recognizedText;

  /// Start listening for voice input
  Future<void> startListening() async {
    if (!_speechToText.isAvailable) {
      await initializeSpeechRecognition();
    }

    _isListening = true;
    _recognizedText = '';

    _speechToText.listen(
      onResult: (result) {
        _recognizedText = result.recognizedWords;
      },
    );
  }

  /// Stop listening
  Future<void> stopListening() async {
    _isListening = false;
    await _speechToText.stop();
  }

  /// Speak text using TTS
  Future<void> speak(String text) async {
    if (text.isNotEmpty) {
      await _flutterTts.speak(text);
    }
  }

  /// Stop speaking
  Future<void> stopSpeaking() async {
    await _flutterTts.stop();
  }
}
