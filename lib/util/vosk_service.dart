import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';

import 'package:demo_vosk_application/api/notifyText.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vosk_flutter/vosk_flutter.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class VoiceRecognition {
  static const modelName = 'vosk-model-small-ru-0.22';
  static const _sampleRate = 16000;

  static final vosk = VoskFlutterPlugin.instance();
  static final modelLoader = ModelLoader();
  static Model? model;
  static Recognizer? _recognizer;
  static SpeechService? speechService;

  static bool recognitionStarted = false;

  static void init(void Function(void Function()) setState, String id) async {
    FlutterTts flutterTts = FlutterTts();
    await flutterTts.setLanguage("ru-RU");
    modelLoader
        .loadModelsList()
        .then((modelsList) =>
            modelsList.firstWhere((model) => model.name == modelName))
        .then((modelDescription) =>
            modelLoader.loadFromNetwork(modelDescription.url)) // load model
        .then((modelPath) => vosk.createModel(modelPath)) // create model object
        .then((vmodel) => setState(() => model = vmodel))
        .then((_) => vosk.createRecognizer(
            model: model!, sampleRate: _sampleRate)) // create recognizer
        .then((value) => _recognizer = value)
        .then((recognizer) {
      vosk
          .initSpeechService(_recognizer!) // init speech service
          .then((value) {
        print(value);
        setState(() => speechService = value);
      });
      var port = ReceivePort();
      IsolateNameServer.registerPortWithName(
          port.sendPort, "yourUniqueChannelName");
      port.listen((dynamic data) async {
        speechService!.start();
        WebSocketChannel.connect(
          Uri.parse(
              'ws://${DotEnv().get("BACKEND_ADDRESS")}/ws?telegramId=$id'),
        ).stream.listen((event) async {
          print(event);
          await flutterTts.speak(jsonDecode(event)["Content"]);
        });

        speechService!.onResult().listen((event) {
          print(event);
          dynamic data = jsonDecode(event);

          if (data["text"] != "") {
            print(data.toString());
            NotifyTextRequest.send(id, data["text"]);
          }
        });
      });
    });
  }

  static void start() {
    final sendPort =
        IsolateNameServer.lookupPortByName("yourUniqueChannelName");
    if (sendPort != null) {
      // The port might be null if the main isolate is not running.
      sendPort.send(['any', 'data', 'you', 'want']);
    }
  }
}
