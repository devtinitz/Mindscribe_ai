import '../repositories/recorder_repository.dart';

class StartRecording {
  final RecorderRepository repository;

  const StartRecording(this.repository);

  Future<void> call() {
    return repository.startRecording();
  }
}
