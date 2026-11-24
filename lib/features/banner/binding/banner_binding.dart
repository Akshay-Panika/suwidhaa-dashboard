
import 'package:get/get.dart';
import '../../user/controller/recent_users_controller.dart';
import '../controller/module_banner_controller.dart';

class BannerBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<RecentUsersController>(RecentUsersController(), permanent: true);
    Get.put<ModuleBannerController>(ModuleBannerController(), permanent: true,);
  }
}