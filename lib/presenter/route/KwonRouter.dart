

import 'dart:io';

import 'package:get/get.dart';
import 'package:kwon_voice_recorder/common/Scheme.dart';
import 'package:kwon_voice_recorder/common/utils/Log.dart';
import 'package:kwon_voice_recorder/presenter/widgets/KwonBottomNavigationBar.dart';

// MARK: - 라우터
class KwonRouter {
  // 메인에서 Double back  체크용 변수
  static DateTime? currentBackPressTime;

  // MARK: - 캐시 클리어
  static void clearCache(String? nextPath) {}

// MARK: - 페이지 이동
  static Future<bool> to({
    required Scheme scheme,
    Map<String, dynamic>? arguments,
    Map<String, String>? parameter,
  }) async {
    // 현재 페이지의 Scheme
    Scheme? currentScheme = RouterUtils.getCurrentScheme();

    Log.d('[KwonRouter.to] scheme=> $scheme\narguments=> $arguments\nparameter=> $parameter\ncurrentScheme=> $currentScheme');

    if (currentScheme == scheme) {
      // 현재 페이지와 이동하려는 페이지가 같은 경우
      Log.d("[KwonRouter.to] 현재 페이지와 이동하려는 페이지가 같습니다.\ncurrentScheme => $currentScheme\nscheme => $scheme");
      return false;
    }

    // 메인 스키마 목록
    List<Scheme> mainSchemeList = _getMainSchemeList();

    bool isChild = RouterUtils.isChildScheme(scheme);  // scheme이 자식인지 여부

    if (mainSchemeList.contains(scheme) && !isChild) {
      Log.d(
          "[KwonRouter.to] 전체 스택을 제거하고 메인 페이지로 이동합니다.\ncurrentScheme => $currentScheme\nscheme => $scheme");
      _offAllNamed(scheme.path, arguments: arguments, parameter: parameter);
      return true;
    }

    if (isChild) {
      Log.d("[KwonRouter.to] 자식 페이지로 이동합니다.\ncurrentScheme => $currentScheme\nscheme => $scheme");
      await _toNamed(scheme.path, arguments: arguments, parameter: parameter);
      return true;
    } else {
      Log.d("[KwonRouter.to] 자식 페이지가 아닙니다. 전체 스택을 제거하고 이동합니다.\ncurrentScheme => $currentScheme\nscheme => $scheme");
      _offAllNamed(scheme.path, arguments: arguments, parameter: parameter);
      return true;
    }

    return false;
  }

  // MARK: - route를 통해, to를 호출하는 함수
  static Future<void> routeTo({required String? route, String title = ''}) async {
    if (route == null) {
      return;
    }

    // route가 http 또는 https로 시작하는지 체크
    if (route.startsWith('http') || route.startsWith('https')) {
      toWebView(url: route, title: title);
      return;
    }

    // route예시 => /child_connect_request
    // route를 통해, Scheme을 가져온다.
    Scheme? scheme = RouterUtils.getScheme(route);
    if (scheme == null) {
      return;
    }

    // parameter를 가져온다.
    Uri uri = Uri.parse(route);
    Map<String, String> parameter = uri.queryParameters;

    Log.d("[PlantyRouter.routeTo] route => $route\nscheme => $scheme\nparameter => $parameter");

    await KwonRouter.to(scheme: scheme, parameter: parameter);
  }

