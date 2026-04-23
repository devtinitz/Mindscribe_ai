import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/entities/meeting.dart';
import '../../domain/entities/task.dart';
import '../../domain/usecases/get_meeting_details.dart';
import '../../domain/usecases/get_meetings.dart';
import '../../domain/usecases/search_meetings.dart';

class MeetingsController extends GetxController {
  final GetMeetings getMeetings;
  final GetMeetingDetails getMeetingDetails;
  final SearchMeetings searchMeetings;

  MeetingsController({
    required this.getMeetings,
    required this.getMeetingDetails,
    required this.searchMeetings,
  });

  var meetings = <Meeting>[].obs;
  var selectedMeeting = Rxn<Meeting>();
  var isLoading = false.obs;
  var isPolling = false.obs;
  final queryController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadMeetings();
  }

  // ── Charge toutes les réunions ────────────────────────────────────
  Future<void> loadMeetings() async {
    isLoading.value = true;
    try {
      final result = await getMeetings();
      meetings.assignAll(result);
    } catch (e) {
      // ignore
    } finally {
      isLoading.value = false;
    }
  }

  // ── Recherche ─────────────────────────────────────────────────────
  Future<void> search() async {
    isLoading.value = true;
    try {
      final result = await searchMeetings(queryController.text.trim());
      meetings.assignAll(result);
    } catch (e) {
      // ignore
    } finally {
      isLoading.value = false;
    }
  }

  // ── Charge le détail d'une réunion avec polling ───────────────────
  Future<void> loadMeetingDetail(int meetingId) async {
    isLoading.value = true;
    try {
      final meeting = await getMeetingDetails(meetingId);
      selectedMeeting.value = meeting;
      if (meeting.status != 'done' && meeting.status != 'failed') {
        _startPolling(meetingId);
      }
    } catch (e) {
      // ignore
    } finally {
      isLoading.value = false;
    }
  }

  // ── Polling toutes les 3 secondes ─────────────────────────────────
  void _startPolling(int meetingId) async {
    isPolling.value = true;
    while (isPolling.value) {
      await Future.delayed(const Duration(seconds: 3));
      try {
        final meeting = await getMeetingDetails(meetingId);
        selectedMeeting.value = meeting;
        if (meeting.status == 'done' || meeting.status == 'failed') {
          isPolling.value = false;
        }
      } catch (e) {
        isPolling.value = false;
      }
    }
  }

  // ── Toggle tâche ──────────────────────────────────────────────────
  void toggleTaskDone(int index) {
    final meeting = selectedMeeting.value;
    if (meeting == null) return;
    final tasks = List.of(meeting.tasks);
    final task = tasks[index];
    tasks[index] = Task(
      id: task.id,
      assignee: task.assignee,
      action: task.action,
      isDone: !task.isDone,
    );
    selectedMeeting.value = Meeting(
      id: meeting.id,
      title: meeting.title,
      audioPath: meeting.audioPath,
      transcription: meeting.transcription,
      summary: meeting.summary,
      decisions: meeting.decisions,
      tasks: tasks,
      createdAt: meeting.createdAt,
      status: meeting.status,
    );
  }

  @override
  void onClose() {
    isPolling.value = false;
    queryController.dispose();
    super.onClose();
  }
}