

import 'package:get/get.dart';
import 'package:kwon_voice_recorder/common/Scheme.dart';
import 'package:kwon_voice_recorder/presenter/pages/HistoryPage.dart';
import 'package:kwon_voice_recorder/presenter/pages/PlayHistoryPage.dart';
import 'package:kwon_voice_recorder/presenter/pages/RecordingPage.dart';

// MARK: - 라우트 페이지 정의
class KwonRoutePage {
  static const Transition transition = Transition.noTransition;
  static const Duration transitionDuration = Duration(milliseconds: 0);

  // MARK: - 녹음 페이지
  static GetPage recordingPage() {
    return GetPage(
      name: Scheme.RECORDING.path,
      page: () => RecordingPage(),
      // 중복 페이지 방지
      preventDuplicates: true,
      // 페이지 상태 유지
      maintainState: true,
      transition: transition,
      transitionDuration: transitionDuration,
      children: [],
      middlewares: [],
    );
  }

  // MARK: - 녹음 기록 페이지
  static GetPage historyPage() {
    return GetPage(
      name: Scheme.HISTORY.path,
      page: () => HistoryPage(),
      // 중복 페이지 방지
      preventDuplicates: true,
      // 페이지 상태 유지
      maintainState: true,
      transition: transition,
      transitionDuration: transitionDuration,
      children: [
        playHistoryPage(),
      ],
      middlewares: [],
    );
  }

  // MARK: - 녹음 기록 재생 페이지
  static GetPage playHistoryPage() {
    return GetPage(
      name: Scheme.PLAY_HISTORY.path,
      page: () => PlayHistoryPage(),
      // 중복 페이지 방지
      preventDuplicates: true,
      // 페이지 상태 유지
      maintainState: true,
      transition: transition,
      transitionDuration: transitionDuration,
      children: [],
      middlewares: [],
    );
  }
}