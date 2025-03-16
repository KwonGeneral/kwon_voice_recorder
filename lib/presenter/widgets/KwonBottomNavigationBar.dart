

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kwon_voice_recorder/common/Scheme.dart';
import 'package:kwon_voice_recorder/presenter/route/KwonRouter.dart';
import 'package:kwon_voice_recorder/presenter/style/TextStyles.dart';
import 'package:kwon_voice_recorder/presenter/theme/Themes.dart';

// MARK: - 바텀 네비게이션 바
class KwonBottomNavigationBar extends StatelessWidget {
  const KwonBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GlobalBottomMenuBarViewModel>(
      builder: (model) {
        if (!model.isShow) {
          return const SizedBox.shrink();
        }

        final items = _getBottomItems();

        return Material( // Material 위젯 추가
          child: Container(
            decoration: BoxDecoration(
              color: KwonThemes().backgroundSub,
              boxShadow: [
                BoxShadow(
                  color: KwonThemes().black10,
                  blurRadius: 5,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(
                    items.length,
                        (index) => _buildBottomNavigationItem(
                      index: index,
                      item: items[index],
                      isSelected: model.currentPageIndex == index,
                      onTap: () => model.onTapBottomSelect(index: index),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // 바텀 메뉴 아이템 생성
  List<KwonBottomMenuItem> _getBottomItems() {
    List<KwonBottomMenuItem> list = [];
    for (int i = 0; i < BottomMenuType.values.length; i++) {
      list.add(_getItem(BottomMenuType.values.elementAt(i)));
    }
    return list;
  }

  // 바텀 메뉴 아이템 설정
  KwonBottomMenuItem _getItem(BottomMenuType bottomMenuType) {
    return KwonBottomMenuItem(
      icon: BottomMenuType.getIcon(bottomMenuType),
      title: BottomMenuType.getTitle(bottomMenuType),
    );
  }

  // 바텀 네비게이션 아이템 위젯
  Widget _buildBottomNavigationItem({
    required int index,
    required KwonBottomMenuItem item,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded( // Expanded 추가
      child: InkWell(
        onTap: onTap,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        child: SizedBox(
          height: 60,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 아이콘
              Icon(
                item.icon,
                color: isSelected ? KwonThemes().primary : KwonThemes().black50,
                size: 24,
              ),
              const SizedBox(height: 4),
              // 텍스트
              Text(
                item.title,
                style: TextStyles.medium(
                  fontSize: 12,
                  color: isSelected ? KwonThemes().primary : KwonThemes().black50,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// MARK: - 바텀 네비게이션 타입
enum BottomMenuType {
  // 녹음
  RECORDING(
    value: 0,
  ),

  // 히스토리
  HISTORY(
    value: 1,
  );

  final int value;

  const BottomMenuType({required this.value,});

  static String getTitle(BottomMenuType type) {
    switch(type) {
      case RECORDING:
        return '녹음';
      case HISTORY:
        return '기록';
    }
  }

  static IconData getIcon(BottomMenuType type) {
    switch(type) {
      case RECORDING:
        return Icons.mic;
      case HISTORY:
        return Icons.history;
    }
  }

  static Scheme getScheme(BottomMenuType type) {
    switch(type) {
      case RECORDING:
        return Scheme.RECORDING;
      case HISTORY:
        return Scheme.HISTORY;
    }
  }
}

// MARK: - 바텀 네비게이션 아이템
class KwonBottomMenuItem {
  final Key? key;
  final IconData icon;
  final String title;

  KwonBottomMenuItem(
      {this.key,
        required this.icon,
        required this.title,
      });
}

// MARK: - 바텀 네비게이션 뷰모델
class GlobalBottomMenuBarViewModel extends GetxController {
  bool _isShow = true;
  bool get isShow => _isShow;
  BottomMenuType _currentPage = BottomMenuType.RECORDING;
  String _currentRoute = '';
  int get currentPageIndex => _currentPage.value;

  // MARK: - 현재 바텀 네비 스키마 가져오기
  Scheme getCurrentScheme() {
    return BottomMenuType.getScheme(_currentPage);
  }

  // MARK: - 바텀 네비게이션 Show, Hide 설정 (외부 허용)
  void setIsShow(bool isShowValue) {
    _isShow = isShowValue;
    update();
  }

  // MARK: - 라우트 변경 (외부 허용)
  void changeRoute({required String? route}) {
    if(route != null) {
      BottomMenuType? getBottomMenuType = _getBottomMenuTypeFromRoute(route: route);

      if(getBottomMenuType != null) {
        _currentRoute = route;

        if(_currentPage != getBottomMenuType) {
          _currentPage = getBottomMenuType;
        }
        update();
      }
    }
  }

  // MARK: - 라우트로부터 바텀 메뉴 타입 가져오기
  BottomMenuType? _getBottomMenuTypeFromRoute({required String route}) {
    for(BottomMenuType type in BottomMenuType.values) {
      if(route.contains(BottomMenuType.getScheme(type).path)) {
        return type;
      }
    }

    return null;
  }

  // MARK: - 사용자의 인터렉션으로 페이지 이동
  Future<void> onTapBottomSelect({required int index}) async {
    BottomMenuType? nextBottomMenuType;
    for(BottomMenuType type in BottomMenuType.values) {
      if (type.value == index) {
        nextBottomMenuType = type;
        break;
      }
    }

    if(nextBottomMenuType != null && nextBottomMenuType != _currentPage) {
      _currentPage = nextBottomMenuType;
      _currentRoute = BottomMenuType.getScheme(nextBottomMenuType).path;

      // 라우터를 통해 페이지 이동
      await KwonRouter.to(scheme: BottomMenuType.getScheme(nextBottomMenuType));
      update();
    }
  }
}