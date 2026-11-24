import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suwidhaa_dashboard/features/ads/widget/ads_card.dart';
import 'package:suwidhaa_dashboard/features/banner/widget/banner_card.dart';
import 'package:suwidhaa_dashboard/features/dashboard/widget/dashboard_card.dart';
import 'package:suwidhaa_dashboard/features/user/widget/user_card.dart';
import '../../../core/utils/app_color.dart';
import '../../auth/screen/auth_screen.dart';
import '../../module/widget/module_card.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  int _selectedIndex = 0;

  final List<_MenuItem> _menu = const [
    _MenuItem('Dashboard', Icons.dashboard_rounded),
    _MenuItem('Module', Icons.layers_rounded),
    _MenuItem('Banner', Icons.image_rounded),
    _MenuItem('Ads', Icons.campaign_rounded),
    _MenuItem('Users', Icons.people_rounded),
  ];

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('userEmail');

    Fluttertoast.showToast(
      msg: 'Logged out successfully.',
      backgroundColor: AppColor.primary,
      textColor: AppColor.white,
      gravity: ToastGravity.BOTTOM,
    );

    Get.offAll(() => const AuthScreen());
  }

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.of(context).size.width < 760;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColor.bg,
      appBar: AppBar(
        backgroundColor: AppColor.white,
        foregroundColor: AppColor.deepPrimary,
        elevation: 0,
        surfaceTintColor: AppColor.white,
        leading: isNarrow
            ? IconButton(
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          icon: const Icon(Icons.menu_rounded),
        )
            : null,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColor.lightPrimary,
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(
                Icons.grid_view_rounded,
                color: AppColor.primary,
                size: 21,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Suwidhaa Admin',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColor.deepPrimary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: isNarrow
          ? Drawer(
        backgroundColor: AppColor.white,
        child: SafeArea(
          child: _buildSidebar(isDrawer: true),
        ),
      )
          : null,
      body: SafeArea(
        child: isNarrow
            ? _buildContent()
            : Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSidebar(),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  // SIDEBAR
  Widget _buildSidebar({bool isDrawer = false}) {
    return Container(
      width: isDrawer ? 280 : 235,
      decoration: const BoxDecoration(
        color: AppColor.white,
        border: Border(
          right: BorderSide(color: AppColor.border),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Divider(color: AppColor.border, height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 14),
              itemCount: _menu.length,
              itemBuilder: (context, index) {
                final item = _menu[index];
                final isSelected = _selectedIndex == index;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 3,
                  ),
                  child: Material(
                    color: isSelected
                        ? AppColor.lightPrimary
                        : AppColor.transparent,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        setState(() => _selectedIndex = index);

                        if (_scaffoldKey.currentState?.isDrawerOpen == true) {
                          Navigator.pop(context);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 13,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              item.icon,
                              size: 19,
                              color: isSelected
                                  ? AppColor.primary
                                  : AppColor.textSecondary,
                            ),
                            const SizedBox(width: 13),
                            Expanded(
                              child: Text(
                                item.label,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? AppColor.primary
                                      : AppColor.textPrimary,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Container(
                                height: 6,
                                width: 6,
                                decoration: const BoxDecoration(
                                  color: AppColor.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColor.border),
              ),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColor.lightPrimary,
                  child: Icon(
                    Icons.person_rounded,
                    size: 19,
                    color: AppColor.primary,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Administrator',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColor.deepPrimary,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'admin@gmail.com',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColor.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // CONTENT
  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return DashboardCard(
          onOpenBanners: () => setState(() => _selectedIndex = 2),
          onOpenAds: () => setState(() => _selectedIndex = 3),
          onOpenUsers: () => setState(() => _selectedIndex = 4),
        );
      case 1:
        return ModuleCard(
          onBackToDashboard: () => setState(() => _selectedIndex = 0),
        );
      case 2:
        return BannerCard(
          onBackToDashboard: () => setState(() => _selectedIndex = 0),
        );
      case 3:
        return AdsCard(
          onBackToDashboard: () => setState(() => _selectedIndex = 0),
        );
      case 4:
        return UserCard(
          onBackToDashboard: () => setState(() => _selectedIndex = 0),
        );
      default:
        return DashboardCard(
          onOpenBanners: () => setState(() => _selectedIndex = 2),
          onOpenAds: () => setState(() => _selectedIndex = 3),
          onOpenUsers: () => setState(() => _selectedIndex = 4),
        );
    }
  }
}

class _MenuItem {
  final String label;
  final IconData icon;

  const _MenuItem(this.label, this.icon);
}