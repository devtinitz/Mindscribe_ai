abstract class RecorderRepository {
  Future<bool> hasMicrophonePermission();

  Future<void> startRecording();

  Future<String> stopRecording();
}
