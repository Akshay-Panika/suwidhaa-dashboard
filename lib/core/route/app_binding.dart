import 'package:get/get.dart';
import '../../features/ads/controller/module_ad_controller.dart';
import '../../features/module/binding/module_item_binding.dart';
import '../../features/user/controller/recent_users_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<RecentUsersController>(RecentUsersController(), permanent: true);
    Get.put<ModuleAdController>(ModuleAdController(), permanent: true);
    ModuleItemBinding().dependencies();
  }
}