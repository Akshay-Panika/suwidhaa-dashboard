// lib/feature/recent_users/binding/recent_users_binding.dart
import 'package:get/get.dart';
import '../controller/recent_users_controller.dart';

class RecentUsersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RecentUsersController>(() => RecentUsersController());
  }
}