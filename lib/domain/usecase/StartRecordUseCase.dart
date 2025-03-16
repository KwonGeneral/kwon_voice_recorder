
import 'package:injectable/injectable.dart';
import 'package:kwon_voice_recorder/domain/repository/RecordRepositoryImpl.dart';

// MARK: - 녹음 시작 UseCase
@singleton
class StartRecordUseCase {
  final RecordRepositoryImpl recordRepository;

  StartRecordUseCase(this.recordRepository);

  Future<void> call() async {
    try {
      return recordRepository.startRecord();
    } catch(e, s) {
      return Future.error(e, s);
    }
  }
}