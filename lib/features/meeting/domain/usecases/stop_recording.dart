import '../repositories/recorder_repository.dart';

class StopRecording {
  final RecorderRepository repository;

  const StopRecording(this.repository);

  Future<String> call() {
    return repository.stopRecording();
  }
}
