import 'dart:async';

import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

import '../../domain/entities/meeting.dart';
import '../../domain/usecases/get_meetings.dart';
import '../../domain/usecases/start_recording.dart';
import '../../domain/usecases/stop_recording.dart';
import '../../domain/usecases/upload_meeting_audio.dart';
import '../routes/app_routes.dart';

class RecorderController extends GetxController {
  RecorderController({
    required StartRecording startRecording,
    required StopRecording stopRecording,
    required UploadMeetingAudio uploadMeetingAudio,
    required GetMeetings getMeetings,
  })  : _startRecording = startRecording,
        _stopRecording = stopRecording,
        _uploadMeetingAudio = uploadMeetingAudio,
        _getMeetings = getMeetings;

  final StartRecording _startRecording;
  final StopRecording _stopRecording;
  final UploadMeetingAudio _uploadMeetingAudio;
  final GetMeetings _getMeetings;

  // ── État enregistrement ───────────────────────────────────────────
  final isRecording = false.obs;
  final isUploading = false.obs;
  final status = 'Prêt'.obs;
  final recordedFilePath = RxnString();
  final uploadedMeeting = Rxn<Meeting>();
  final elapsedSeconds = 0.obs;
  Timer? _timer;

  // ── État lecteur audio (Phase 2) ──────────────────────────────────
  final hasRecorded = false.obs;
  final isPlaying = false.obs;
  final playbackPosition = Duration.zero.obs;
  final playbackDuration = Duration.zero.obs;

  final AudioPlayer _player = AudioPlayer();
  StreamSubscription? _positionSub;
  StreamSubscription? _durationSub;
  StreamSubscription? _playerStateSub;

  // ── Démarrer l'enregistrement ─────────────────────────────────────
  Future<void> startRecording() async {
    try {
      await _resetPlayer();
      hasRecorded.value = false;

      await _startRecording();
      isRecording.value = true;
      status.value = 'Enregistrement en cours...';
      elapsedSeconds.value = 0;
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        elapsedSeconds.value++;
      });
    } catch (e) {
      status.value = 'Erreur enregistrement: $e';
    }
  }

  // ── Arrêter → affiche le lecteur ──────────────────────────────────
  Future<void> stopRecording() async {
    try {
      final path = await _stopRecording();
      recordedFilePath.value = path;
      isRecording.value = false;
      _timer?.cancel();

      await _loadAudioForPlayback(path);
      hasRecorded.value = true;
      status.value = 'Enregistrement terminé';
    } catch (e) {
      isRecording.value = false;
      status.value = 'Erreur : $e';
      _timer?.cancel();
    }
  }

  // ── Lecteur audio ─────────────────────────────────────────────────
  Future<void> _loadAudioForPlayback(String path) async {
    try {
      await _player.setFilePath(path);

      _durationSub = _player.durationStream.listen((d) {
        if (d != null) playbackDuration.value = d;
      });

      _positionSub = _player.positionStream.listen((p) {
        playbackPosition.value = p;
      });

      _playerStateSub = _player.playerStateStream.listen((state) {
        isPlaying.value = state.playing;
        if (state.processingState == ProcessingState.completed) {
          isPlaying.value = false;
          _player.seek(Duration.zero);
        }
      });
    } catch (e) {
      status.value = 'Erreur lecteur: $e';
    }
  }

  void togglePlayback() {
    if (_player.playing) {
      _player.pause();
    } else {
      _player.play();
    }
  }

  Future<void> seekTo(Duration position) async {
    await _player.seek(position);
  }

  // ── Réenregistrer ─────────────────────────────────────────────────
  Future<void> retake() async {
    await _resetPlayer();
    hasRecorded.value = false;
    recordedFilePath.value = null;
    status.value = 'Prêt';
    elapsedSeconds.value = 0;
  }

  // ── Valider et envoyer ────────────────────────────────────────────
  Future<void> validateAndUpload() async {
    final path = recordedFilePath.value;
    if (path == null) return;
    await _resetPlayer();
    await _uploadRecording(path);
  }

  // ── Upload + redirection ──────────────────────────────────────────
  Future<void> _uploadRecording(String path) async {
    final title = await _buildAutoTitle();

    isUploading.value = true;
    status.value = 'Envoi en cours...';

    try {
      final meeting = await _uploadMeetingAudio(
        audioFilePath: path,
        title: title,
      );
      uploadedMeeting.value = meeting;
      status.value = 'Audio envoyé !';
      hasRecorded.value = false;

      Get.toNamed(AppRoutes.meetingDetail, arguments: meeting.id);
    } catch (e) {
      status.value = 'Erreur upload: $e';
    } finally {
      isUploading.value = false;
    }
  }

  Future<String> _buildAutoTitle() async {
    try {
      final currentMeetings = await _getMeetings();
      return 'Réunion ${currentMeetings.length + 1}';
    } catch (_) {
      return 'Réunion ${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  // ── Reset lecteur ─────────────────────────────────────────────────
  Future<void> _resetPlayer() async {
    await _player.stop();
    await _positionSub?.cancel();
    await _durationSub?.cancel();
    await _playerStateSub?.cancel();
    _positionSub = null;
    _durationSub = null;
    _playerStateSub = null;
    isPlaying.value = false;
    playbackPosition.value = Duration.zero;
    playbackDuration.value = Duration.zero;
  }

  // ── Annuler ───────────────────────────────────────────────────────
  void cancelRecording() {
    isRecording.value = false;
    status.value = 'Enregistrement annulé.';
    recordedFilePath.value = null;
    elapsedSeconds.value = 0;
    hasRecorded.value = false;
    _timer?.cancel();
  }

  @override
  void onClose() {
    _timer?.cancel();
    _resetPlayer();
    _player.dispose();
    super.onClose();
  }
}