
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:kwon_voice_recorder/KwonRoutePage.dart';
import 'package:kwon_voice_recorder/common/Scheme.dart';
import 'package:kwon_voice_recorder/common/utils/Log.dart';
import 'package:kwon_voice_recorder/common/utils/PermissionUtil.dart';
import 'package:kwon_voice_recorder/data/db/SharedDb.dart';
import 'package:kwon_voice_recorder/injection/injection.dart';
import 'package:kwon_voice_recorder/presenter/theme/Themes.dart';
import 'package:kwon_voice_recorder/presenter/widgets/KwonBottomNavigationBar.dart';

Future<void> main() async {
  // MARK: - 플러터 엔진 상호작용 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // MARK: - 의존성 역전 셋팅
  await getItSetup();

  // MARK: - 프리로드
  await SharedDb().preloading();

  runApp(const KwonApp());
}

class KwonApp extends StatefulWidget {
  const KwonApp({super.key});

  @override
  State<KwonApp> createState() => _KwonAppState();
}

class _KwonAppState extends State<KwonApp> with WidgetsBindingObserver {
  // MARK: - 초기 설정
  @override
  void initState() {
    super.initState();

    Get.put(GlobalBottomMenuBarViewModel());

    WidgetsBinding.instance.addObserver(this);

    // 초기 시스템 테마 설정
    _updateThemeMode();

    // 권한 요청을 비동기적으로 시작
    _checkPermissions();
  }

  // 권한 확인 및 요청
  Future<void> _checkPermissions() async {
    final permissionUtil = PermissionUtil();
    final hasPermissions = await permissionUtil.requestAllPermissions();

    if (!hasPermissions) {
      // 권한이 없는 경우 사용자에게 알림
      Get.snackbar(
        '권한 필요',
        '녹음을 위해 마이크 권한이 필요합니다. 설정에서 권한을 허용해주세요.',
        duration: const Duration(seconds: 5),
        snackPosition: SnackPosition.BOTTOM,
        mainButton: TextButton(
          onPressed: () => permissionUtil.openAppSettings(),
          child: const Text('설정 열기'),
        ),
      );
    }
  }

  // MARK: - 앱 라이프사이클
  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      // 앱이 포그라운드로 전환될 때 호출
      Log.d('didChangeAppLifecycleState: resumed');
      // 테마 업데이트 (시스템 테마가 변경되었을 수 있음)
      _updateThemeMode();
    } else if (state == AppLifecycleState.paused) {
      // 앱이 백그라운드로 전환될 때 호출
      Log.d('didChangeAppLifecycleState: paused');
    } else if (state == AppLifecycleState.inactive) {
      // 앱이 중지될 때 호출
      Log.d('didChangeAppLifecycleState: inactive');
    } else if (state == AppLifecycleState.detached) {
      // 앱이 종료될 때 호출
      Log.d('didChangeAppLifecycleState: detached');
    }
  }

  // MARK: - 플랫폼 밝기 변경
  @override
  void didChangePlatformBrightness() {
    Log.d('didChangePlatformBrightness: ${WidgetsBinding.instance.window.platformBrightness}');
    _updateThemeMode();
    super.didChangePlatformBrightness();
  }

  // 시스템 테마 모드에 따라 앱 테마 업데이트
  void _updateThemeMode() {
    final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    KwonThemes().setThemeByBrightness(brightness);
    // UI 갱신을 위해 setState 호출
    if (mounted) setState(() {});
  }

  // MARK: - 앱 종료
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // MARK: - 앱 초기화
  static TransitionBuilder KwonInit({
    TransitionBuilder? builder,
  }) {
    return (BuildContext context, Widget? child) {
      if (builder != null) {
        return builder(context, FlutterEasyLoading(child: child));
      } else {
        return PopScope(
            canPop: true,
            onPopInvokedWithResult: (bool didPop, dynamic result) {
              Log.d('[KwonInit] onPopInvokedWithResult: $didPop, $result');
            },
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(1.0),
              ),
              child: FlutterEasyLoading(child: child),
            ));
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Kwon Voice Recorder',
      locale: const Locale('ko', 'KR'),
      fallbackLocale: const Locale('ko', 'KR'),
      builder: (context, child) {
        child = KwonInit()(context, child);

        child = Column(
          children: [
            Expanded(child: child),
            // 바텀 네비게이션 바 추가
            const KwonBottomNavigationBar(),
          ],
        );

        return child ?? const SizedBox.shrink();
      },
      popGesture: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: KwonThemes().primary),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      getPages: appRoutes,
      initialRoute: Scheme.RECORDING.path,
      themeMode: ThemeMode.system,
    );
  }
}

// MARK: - 라우트 관리
final List<GetPage> appRoutes = [
  // MARK: - 녹음 페이지
  KwonRoutePage.recordingPage(),

  // MARK: - 녹음 기록 페이지
  KwonRoutePage.historyPage(),

  // MARK: - 녹음 기록 재생 페이지
  KwonRoutePage.playHistoryPage(),
];
