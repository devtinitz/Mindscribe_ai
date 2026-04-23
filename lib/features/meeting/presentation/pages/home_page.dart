import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'recording_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MindScribe AI'),
      ),
      body: const Center(
        child: Text('Bienvenue sur MindScribe AI 🎙️'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const RecordingPage()),
        child: const Icon(Icons.mic),
      ),
    );
  }
}