

// MARK: - 녹음 상태 (재생, 일시정지, 정지, 없음)
enum RecordStatus {
  NONE(99),
  PLAY(1),
  PAUSE(2),
  STOP(3);

  final int value;
  const RecordStatus(this.value);

  // MARK: - value로 RecordStatus 반환
  static RecordStatus getStatus(int? value) {
    var data = RecordStatus.NONE;
    if(value == null) {
      return data;
    }
    for (var status in RecordStatus.values) {
      if (status.value == value) {
        data = status;
        break;
      }
    }
    return data;
  }
}