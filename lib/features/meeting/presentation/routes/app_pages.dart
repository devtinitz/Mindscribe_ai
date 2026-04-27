import 'package:get/get.dart';

import '../bindings/meeting_binding.dart';
import '../pages/login_page.dart';
import '../pages/register_page.dart';
import '../pages/two_factor_page.dart';
import '../pages/dashboard_page.dart';
import '../pages/meeting_detail_page.dart';
import '../pages/meetings_page.dart';
import '../pages/recording_page.dart';
import 'app_routes.dart';

abstract class AppPages {
  static final pages = <GetPage<dynamic>>[
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      binding: MeetingBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterPage(),
      binding: MeetingBinding(),
    ),
    GetPage(
      name: AppRoutes.twoFactor,
      page: () => const TwoFactorPage(),
      binding: MeetingBinding(),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardPage(),
      binding: MeetingBinding(),
    ),
    GetPage(
      name: AppRoutes.recorder,
      page: () => const RecordingPage(),
      binding: MeetingBinding(),
    ),
    GetPage(
      name: AppRoutes.meetings,
      page: () => const MeetingsPage(),
      binding: MeetingBinding(),
    ),
    GetPage(
      name: AppRoutes.meetingDetail,
      page: () => const MeetingDetailPage(),
      binding: MeetingBinding(),
    ),
  ];
}