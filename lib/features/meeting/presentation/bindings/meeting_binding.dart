import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:record/record.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/local/recorder_local_data_source.dart';
import '../../data/datasources/remote/auth_remote_data_source.dart';
import '../../data/datasources/remote/meeting_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/meeting_repository_impl.dart';
import '../../data/repositories/recorder_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/meeting_repository.dart';
import '../../domain/repositories/recorder_repository.dart';
import '../../domain/usecases/get_meeting_details.dart';
import '../../domain/usecases/get_meetings.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/logout_user.dart';
import '../../domain/usecases/search_meetings.dart';
import '../../domain/usecases/start_recording.dart';
import '../../domain/usecases/stop_recording.dart';
import '../../domain/usecases/upload_meeting_audio.dart';
import '../controllers/auth_controller.dart';
import '../controllers/meetings_controller.dart';
import '../controllers/recorder_controller.dart';

class MeetingBinding extends Bindings {
  /// Base URL selon la plateforme :
  /// - Web (Chrome)         → localhost (CORS géré par le navigateur)
  /// - Émulateur Android    → 10.0.2.2 (IP spéciale qui pointe vers le PC hôte)
  /// - Windows desktop      → localhost
  static String get _baseUrl {
    if (kIsWeb) return 'http://localhost:8000/api';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://192.168.1.27:8000/api';//ip du pc
    }
    return 'http://localhost:8000/api';
  }

  void _lazyPutIfAbsent<S>(S Function() builder) {
    if (!Get.isRegistered<S>()) {
      Get.lazyPut<S>(builder, fenix: true);
    }
  }

  @override
  void dependencies() {
    _lazyPutIfAbsent<Dio>(
      () => Dio(
        BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(minutes: 2),
          sendTimeout: const Duration(minutes: 2),
        ),
      ),
    );

    _lazyPutIfAbsent<AudioRecorder>(AudioRecorder.new);
    _lazyPutIfAbsent<SharedPreferences>(() => Get.find<SharedPreferences>());

    _lazyPutIfAbsent<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(
        dio: Get.find<Dio>(),
        prefs: Get.find<SharedPreferences>(),
      ),
    );
    _lazyPutIfAbsent<MeetingRemoteDataSource>(
      () => MeetingRemoteDataSourceImpl(Get.find<Dio>()),
    );
    _lazyPutIfAbsent<RecorderLocalDataSource>(
      () => RecorderLocalDataSourceImpl(Get.find<AudioRecorder>()),
    );

    _lazyPutIfAbsent<AuthRepository>(
      () => AuthRepositoryImpl(Get.find<AuthRemoteDataSource>()),
    );
    _lazyPutIfAbsent<MeetingRepository>(
      () => MeetingRepositoryImpl(Get.find<MeetingRemoteDataSource>()),
    );
    _lazyPutIfAbsent<RecorderRepository>(
      () => RecorderRepositoryImpl(Get.find<RecorderLocalDataSource>()),
    );

    _lazyPutIfAbsent<LoginUser>(() => LoginUser(Get.find<AuthRepository>()));
    _lazyPutIfAbsent<LogoutUser>(() => LogoutUser(Get.find<AuthRepository>()));
    _lazyPutIfAbsent<GetMeetings>(
      () => GetMeetings(Get.find<MeetingRepository>()),
    );
    _lazyPutIfAbsent<GetMeetingDetails>(
      () => GetMeetingDetails(Get.find<MeetingRepository>()),
    );
    _lazyPutIfAbsent<SearchMeetings>(
      () => SearchMeetings(Get.find<MeetingRepository>()),
    );
    _lazyPutIfAbsent<StartRecording>(
      () => StartRecording(Get.find<RecorderRepository>()),
    );
    _lazyPutIfAbsent<StopRecording>(
      () => StopRecording(Get.find<RecorderRepository>()),
    );
    _lazyPutIfAbsent<UploadMeetingAudio>(
      () => UploadMeetingAudio(Get.find<MeetingRepository>()),
    );

    _lazyPutIfAbsent<AuthController>(
      () => AuthController(Get.find<LoginUser>(), Get.find<LogoutUser>()),
    );
    _lazyPutIfAbsent<MeetingsController>(
      () => MeetingsController(
        getMeetings: Get.find<GetMeetings>(),
        getMeetingDetails: Get.find<GetMeetingDetails>(),
        searchMeetings: Get.find<SearchMeetings>(),
      ),
    );
    _lazyPutIfAbsent<RecorderController>(
      () => RecorderController(
        startRecording: Get.find<StartRecording>(),
        stopRecording: Get.find<StopRecording>(),
        uploadMeetingAudio: Get.find<UploadMeetingAudio>(),
        getMeetings: Get.find<GetMeetings>(),
      ),
    );
  }
}