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
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  @override
  Future<void> startRecording() async {
    final hasPermission = await hasMicrophonePermission();
    if (!hasPermission) throw Exception('Permission microphone refusée');

    if (await _recorder.isRecording()) return;

    final config = const RecordConfig(
      encoder: AudioEncoder.aacLc,
      bitRate: 128000,
      sampleRate: 44100,
    );

    if (kIsWeb) {
      // Web still requires a path parameter in this package version.
      await _recorder.start(
        config,
        path: 'mindscribe_${DateTime.now().millisecondsSinceEpoch}.m4a',
      );
      return;
    }

    final dir = await getApplicationDocumentsDirectory();
    final path =
        '${dir.path}/mindscribe_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _recorder.start(config, path: path);
  }

  @override
  Future<String> stopRecording() async {
    final path = await _recorder.stop();
    if (path == null || path.isEmpty) {
      throw Exception('Enregistrement échoué : aucun fichier généré');
    }
    return path;
  }
}