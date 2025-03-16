
import 'package:get/get.dart';
import 'package:kwon_voice_recorder/common/utils/Log.dart';

// MARK: - BaseViewModel
abstract class BaseViewModel extends GetxController {
  bool isError = false;

  BaseViewModel(): super();

  Future<void> initialize() async {
    try {
      isError = false;
      await init();
    } catch (e, s) {
      isError = true;
      Log.e(e, s);
      update();
    }
  }

  void clear({bool isInitClear = false});

  Future<void> dataUpdate();

  Future<void> init();
}