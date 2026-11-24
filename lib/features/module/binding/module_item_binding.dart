import 'package:get/get.dart';
import '../controller/module_item_controller.dart';
import '../repository/module_item_repository.dart';

class ModuleItemBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ModuleItemRepository>(
          () => ModuleItemRepository(),
      fenix: true,
    );
    Get.lazyPut<ModuleItemController>(
          () => ModuleItemController(repository: Get.find<ModuleItemRepository>()),
      fenix: true,
    );
  }
}