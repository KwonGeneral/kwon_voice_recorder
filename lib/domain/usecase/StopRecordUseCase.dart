
import 'package:injectable/injectable.dart';
import 'package:kwon_voice_recorder/domain/repository/RecordRepositoryImpl.dart';

// MARK: - 녹음 중지 UseCase
@singleton
class StopRecordUseCase {
  final RecordRepositoryImpl recordRepository;

  StopRecordUseCase(this.recordRepository);

  Future<void> call() async {
    try {
      return recordRepository.stopRecord();
    } catch(e, s) {
      return Future.error(e, s);
    }
  }
}