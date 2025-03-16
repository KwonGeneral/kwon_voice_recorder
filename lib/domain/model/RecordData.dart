// MARK: - 녹음 데이터
import 'package:kwon_voice_recorder/common/types/RecordStatus.dart';

class RecordData {
  String id;  // 녹음 고유 아이디
  String fileName;  // 녹음 파일명
  String filePath;  // 녹음 파일 경로
  DateTime recordedAt;  // 녹음 날짜 및 시간
  int duration;  // 녹음 길이 (밀리초)
  double fileSize;  // 파일 크기 (바이트)
  RecordStatus status = RecordStatus.NONE;  // 녹음 상태 (재생, 일시정지, 정지, 없음)

  RecordData({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.recordedAt,
    required this.duration,
    required this.fileSize,
    required this.status,
  });

  // Empty
  factory RecordData.empty({
    RecordStatus? status,
  }) {
    final now = DateTime.now();
    final id = now.millisecondsSinceEpoch.toString();
    return RecordData(
      id: id,
      fileName: '녹음 $id',
      filePath: '',
      recordedAt: now,
      duration: 0,
      fileSize: 0,
      status: status ?? RecordStatus.NONE,
    );
  }

  // toJson
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'filePath': filePath,
      'recordedAt': recordedAt.toIso8601String(),
      'duration': duration,
      'fileSize': fileSize,
      'status': status.value,
    };
  }

  // fromJson
  RecordData.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        fileName = json['fileName'],
        filePath = json['filePath'],
        recordedAt = DateTime.parse(json['recordedAt']),
        duration = json['duration'],
        fileSize = json['fileSize'],
        status = RecordStatus.getStatus(json['status']);

  // 포맷된 시간 (3:45 형식)
  String get formattedDuration {
    final minutes = (duration / 60000).floor();
    final seconds = ((duration % 60000) / 1000).floor();
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  // 포맷된 날짜 (2024-03-16 형식)
  String get formattedDate {
    return '${recordedAt.year}-${recordedAt.month.toString().padLeft(2, '0')}-${recordedAt.day.toString().padLeft(2, '0')}';
  }

  // 포맷된 시간 (14:30 형식)
  String get formattedTime {
    return '${recordedAt.hour.toString().padLeft(2, '0')}:${recordedAt.minute.toString().padLeft(2, '0')}';
  }

  // 포맷된 파일 크기 (1.2 MB 형식)
  String get formattedFileSize {
    if (fileSize < 1024) {
      return '${fileSize.toStringAsFixed(0)} B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  @override
  String toString() {
    return 'RecordData{id: $id, fileName: $fileName, filePath: $filePath, '
        'recordedAt: $recordedAt, duration: $duration, fileSize: $fileSize, status: $status}';
  }
}