  // MARK: - 뒤로가기 처리
  static Future<bool> back({bool isAllClear = false}) async {
    // 현재 라우트가 마지막인지 체크
    Log.d('[KwonRouter.back] DeepLink back\ncurrent=> ${Get.currentRoute}\nprevious=> ${Get.previousRoute}');

    // 현재 라우트가 녹음 재생 페이지인 경우, 히스토리 페이지로 이동
    if (Get.currentRoute == Scheme.PLAY_HISTORY.path) {
      Log.d('[KwonRouter.back] 녹음 재생 페이지에서 뒤로가기 -> 히스토리 페이지로 이동');
      await to(scheme: Scheme.HISTORY);
      return false;
    }

    if(isAllClear) {
      RouterUtils.dialogClose();
      RouterUtils.bottomSheetClose();
    } else {
      if(RouterUtils.dialogClose()) {
        Log.d("[KwonRouter.back] 다이얼로그를 닫습니다.");
        return false;
      }

      if(RouterUtils.bottomSheetClose()) {
        Log.d("[KwonRouter.back] 바텀시트를 닫습니다.");
        return false;
      }
    }

    Scheme? currentScheme = RouterUtils.getCurrentScheme();

    if (currentScheme == Scheme.RECORDING) {
      Log.d("[KwonRouter.back] 녹음 페이지에서 뒤로가기를 눌렀습니다.");
      // 현재 페이지가 홈 또는 로그인 경우
      if (currentBackPressTime == null ||
          currentBackPressTime!.difference(DateTime.now()).inSeconds.abs() >
              1) {
        currentBackPressTime = DateTime.now();
        Get.snackbar('앱 종료', '한번 더 누르면 종료됩니다.');
        return false;
      }
      // 앱 종료
      exit(0);
      return true;
    }

    if(RouterUtils.snackbarClose()) {
      Log.d("[KwonRouter.back] 스낵바를 닫습니다.");
      // return false;
    }

    List<Scheme> bottomSchemeList = RouterUtils.getBottomSchemeList();
    Scheme? previousScheme = RouterUtils.getPreviousScheme();
    if (previousScheme == null) {
      Log.d("[KwonRouter.back] 뒤로 이동할 페이지가 없습니다. 로그인 여부를 조회합니다.\ncurrentScheme => $currentScheme\npreviousScheme => $previousScheme");

      return false;
    }

    else if (bottomSchemeList.contains(currentScheme) &&
        currentScheme != Scheme.RECORDING) {
      Log.d("[KwonRouter.back] 바텀 네비게이션 페이지에서 뒤로 이동합니다. => 홈으로 이동\ncurrentScheme => $currentScheme\npreviousScheme => $previousScheme");

      _offAllNamed(Scheme.RECORDING.path);
      return false;
    }

    clearCache(null);
    Get.back();

    Log.d("[KwonRouter.back] 이전 페이지로 이동합니다. => moveScheme: ${RouterUtils.getCurrentScheme()}");
    return false;
  }

  // MARK: - 웹뷰
  static Future<void> toWebView({required String url, String title = '', }) async {
  }

  static Future _toNamed(String path,
      {Map<String, dynamic>? arguments, Map<String, String>? parameter}) async {
    clearCache(path);
    await Get.toNamed(path, arguments: arguments, parameters: parameter);
  }

  static Future _offNamed(String path,
      {Map<String, dynamic>? arguments, Map<String, String>? parameter}) async {
    clearCache(path);
    Get.offNamed(path, arguments: arguments, parameters: parameter);
  }

  static Future _offAllNamed(String path,
      {Map<String, dynamic>? arguments, Map<String, String>? parameter}) async {
    clearCache(path);
    Get.offAllNamed(path, arguments: arguments, parameters: parameter);
  }

  // MARK: - 메인 Scheme 조회
  static List<Scheme> _getMainSchemeList() {
    return [
      Scheme.RECORDING, // 녹음
      Scheme.HISTORY, // 녹음 기록
    ];
  }
}

// MARK: - 라우터 유틸
class RouterUtils {
  // MARK: - 특정 path의 Scheme 조회
  static Scheme? getScheme(String path) {
    Uri getUri = Uri.parse(path);
    String uriPath = getUri.path;
    List<Scheme> allSchemeList = Scheme.values;

    for (Scheme scheme in allSchemeList) {
      if (uriPath == scheme.path) {
        return scheme;
      }
    }

    return null;
  }

