

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kwon_voice_recorder/common/utils/ErrorUtil.dart';
import 'package:kwon_voice_recorder/domain/repository/RecordRepositoryImpl.dart';
import 'package:kwon_voice_recorder/injection/injection.dart';
import 'package:kwon_voice_recorder/presenter/BaseViewModel.dart';
import 'dart:async';
import 'package:get_it/get_it.dart';
import 'package:kwon_voice_recorder/common/Scheme.dart';
import 'package:kwon_voice_recorder/common/utils/Log.dart';
import 'package:kwon_voice_recorder/domain/model/RecordData.dart';
import 'package:kwon_voice_recorder/domain/usecase/DeleteHistoryUseCase.dart';
import 'package:kwon_voice_recorder/domain/usecase/GetHistoryUseCase.dart';
import 'package:kwon_voice_recorder/domain/usecase/PlayHistoryUseCase.dart';
import 'package:kwon_voice_recorder/domain/usecase/UpdateHistoryNameUseCase.dart';
import 'package:kwon_voice_recorder/presenter/route/KwonRouter.dart';
import 'package:kwon_voice_recorder/presenter/style/TextStyles.dart';
import 'package:kwon_voice_recorder/presenter/theme/Themes.dart';

// MARK: - 녹음 기록 페이지
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {

  @override
  void initState() {
    super.initState();

    // 등록된 UseCase 확인을 위한 테스트 코드
    try {
      final getHistoryUseCase = getIt<GetHistoryUseCase>();
      Log.d('[HistoryPage] GetHistoryUseCase를 성공적으로 가져왔습니다.');
    } catch (e) {
      Log.e('GetHistoryUseCase를 가져오는 중 오류 발생: $e', StackTrace.current);

      // UseCase가 등록되어 있지 않은 경우 수동 등록 시도
      try {
        final repo = getIt<RecordRepositoryImpl>();
        getIt.registerSingleton<GetHistoryUseCase>(GetHistoryUseCase(repo));
        Log.d('[HistoryPage] GetHistoryUseCase를 수동으로 등록했습니다.');
      } catch (e) {
        Log.e('GetHistoryUseCase 수동 등록 중 오류 발생: $e', StackTrace.current);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HistoryPageViewModel>(
      init: HistoryPageViewModel(),
      initState: (state) {
        // 페이지가 초기화될 때 데이터 로드 명시적 호출
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final model = Get.find<HistoryPageViewModel>();
          model.dataUpdate();
        });
      },
      builder: (model) {
        Log.d('[HistoryPage] 빌드: recordList 개수 = ${model.recordList.length}');

        return Scaffold(
          appBar: AppBar(
            title: Text(
              '녹음 기록',
              style: TextStyles.bold(fontSize: 18, color: KwonThemes().surface01),
            ),
            centerTitle: true,
            elevation: 0,
            backgroundColor: KwonThemes().backgroundSub,
          ),
          body: SafeArea(
            child: Container(
              color: KwonThemes().background,
              child: Column(
                children: [
                  // 검색창
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      onChanged: (value) => model.setSearchText(value),
                      decoration: InputDecoration(
                        hintText: '녹음 이름으로 검색',
                        hintStyle: TextStyles.regular(
                          fontSize: 14,
                          color: KwonThemes().black50,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: KwonThemes().black50,
                        ),
                        filled: true,
                        fillColor: KwonThemes().backgroundSub,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                      ),
                    ),
                  ),

                  // 목록 타이틀
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '모든 녹음',
                          style: TextStyles.bold(
                            fontSize: 16,
                            color: KwonThemes().surface01,
                          ),
                        ),
                        Text(
                          '${model.recordList.length}개',
                          style: TextStyles.medium(
                            fontSize: 14,
                            color: KwonThemes().black50,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 로딩 중인 경우
                  if (model.isLoading)
                    const Expanded(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  // 오류가 있는 경우
                  else if (model.hasError)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              model.errorMessage,
                              style: TextStyles.medium(
                                fontSize: 16,
                                color: KwonThemes().black70,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () => model.dataUpdate(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: KwonThemes().primary,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: Text(
                                '다시 시도',
                                style: TextStyles.medium(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  // 목록이 비어있을 때
                  else if (model.recordList.isEmpty)
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.mic_off,
                                size: 64,
                                color: KwonThemes().black30,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '녹음 기록이 없습니다',
                                style: TextStyles.medium(
                                  fontSize: 16,
                                  color: KwonThemes().black50,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '녹음 페이지에서 새로운 녹음을 시작해보세요',
                                style: TextStyles.regular(
                                  fontSize: 14,
                                  color: KwonThemes().black40,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => model.dataUpdate(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: KwonThemes().primary,
                                ),
                                child: Text(
                                  '새로고침',
                                  style: TextStyles.medium(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    // 녹음 목록
                    else
                      Expanded(
                        child: ListView.builder(
                          itemCount: model.recordList.length,
                          itemBuilder: (context, index) {
                            final record = model.recordList[index];
                            Log.d('[HistoryPage] 아이템 빌드 #$index: ${record.fileName}');
                            return _buildRecordItem(context, record, model);
                          },
                        ),
                      ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 빈 상태 위젯
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.mic_off,
            size: 64,
            color: KwonThemes().black30,
          ),
          const SizedBox(height: 16),
          Text(
            '녹음 기록이 없습니다',
            style: TextStyles.medium(
              fontSize: 16,
              color: KwonThemes().black50,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '녹음 페이지에서 새로운 녹음을 시작해보세요',
            style: TextStyles.regular(
              fontSize: 14,
              color: KwonThemes().black40,
            ),
          ),
        ],
      ),
    );
  }

  // 녹음 항목 위젯
  Widget _buildRecordItem(
      BuildContext context,
      RecordData record,
      HistoryPageViewModel model
      ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => model.navigateToPlayPage(record.id),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 파일명과 편집 버튼
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      record.fileName,
                      style: TextStyles.bold(
                        fontSize: 16,
                        color: KwonThemes().surface01,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.edit,
                      color: KwonThemes().black50,
                      size: 20,
                    ),
                    onPressed: () => _showRenameDialog(
                        context,
                        record,
                        model
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // 녹음 정보 (날짜, 시간, 길이)
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: KwonThemes().black50,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    record.formattedDate,
                    style: TextStyles.regular(
                      fontSize: 12,
                      color: KwonThemes().black60,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: KwonThemes().black50,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    record.formattedTime,
                    style: TextStyles.regular(
                      fontSize: 12,
                      color: KwonThemes().black60,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              // 재생 시간 및 파일 크기
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.timer,
                        size: 16,
                        color: KwonThemes().primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        record.formattedDuration,
                        style: TextStyles.medium(
                          fontSize: 14,
                          color: KwonThemes().black70,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        record.formattedFileSize,
                        style: TextStyles.regular(
                          fontSize: 12,
                          color: KwonThemes().black50,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // 삭제 버튼
                      InkWell(
                        onTap: () => _showDeleteConfirmation(
                            context,
                            record.id,
                            model
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(
                            Icons.delete_outline,
                            size: 16,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 이름 변경 다이얼로그
  void _showRenameDialog(
      BuildContext context,
      RecordData record,
      HistoryPageViewModel model
      ) {
    final TextEditingController controller = TextEditingController(text: record.fileName);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '녹음 이름 변경',
            style: TextStyles.bold(
              fontSize: 18,
              color: KwonThemes().surface01,
            ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: '새 이름 입력',
              hintStyle: TextStyles.regular(
                fontSize: 14,
                color: KwonThemes().black50,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                '취소',
                style: TextStyles.medium(
                  fontSize: 14,
                  color: KwonThemes().black60,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                model.updateRecordName(record.id, controller.text);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: KwonThemes().primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                '저장',
                style: TextStyles.medium(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // 삭제 확인 다이얼로그
  void _showDeleteConfirmation(
      BuildContext context,
      String id,
      HistoryPageViewModel model
      ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '녹음 삭제',
            style: TextStyles.bold(
              fontSize: 18,
              color: KwonThemes().surface01,
            ),
          ),
          content: Text(
            '이 녹음을 삭제하시겠습니까?\n삭제된 녹음은 복구할 수 없습니다.',
            style: TextStyles.regular(
              fontSize: 14,
              color: KwonThemes().black70,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                '취소',
                style: TextStyles.medium(
                  fontSize: 14,
                  color: KwonThemes().black60,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                model.deleteRecord(id);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                '삭제',
                style: TextStyles.medium(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// MARK: - 녹음 기록 페이지 뷰모델
class HistoryPageViewModel extends BaseViewModel {
  // UseCase 의존성 주입
  final _getHistoryUseCase = getIt<GetHistoryUseCase>();
  final _deleteHistoryUseCase = getIt<DeleteHistoryUseCase>();
  final _playHistoryUseCase = getIt<PlayHistoryUseCase>();
  final _updateHistoryNameUseCase = getIt<UpdateHistoryNameUseCase>();

  final ErrorUtil _errorUtil = ErrorUtil();

  // 녹음 목록
  List<RecordData> _recordList = [];
  List<RecordData> get recordList => _recordList;

  // 로딩 상태
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // 오류 상태
  bool _hasError = false;
  bool get hasError => _hasError;
  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  // 검색어
  String _searchText = '';
  String get searchText => _searchText;

  @override
  void clear({bool isInitClear = false}) {
    _recordList = [];
    _isLoading = false;
    _searchText = '';
    _hasError = false;
    _errorMessage = '';
  }

  @override
  Future<void> dataUpdate() async {
    Log.d('[HistoryPageViewModel] dataUpdate 시작');
    _isLoading = true;
    _hasError = false;
    update();

    try {
      Log.d('[HistoryPageViewModel] useCase 호출 전');

      final results = await _getHistoryUseCase.call();

      Log.d('[HistoryPageViewModel] useCase 호출 후, 결과 길이: ${results.length}');

      _recordList = [...results]; // 새 목록으로 할당 (중요)

      if (_recordList.isEmpty) {
        Log.d('[HistoryPageViewModel] 녹음 목록이 비어 있습니다.');
      } else {
        // 각 항목 자세히 로깅
        for (int i = 0; i < _recordList.length; i++) {
          Log.d('[HistoryPageViewModel] 녹음[$i]: id=${_recordList[i].id}, fileName=${_recordList[i].fileName}');
        }
      }

      // 검색어가 있으면 필터링
      if (_searchText.isNotEmpty) {
        _recordList = _recordList.where((item) =>
            item.fileName.toLowerCase().contains(_searchText.toLowerCase())
        ).toList();
      }
    } catch (e, s) {
      Log.e('[HistoryPageViewModel] 데이터 로드 실패: $e', s);
      _hasError = true;
      _errorMessage = '녹음 목록을 불러올 수 없습니다.';
    } finally {
      _isLoading = false;
      Log.d('[HistoryPageViewModel] dataUpdate 완료, recordList 개수: ${_recordList.length}');
      update();
    }
  }

  @override
  Future<void> init() async {
    Log.d('[HistoryPageViewModel] init 시작');

    try {
      // 녹음 목록을 즉시 불러오도록 변경
      _isLoading = true;
      update(); // 로딩 상태 UI 업데이트

      // 잠시 대기하여 UI가 로딩 상태를 표시할 시간을 줌
      await Future.delayed(const Duration(milliseconds: 100));

      // 바로 데이터 로드 시작
      final results = await _getHistoryUseCase.call();

      Log.d('[HistoryPageViewModel] 녹음 목록 로드 완료: ${results.length}개');

      _recordList = [...results]; // 새 목록으로 복사
      _isLoading = false;

      Log.d('[HistoryPageViewModel] init 완료, recordList 개수: ${_recordList.length}');
    } catch (e) {
      Log.e('[HistoryPageViewModel] init 오류: $e', StackTrace.current);
      _hasError = true;
      _errorMessage = '녹음 목록을 불러올 수 없습니다.';
      _isLoading = false;
    }

    update(); // 최종 상태로 UI 업데이트
  }

  // 녹음 삭제
  Future<void> deleteRecord(String id) async {
    try {
      await _deleteHistoryUseCase.call(id: id);
      await dataUpdate();
    } catch (e, s) {
      Log.e('녹음 삭제 실패', s);
      throw e;
    }
  }

  // 녹음 이름 변경
  Future<void> updateRecordName(String id, String newName) async {
    try {
      if (newName.isEmpty) {
        return;
      }

      await _updateHistoryNameUseCase.call(id: id, fileName: newName);
      await dataUpdate();
    } catch (e, s) {
      Log.e('녹음 이름 변경 실패', s);
      throw e;
    }
  }

  // 녹음 재생 페이지로 이동
  Future<void> navigateToPlayPage(String id) async {
    Log.d('[HistoryPageViewModel] 재생 페이지로 이동, ID: $id');

    await KwonRouter.to(
      scheme: Scheme.PLAY_HISTORY,
      arguments: {'id': id},
    );
  }

  // 검색어 설정
  void setSearchText(String text) {
    _searchText = text;
    dataUpdate();
  }
}