// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:kwon_voice_recorder/data/repository/RecordRepository.dart'
    as _i192;
import 'package:kwon_voice_recorder/domain/repository/RecordRepositoryImpl.dart'
    as _i594;
import 'package:kwon_voice_recorder/domain/usecase/DeleteHistoryUseCase.dart'
    as _i846;
import 'package:kwon_voice_recorder/domain/usecase/GetHistoryUseCase.dart'
    as _i1031;
import 'package:kwon_voice_recorder/domain/usecase/PauseRecordUseCase.dart'
    as _i772;
import 'package:kwon_voice_recorder/domain/usecase/PlayHistoryUseCase.dart'
    as _i795;
import 'package:kwon_voice_recorder/domain/usecase/StartRecordUseCase.dart'
    as _i327;
import 'package:kwon_voice_recorder/domain/usecase/StopRecordUseCase.dart'
    as _i512;
import 'package:kwon_voice_recorder/domain/usecase/UpdateHistoryNameUseCase.dart'
    as _i743;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt initGetIt({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.singleton<_i594.RecordRepositoryImpl>(() => _i192.RecordRepository());
    gh.singleton<_i846.DeleteHistoryUseCase>(
        () => _i846.DeleteHistoryUseCase(gh<_i594.RecordRepositoryImpl>()));
    gh.singleton<_i1031.GetHistoryUseCase>(
        () => _i1031.GetHistoryUseCase(gh<_i594.RecordRepositoryImpl>()));
    gh.singleton<_i772.PauseRecordUseCase>(
        () => _i772.PauseRecordUseCase(gh<_i594.RecordRepositoryImpl>()));
    gh.singleton<_i795.PlayHistoryUseCase>(
        () => _i795.PlayHistoryUseCase(gh<_i594.RecordRepositoryImpl>()));
    gh.singleton<_i327.StartRecordUseCase>(
        () => _i327.StartRecordUseCase(gh<_i594.RecordRepositoryImpl>()));
    gh.singleton<_i512.StopRecordUseCase>(
        () => _i512.StopRecordUseCase(gh<_i594.RecordRepositoryImpl>()));
    gh.singleton<_i743.UpdateHistoryNameUseCase>(
        () => _i743.UpdateHistoryNameUseCase(gh<_i594.RecordRepositoryImpl>()));
    return this;
  }
}
