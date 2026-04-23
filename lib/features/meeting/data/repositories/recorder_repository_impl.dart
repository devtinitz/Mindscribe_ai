import '../../domain/repositories/recorder_repository.dart';
import '../datasources/local/recorder_local_data_source.dart';

class RecorderRepositoryImpl implements RecorderRepository {
  const RecorderRepositoryImpl(this._localDataSource);

  final RecorderLocalDataSource _localDataSource;

  @override
  Future<bool> hasMicrophonePermission() {
    return _localDataSource.hasMicrophonePermission();
  }

  @override
  Future<void> startRecording() {
    return _localDataSource.startRecording();
  }

  @override
  Future<String> stopRecording() {
    return _localDataSource.stopRecording();
  }
}
