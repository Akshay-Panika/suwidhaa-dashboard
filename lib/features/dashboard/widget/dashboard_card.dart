import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import '../../../core/utils/app_color.dart';
import '../../../core/utils/contact_helper.dart';
import '../../ads/controller/module_ad_controller.dart';
import '../../ads/model/module_ad_model.dart';
import '../../banner/controller/module_banner_controller.dart';
import '../../banner/model/module_banner_model.dart';
import '../../user/controller/recent_users_controller.dart';
import '../../user/model/recent_user_model.dart';

class DashboardCard extends StatefulWidget {
  final VoidCallback? onOpenBanners;
  final VoidCallback? onOpenAds;
  final VoidCallback? onOpenUsers;

  const DashboardCard({
    super.key,
    this.onOpenBanners,
    this.onOpenAds,
    this.onOpenUsers,
  });

  @override
  State<DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<DashboardCard> {
  late final RecentUsersController _recentUsersController;
  late final ModuleBannerController _bannerController;
  late final ModuleAdController _adController;

  @override
  void initState() {
    super.initState();
    _recentUsersController = Get.isRegistered<RecentUsersController>()
        ? Get.find<RecentUsersController>()
        : Get.put(RecentUsersController());

    _bannerController = Get.isRegistered<ModuleBannerController>()
        ? Get.find<ModuleBannerController>()
        : Get.put(ModuleBannerController(), permanent: true);

    _adController = Get.isRegistered<ModuleAdController>()
        ? Get.find<ModuleAdController>()
        : Get.put(ModuleAdController(), permanent: true);

    if (_bannerController.banners.isEmpty && !_bannerController.isLoading.value) {
      _bannerController.fetchBanners();
    }

    if (_adController.ads.isEmpty && !_adController.isLoading.value) {
      _adController.loadAds();
    }
  }

  final List<_ServiceItem> _services = const [
    _ServiceItem(
      title: 'School',
      subtitle: 'School Management',
      icon: Icons.school_rounded,
      url: 'https://suwidhaa-school.web.app/',
    ),
    _ServiceItem(
      title: 'College',
      subtitle: 'College Management',
      icon: Icons.account_balance_rounded,
      url: 'https://suwidhaa-college-dashboard.web.app/',
    ),
    _ServiceItem(
      title: 'NGO',
      subtitle: 'NGO Management',
      icon: Icons.volunteer_activism_rounded,
      url: 'https://suwidhaa-ngo-dashboard.web.app/',
    ),
    _ServiceItem(
      title: 'IT Services',
      subtitle: 'Technology Services',
      icon: Icons.computer_rounded,
      url: 'https://suwidhaa-it-dashboard.web.app/',
    ),
    _ServiceItem(
      title: 'E-Commerce',
      subtitle: 'Online Shopping',
      icon: Icons.shopping_bag_rounded,
      url: null,
    ),
    _ServiceItem(
      title: 'OTT',
      subtitle: 'Entertainment Platform',
      icon: Icons.live_tv_rounded,
      url: 'https://suwidhaa-ott-dashboard.web.app/',
    ),
  ];

  bool _hasValidUrl(_ServiceItem service) {
    final raw = service.url?.trim() ?? '';
    if (raw.isEmpty) return false;
    final uri = Uri.tryParse(
      raw.startsWith('http://') || raw.startsWith('https://')
          ? raw
          : 'https://$raw',
    );
    return uri != null &&
        uri.host.isNotEmpty &&
        !uri.host.endsWith('.example.com');
  }

  Future<void> _openService(_ServiceItem service) async {
    if (!_hasValidUrl(service)) {
      Fluttertoast.showToast(
        msg: '${service.title} URL is not configured yet.',
        backgroundColor: AppColor.red,
        textColor: AppColor.white,
      );
      return;
    }
    await ContactHelper.openWebsite(service.url!);
  }

  Future<void> _copyServiceLink(_ServiceItem service) async {
    if (!_hasValidUrl(service)) {
      Fluttertoast.showToast(
        msg: 'No link available to copy for ${service.title}.',
        backgroundColor: AppColor.red,
        textColor: AppColor.white,
      );
      return;
    }
    await Clipboard.setData(ClipboardData(text: service.url!.trim()));
    Fluttertoast.showToast(
      msg: '${service.title} link copied!',
      backgroundColor: AppColor.deepPrimary,
      textColor: AppColor.white,
    );
  }

  void _onViewAllBanners() {
    _bannerController.fetchBanners();
    widget.onOpenBanners?.call();
  }

  void _onViewAllAds() {
    _adController.loadAds();
    widget.onOpenAds?.call();
  }

  void _onViewAllUsers() {
    _recentUsersController.fetchRecentUsers();
    widget.onOpenUsers?.call();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dashboard',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColor.deepPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Manage all your Suwidhaa digital services from one place.',
            style: TextStyle(
              fontSize: 13,
              color: AppColor.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          Card(
            elevation: 0,
            color: AppColor.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColor.border),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Service grid header ──
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColor.lightPrimary,
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: const Icon(
                          Icons.apps_rounded,
                          color: AppColor.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Suwidhaa Services',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: AppColor.deepPrimary,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Tap a card to open its website or use copy to copy the URL',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColor.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // ── Service grid ──
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final crossAxisCount = width >= 850
                          ? 6
                          : width >= 520
                          ? 2
                          : 1;

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _services.length,
                        gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          mainAxisExtent: 132,
                        ),
                        itemBuilder: (context, index) {
                          return _serviceCard(_services[index]);
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 22),

                  // ── Side-by-side / Stacked sections ──
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= 820;

                      final leftColumn = Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _recentBannersSection(),
                          const SizedBox(height: 14),
                          _recentAdsSection(),
                        ],
                      );

                      final rightColumn = _recentUsersSection();

                      if (isWide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 2, child: leftColumn),
                            const SizedBox(width: 14),
                            Expanded(flex: 1, child: rightColumn),
                          ],
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _recentBannersSection(),
                          const SizedBox(height: 14),
                          _recentAdsSection(),
                          const SizedBox(height: 14),
                          _recentUsersSection(),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Service card ───────────────────────────────────────────────
  Widget _serviceCard(_ServiceItem service) {
    final isConfigured = _hasValidUrl(service);

    return Material(
      color: AppColor.bg,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        borderRadius: BorderRadius.circular(13),
        onTap: () => _openService(service),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: AppColor.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    height: 38,
                    width: 38,
                    decoration: BoxDecoration(
                      color: AppColor.lightPrimary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      service.icon,
                      color: AppColor.primary,
                      size: 21,
                    ),
                  ),
                  const Spacer(),
                  Tooltip(
                    message: isConfigured ? 'Copy link' : 'Link not set',
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => _copyServiceLink(service),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.copy_rounded,
                          size: 17,
                          color: isConfigured
                              ? AppColor.primary
                              : AppColor.textSecondary
                              .withValues(alpha: 0.45),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.open_in_new_rounded,
                    size: 17,
                    color: isConfigured
                        ? AppColor.textSecondary
                        : AppColor.textSecondary.withValues(alpha: 0.45),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                service.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColor.deepPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                service.subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColor.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Recent Banners section (API via ModuleBannerController) ───
  Widget _recentBannersSection() {
    return Obx(() {
      final banners = _bannerController.banners;
      final isLoading = _bannerController.isLoading.value;

      return _sectionContainer(
        icon: Icons.image_rounded,
        iconColor: AppColor.primary,
        iconBg: AppColor.lightPrimary,
        title: 'Recent Banners',
        count: banners.length,
        onViewAll: _onViewAllBanners,
        child: SizedBox(
          height: 148,
          child: isLoading && banners.isEmpty
              ? const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : banners.isEmpty
              ? const Center(
            child: Text(
              'No banners yet',
              style: TextStyle(
                fontSize: 12,
                color: AppColor.textSecondary,
              ),
            ),
          )
              : ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: banners.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) =>
                _bannerTile(banners[index]),
          ),
        ),
      );
    });
  }

