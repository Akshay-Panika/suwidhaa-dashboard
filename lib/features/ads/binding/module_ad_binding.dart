import 'package:get/get.dart';
import '../controller/module_ad_controller.dart';

class ModuleAdBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ModuleAdController>(() => ModuleAdController());
  }
}