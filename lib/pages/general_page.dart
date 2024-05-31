import 'package:demo_vosk_application/widgets/vosk_widget.dart';
import 'package:flutter/material.dart';

class GeneralPage extends StatefulWidget {
  const GeneralPage({super.key});

  @override
  State<GeneralPage> createState() => _GeneralPageState();
}

class _GeneralPageState extends State<GeneralPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Главная страница"),
      ),
      body: VoskFlutterDemo(),
    );
  }
}
