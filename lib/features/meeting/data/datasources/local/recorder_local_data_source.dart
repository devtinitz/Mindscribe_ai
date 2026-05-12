import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

abstract class RecorderLocalDataSource {
  Future<bool> hasMicrophonePermission();
  Future<void> startRecording();
  Future<String> stopRecording();
}

class RecorderLocalDataSourceImpl implements RecorderLocalDataSource {
  RecorderLocalDataSourceImpl(this._recorder);

  final AudioRecorder _recorder;

  @override
  Future<bool> hasMicrophonePermission() async {
    if (kIsWeb) {
      return await _recorder.hasPermission();
    }
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  @override
  Future<void> startRecording() async {
    if (kIsWeb) {
      // Sur web, le navigateur affiche automatiquement la popup
      // de permission au premier appel de start()
      if (await _recorder.isRecording()) return;

      // opus/webm = seul format fiable sur Chrome, Firefox ET Safari
      const config = RecordConfig(
        encoder: AudioEncoder.opus,
        bitRate: 128000,
        sampleRate: 44100,
        numChannels: 1,
      );

      try {
        await _recorder.start(
          config,
          path: 'mindscribe_${DateTime.now().millisecondsSinceEpoch}.webm',
        );
      } catch (e) {
        throw Exception(
          'Microphone inaccessible. Vérifiez que vous avez autorisé '
          'l\'accès au micro dans votre navigateur.',
        );
      }
      return;
    }

    // ── Mobile (Android / iOS) ────────────────────────────────────
    final hasPermission = await hasMicrophonePermission();
    if (!hasPermission) {
      throw Exception('Permission microphone refusée.');
    }

    if (await _recorder.isRecording()) return;

    final dir = await getApplicationDocumentsDirectory();
    final path =
        '${dir.path}/mindscribe_${DateTime.now().millisecondsSinceEpoch}.m4a';

    const config = RecordConfig(
      encoder: AudioEncoder.aacLc,
      bitRate: 128000,
      sampleRate: 44100,
      numChannels: 1,
    );

    await _recorder.start(config, path: path);
  }

  @override
  Future<String> stopRecording() async {
    final path = await _recorder.stop();
    if (path == null || path.isEmpty) {
      throw Exception('Enregistrement échoué : aucun fichier généré.');
    }
    return path;
  }
}