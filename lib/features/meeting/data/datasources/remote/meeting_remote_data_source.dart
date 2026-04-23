import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../models/meeting_model.dart';

abstract class MeetingRemoteDataSource {
  Future<MeetingModel> uploadMeetingAudio({
    required String audioFilePath,
    required String title,
  });

  Future<MeetingModel> getMeetingDetails(int meetingId);

  Future<List<MeetingModel>> getMeetings();

  Future<List<MeetingModel>> searchMeetings(String query);
}

class MeetingRemoteDataSourceImpl implements MeetingRemoteDataSource {
  const MeetingRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<MeetingModel> uploadMeetingAudio({
    required String audioFilePath,
    required String title,
  }) async {
    final fileName = audioFilePath.split(RegExp(r'[\\/]')).last;

    MultipartFile audioPart;
    if (kIsWeb && audioFilePath.startsWith('blob:')) {
      final blobResponse = await _dio.get<List<int>>(
        audioFilePath,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {'Authorization': null},
        ),
      );
      final bytes = blobResponse.data ?? <int>[];
      audioPart = MultipartFile.fromBytes(
        bytes,
        filename: fileName.isEmpty ? 'recording.webm' : fileName,
      );
    } else {
      audioPart = await MultipartFile.fromFile(
        audioFilePath,
        filename: fileName.isEmpty ? 'recording.m4a' : fileName,
      );
    }

    final formData = FormData.fromMap({
      'title': title,
      'audio': audioPart,
    });

    final response = await _dio.post<Map<String, dynamic>>(
      '/meetings/upload',
      data: formData,
    );

    return MeetingModel.fromJson(response.data ?? <String, dynamic>{});
  }

  @override
  Future<MeetingModel> getMeetingDetails(int meetingId) async {
    final response =
        await _dio.get<Map<String, dynamic>>('/meetings/$meetingId');
    return MeetingModel.fromJson(response.data ?? <String, dynamic>{});
  }

  @override
  Future<List<MeetingModel>> getMeetings() async {
    final response = await _dio.get<List<dynamic>>('/meetings');
    final list = response.data ?? <dynamic>[];
    return list
        .map((e) => MeetingModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<MeetingModel>> searchMeetings(String query) async {
    final response = await _dio.get<List<dynamic>>(
      '/meetings/search',
      queryParameters: {'q': query},
    );
    final list = response.data ?? <dynamic>[];
    return list
        .map((e) => MeetingModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
