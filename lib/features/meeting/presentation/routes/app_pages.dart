import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../bindings/meeting_binding.dart';
import '../pages/splash_page.dart';
import '../pages/login_page.dart';
import '../pages/register_page.dart';
import '../pages/two_factor_page.dart';
import '../pages/forgot_password_page.dart';
import '../pages/reset_password_page.dart';
import '../pages/dashboard_page.dart';
import '../pages/meeting_detail_page.dart';
import '../pages/meetings_page.dart';
import '../pages/recording_page.dart';
import '../pages/select_participants_page.dart';
import 'app_routes.dart';

abstract class AppPages {
  static final pages = <GetPage<dynamic>>[
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashPage(),
      binding: MeetingBinding(),
      transition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      binding: MeetingBinding(),
      transition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterPage(),
      binding: MeetingBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    ),
    GetPage(
      name: AppRoutes.twoFactor,
      page: () => const TwoFactorPage(),
      binding: MeetingBinding(),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordPage(),
      binding: MeetingBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    ),
    GetPage(
      name: AppRoutes.resetPassword,
      page: () => const ResetPasswordPage(),
      binding: MeetingBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardPage(),
      binding: MeetingBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    ),
    GetPage(
      name: AppRoutes.selectParticipants,
      page: () => const SelectParticipantsPage(),
      binding: MeetingBinding(),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    ),
    GetPage(
      name: AppRoutes.recorder,
      page: () => const RecordingPage(),
      binding: MeetingBinding(),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    ),
    GetPage(
      name: AppRoutes.meetings,
      page: () => const MeetingsPage(),
      binding: MeetingBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    ),
    GetPage(
      name: AppRoutes.meetingDetail,
      page: () => const MeetingDetailPage(),
      binding: MeetingBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    ),
  ];
}