  Widget _bannerTile(ModuleBannerModel banner) {
    final hasImage = banner.image.trim().startsWith('http');
    final hasVideo = banner.youtubeVideoUrl != null &&
        banner.youtubeVideoUrl!.trim().isNotEmpty;
    final parsedDate = banner.createdAt != null
        ? DateTime.tryParse(banner.createdAt!)
        : null;
    final subtitle =
    hasVideo ? banner.youtubeVideoUrl!.trim() : 'Banner #${banner.id}';

    return SizedBox(
      width: 210,
      child: Material(
        color: AppColor.bg,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: _onViewAllBanners,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColor.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 82,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(9)),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (hasImage)
                          Image.network(
                            banner.image.trim(),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _bannerPlaceholderBg(),
                          )
                        else
                          _bannerPlaceholderBg(),
                        if (hasVideo)
                          Positioned(
                            top: 6,
                            left: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColor.white.withValues(alpha: 0.92),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.play_arrow_rounded,
                                    size: 11,
                                    color: AppColor.primary,
                                  ),
                                  Text(
                                    'VIDEO',
                                    style: TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.4,
                                      color: AppColor.deepPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        Positioned(
                          top: 6,
                          right: 6,
                          child: _statusPill(true, label: 'Active'),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        banner.name.trim().isNotEmpty
                            ? banner.name.trim()
                            : 'Banner #${banner.id}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColor.deepPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColor.textSecondary,
                              ),
                            ),
                          ),
                          if (parsedDate != null)
                            Text(
                              _timeAgo(parsedDate),
                              style: const TextStyle(
                                fontSize: 9,
                                color: AppColor.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _bannerPlaceholderBg() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColor.primary.withValues(alpha: 0.85),
            AppColor.deepPrimary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.image_rounded,
          size: 30,
          color: AppColor.white.withValues(alpha: 0.45),
        ),
      ),
    );
  }

  // ── Recent Ads section (API via ModuleAdController) ──────────
  Widget _recentAdsSection() {
    return Obx(() {
      final ads = _adController.ads;
      final isLoading = _adController.isLoading.value;

      return _sectionContainer(
        icon: Icons.campaign_rounded,
        iconColor: AppColor.deepPrimary,
        iconBg: AppColor.lightPrimary.withValues(alpha: 0.6),
        title: 'Recent Ads',
        count: ads.length,
        onViewAll: _onViewAllAds,
        child: SizedBox(
          height: 148,
          child: isLoading && ads.isEmpty
              ? const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : ads.isEmpty
              ? const Center(
            child: Text(
              'No ads yet',
              style: TextStyle(
                fontSize: 12,
                color: AppColor.textSecondary,
              ),
            ),
          )
              : ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: ads.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) => _adTile(ads[index]),
          ),
        ),
      );
    });
  }

  Widget _adTile(ModuleAdModel ad) {
    final hasImage = ad.image.trim().startsWith('http');
    final hasVideo = ad.youtubeVideoUrl != null &&
        ad.youtubeVideoUrl!.trim().isNotEmpty;
    final parsedDate =
    ad.createdAt != null ? DateTime.tryParse(ad.createdAt!) : null;
    final subtitle =
    hasVideo ? ad.youtubeVideoUrl!.trim() : 'Ad #${ad.id}';

    return SizedBox(
      width: 210,
      child: Material(
        color: AppColor.bg,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: _onViewAllAds,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColor.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 82,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColor.primary,
                        AppColor.primary.withValues(alpha: 0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(9)),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (hasImage)
                        Image.network(
                          ad.image.trim(),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                            child: Icon(
                              Icons.campaign_rounded,
                              size: 30,
                              color: AppColor.white.withValues(alpha: 0.6),
                            ),
                          ),
                        )
                      else
                        Center(
                          child: Icon(
                            Icons.campaign_rounded,
                            size: 30,
                            color: AppColor.white.withValues(alpha: 0.6),
                          ),
                        ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: _statusPill(true, label: 'Active'),
                      ),
                      Positioned(
                        top: 6,
                        left: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            hasVideo ? 'VIDEO' : 'AD',
                            style: const TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: AppColor.deepPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ad.name.trim().isNotEmpty
                            ? ad.name.trim()
                            : 'Ad #${ad.id}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColor.deepPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColor.textSecondary,
                              ),
                            ),
                          ),
                          if (parsedDate != null)
                            Text(
                              _timeAgo(parsedDate),
                              style: const TextStyle(
                                fontSize: 9,
                                color: AppColor.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Recent Users section (API via RecentUsersController) ──────
  Widget _recentUsersSection() {
    return Obx(() {
      final users = _recentUsersController.users;
      final isLoading = _recentUsersController.isLoading.value;

      return _sectionContainer(
        icon: Icons.person_add_alt_1_rounded,
        iconColor: AppColor.primary,
        iconBg: AppColor.lightPrimary,
        title: 'Recent Users',
        count: users.length,
        onViewAll: _onViewAllUsers,
        child: isLoading && users.isEmpty
            ? const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        )
            : users.isEmpty
            ? const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: Text(
              'No users yet',
              style: TextStyle(
                fontSize: 12,
                color: AppColor.textSecondary,
              ),
            ),
          ),
        )
            : ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: users.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) => _userTile(users[index]),
        ),
      );
    });
  }

  T? _tryRead<T>(Object obj, T? Function() getter) {
    try {
      return getter();
    } catch (_) {
      return null;
    }
  }

  Widget _userTile(RecentUserModel user) {
    final dynamic u = user;
    final idStr = (_tryRead<Object?>(user, () => u.id) ?? '').toString().trim();
    final rawName = (_tryRead<Object?>(user, () => u.fullName) ??
        _tryRead<Object?>(user, () => u.name) ??
        '')
        .toString()
        .trim();
    final rawPhone = (_tryRead<Object?>(user, () => u.phone) ??
        _tryRead<Object?>(user, () => u.mobile) ??
        _tryRead<Object?>(user, () => u.phoneNumber) ??
        '')
        .toString()
        .trim();
    final rawEmail =
    (_tryRead<Object?>(user, () => u.email) ?? '').toString().trim();

    final displayName = rawName.isNotEmpty
        ? rawName
        : (rawPhone.isNotEmpty
        ? rawPhone
        : (idStr.isNotEmpty ? 'User #$idStr' : 'User'));
    final subtitle = rawEmail.isNotEmpty
        ? rawEmail
        : (rawPhone.isNotEmpty ? rawPhone : 'No contact');
    final isVerified = (_tryRead<bool>(user, () => u.isPhoneVerified) == true) ||
        (_tryRead<bool>(user, () => u.isEmailVerified) == true) ||
        (_tryRead<bool>(user, () => u.isVerified) == true);

    return Material(
      color: AppColor.bg,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: _onViewAllUsers,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColor.border),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: AppColor.lightPrimary,
                child: Text(
                  displayName[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColor.primary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColor.deepPrimary,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColor.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // _statusPill(
              //   isVerified,
              //   label: isVerified ? 'Verified' : 'Pending',
              // ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Shared section wrapper & helpers ──────────────────────────
  Widget _sectionContainer({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required int count,
    required VoidCallback onViewAll,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColor.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 17, color: iconColor),
              ),
              const SizedBox(width: 9),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColor.deepPrimary,
                ),
              ),
              const SizedBox(width: 7),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColor.bg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColor.border),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColor.textSecondary,
                  ),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: onViewAll,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColor.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _statusPill(bool active, {String label = 'Active'}) {
    final bg = active
        ? AppColor.green.withValues(alpha: 0.14)
        : AppColor.textSecondary.withValues(alpha: 0.14);
    final fg = active ? AppColor.green : AppColor.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        active ? label : 'Inactive',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }

  String _timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _ServiceItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final String? url;

  const _ServiceItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.url,
  });
}