import 'package:demo_vosk_application/util/vosk_service.dart';
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';

class VoskFlutterDemo extends StatefulWidget {
  const VoskFlutterDemo({Key? key}) : super(key: key);

  @override
  State<VoskFlutterDemo> createState() => VoskFlutterDemoState();
}

class VoskFlutterDemoState extends State<VoskFlutterDemo> {
  static const _textStyle = TextStyle(fontSize: 30, color: Colors.black);

  @override
  void initState() {
    super.initState();
  }

  String? tgId;
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (tgId == null) {
      return Container(
        child: AlertDialog(
          title: Text("Введите телеграм id"),
          content: TextField(
            controller: controller,
          ),
          actions: [
            TextButton(
                onPressed: () {
                  setState(() {
                    tgId = controller.text;
                  });
                  VoiceRecognition.init(setState, controller.text);
                },
                child: Text("ОК"))
          ],
        ),
      );
    } else if (VoiceRecognition.speechService == null) {
      return const Scaffold(
          body: Center(child: Text("Загрузка...", style: _textStyle)));
    } else {
      return _androidExample();
    }
  }

  Widget _androidExample() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: () async {
                  if (VoiceRecognition.recognitionStarted) {
                    VoiceRecognition.speechService!.stop();
                    Workmanager().cancelByUniqueName("1");
                  } else {
                    print(VoiceRecognition.speechService);
                    Workmanager().registerOneOffTask("1", "start");
                  }
                  setState(() => VoiceRecognition.recognitionStarted =
                      !VoiceRecognition.recognitionStarted);
                },
                child: Text(
                    VoiceRecognition.recognitionStarted ? "Стоп" : "Старт")),
          ],
        ),
      ),
    );
  }
}