  // MARK: - 현재 내 라우트의 Scheme 조회
  static Scheme? getCurrentScheme() {
    return getScheme(Get.currentRoute);
  }

  // MARK: - 이전 페이지의 Scheme 조회
  static Scheme? getPreviousScheme() {
    return getScheme(Get.previousRoute);
  }

  // MARK: - 해당 scheme이 자식 scheme인지 확인
  static bool isChildScheme(Scheme scheme) {
    List<Scheme> childSchemeList = getChildSchemeList();
    for (Scheme childScheme in childSchemeList) {
      if (childScheme == scheme) {
        return true;
      }
    }
    return false;
  }

  // MARK: - 현재 내 페이지에서 이동 가능한 자식 Scheme 목록 조회
  static List<Scheme> getChildSchemeList() {
    Scheme? getCurrentSheme = getCurrentScheme();
    if (getCurrentSheme == null) {
      return [];
    }

    List<Scheme> allSchemeList = Scheme.values;
    List<Scheme> childRouteList = [];

    for (GetPage page in Get.routeTree.routes) {
      if (page.name.contains(getCurrentSheme.path)) {
        for (Scheme scheme in allSchemeList) {
          if (page.name.contains(scheme.path) && scheme != getCurrentSheme) {
            childRouteList.add(scheme);
          }
        }
      }
    }

    return childRouteList;
  }

  // MARK: - 바텀 네비게이션 Scheme 조회
  static List<Scheme> getBottomSchemeList() {
    List<BottomMenuType> allBottomMenuType = BottomMenuType.values;
    List<Scheme> result = [];

    for(BottomMenuType bottomMenuType in allBottomMenuType) {
      result.add(BottomMenuType.getScheme(bottomMenuType));
    }

    return result;
  }

  // MARK: - 바텀 스킴의 자식 Scheme 목록 조회
  // key: 바텀 스킴, value: 자식 스킴
  static Map<Scheme, List<Scheme>> getBottomSchemeChildList() {
    List<Scheme> bottomSchemeList = getBottomSchemeList();

    List<Scheme> allSchemeList = Scheme.values;
    Map<Scheme, List<Scheme>> result = {};

    for(Scheme bottomScheme in bottomSchemeList) {
      for (GetPage page in Get.routeTree.routes) {
        if (page.name.contains(bottomScheme.path)) {
          for (Scheme scheme in allSchemeList) {
            if (page.name.contains(scheme.path) && scheme != bottomScheme) {
              if(result[bottomScheme] == null) {
                result[bottomScheme] = [];
              }
              result[bottomScheme]!.add(scheme);
            }
          }
        }
      }
    }

    return result;
  }

  // MARK: - 해당 scheme이 바텀의 자식 scheme인지 확인하고 자식 scheme의 path를 반환
  static String? getBottomSchemeChild(Scheme scheme) {
    List<Scheme> bottomSchemeList = getBottomSchemeList();
    for (Scheme bottomScheme in bottomSchemeList) {
      if (bottomScheme == scheme) {
        return null;
      }
    }

    Map<Scheme, List<Scheme>> bottomSchemeChildList = getBottomSchemeChildList();
    for (Scheme bottomScheme in bottomSchemeChildList.keys) {
      for (Scheme childScheme in bottomSchemeChildList[bottomScheme]!) {
        if (childScheme == scheme) {
          return bottomScheme.path + scheme.path;
        }
      }
    }

    return null;
  }

  // MARK: - 다이얼로그 닫기
  static bool dialogClose() {
    if (Get.isDialogOpen == true) {
      Get.back();
      return true;
    }
    return false;
  }

  // MARK: - 바텀시트 닫기
  static bool bottomSheetClose() {
    snackbarClose();
    if (Get.isBottomSheetOpen == true) {
      Get.back();
      return true;
    }
    return false;
  }

  // MARK: - 스낵바 닫기
  static bool snackbarClose() {
    if (Get.isSnackbarOpen == true) {
      Get.back();
      return true;
    }
    return false;
  }
}