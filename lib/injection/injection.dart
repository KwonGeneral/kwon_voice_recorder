// ignore_for_file: constant_identifier_names

import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:kwon_voice_recorder/data/repository/RecordRepository.dart';
import 'package:kwon_voice_recorder/domain/repository/RecordRepositoryImpl.dart';
import 'package:kwon_voice_recorder/domain/usecase/DeleteHistoryUseCase.dart';
import 'package:kwon_voice_recorder/domain/usecase/GetHistoryUseCase.dart';
import 'package:kwon_voice_recorder/domain/usecase/PauseRecordUseCase.dart';
import 'package:kwon_voice_recorder/domain/usecase/PlayHistoryUseCase.dart';
import 'package:kwon_voice_recorder/domain/usecase/StartRecordUseCase.dart';
import 'package:kwon_voice_recorder/domain/usecase/StopRecordUseCase.dart';
import 'package:kwon_voice_recorder/domain/usecase/UpdateHistoryNameUseCase.dart';

import 'injection.config.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit(
  // 초기화 함수 이름 설정
  initializerName: 'initGetIt',
)
Future<void> _getItInit() async {
  // MARK: - Repository
  if(!getIt.isRegistered<RecordRepositoryImpl>()) {
    getIt.registerLazySingleton<RecordRepositoryImpl>(() => RecordRepository());
  }

  // MARK: - UseCase
  if(!getIt.isRegistered<StartRecordUseCase>()) {
    getIt.registerSingleton<StartRecordUseCase>(StartRecordUseCase(getIt<RecordRepositoryImpl>()));
  }

  if(!getIt.isRegistered<PauseRecordUseCase>()) {
    getIt.registerLazySingleton<PauseRecordUseCase>(() => PauseRecordUseCase(getIt<RecordRepositoryImpl>()));
  }

  if(!getIt.isRegistered<StopRecordUseCase>()) {
    getIt.registerLazySingleton<StopRecordUseCase>(() => StopRecordUseCase(getIt<RecordRepositoryImpl>()));
  }

  if(!getIt.isRegistered<GetHistoryUseCase>()) {
    getIt.registerLazySingleton<GetHistoryUseCase>(() => GetHistoryUseCase(getIt<RecordRepositoryImpl>()));
  }

  if(!getIt.isRegistered<DeleteHistoryUseCase>()) {
    getIt.registerLazySingleton<DeleteHistoryUseCase>(() => DeleteHistoryUseCase(getIt<RecordRepositoryImpl>()));
  }

  if(!getIt.isRegistered<PlayHistoryUseCase>()) {
    getIt.registerLazySingleton<PlayHistoryUseCase>(() => PlayHistoryUseCase(getIt<RecordRepositoryImpl>()));
  }

  if(!getIt.isRegistered<UpdateHistoryNameUseCase>()) {
    getIt.registerLazySingleton<UpdateHistoryNameUseCase>(() => UpdateHistoryNameUseCase(getIt<RecordRepositoryImpl>()));
  }

  // MARK: - 의존성 주입 설정
  getIt.initGetIt();
}

// MARK: - 의존성 역전 셋팅
Future<void> getItSetup() async {
  _getItInit();
}
