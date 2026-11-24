import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/app_color.dart';
import '../controller/recent_users_controller.dart';
import '../model/recent_user_model.dart';

class UserCard extends StatefulWidget {
  final VoidCallback? onBackToDashboard;

  const UserCard({super.key, this.onBackToDashboard});

  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  late final RecentUsersController _controller;
  final TextEditingController _searchCtrl = TextEditingController();

  String _search = '';
  int? _selectedUserId;
  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<RecentUsersController>()
        ? Get.find<RecentUsersController>()
        : Get.put(RecentUsersController(), permanent: true);

    ever<List<RecentUserModel>>(_controller.users, (list) {
      if (!mounted) return;
      if (list.isEmpty) {
        setState(() => _selectedUserId = null);
      } else if (_selectedUserId == null ||
          !list.any((u) => u.id == _selectedUserId)) {
        setState(() => _selectedUserId = list.first.id);
      }
    });

    if (_controller.users.isNotEmpty) {
      _selectedUserId = _controller.users.first.id;
    } else if (!_controller.isLoading.value) {
      _controller.fetchRecentUsers();
    }
  }

  void _handleBack() {
    if (widget.onBackToDashboard != null) {
      widget.onBackToDashboard!();
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Widget _buildAvatar(RecentUserModel user, {double radius = 22}) {
    final hasImage = user.profileImage.trim().startsWith('http');
    final displayName =
    user.name.trim().isNotEmpty ? user.name.trim() : 'Suwidhaa User';

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColor.lightPrimary,
      backgroundImage: hasImage ? NetworkImage(user.profileImage.trim()) : null,
      child: hasImage
          ? null
          : Text(
        displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
        style: TextStyle(
          fontSize: radius * 0.65,
          fontWeight: FontWeight.w700,
          color: AppColor.primary,
        ),
      ),
    );
  }

  Widget _buildListItem(RecentUserModel user) {
    final isSelected = _selectedUserId == user.id;
    final displayName =
    user.name.trim().isNotEmpty ? user.name.trim() : 'Suwidhaa User';
    final subtitle = user.email.trim().isNotEmpty
        ? user.email.trim()
        : (user.phoneNumber.trim().isNotEmpty
        ? user.phoneNumber.trim()
        : 'User #${user.id}');

    return ListTile(
      selected: isSelected,
      selectedTileColor: AppColor.lightPrimary,
      tileColor: AppColor.bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected ? AppColor.primary : AppColor.border,
          width: isSelected ? 1.4 : 1,
        ),
      ),
      leading: _buildAvatar(user, radius: 20),
      title: Text(
        displayName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColor.deepPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 12, color: AppColor.textSecondary),
      ),
      trailing: Text(
        '#${user.id}',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColor.textSecondary,
        ),
      ),
      onTap: () => setState(() => _selectedUserId = user.id),
    );
  }

  Widget _buildGridItem(RecentUserModel user) {
    final isSelected = _selectedUserId == user.id;
    final displayName =
    user.name.trim().isNotEmpty ? user.name.trim() : 'Suwidhaa User';
    final subtitle = user.phoneNumber.trim().isNotEmpty
        ? user.phoneNumber.trim()
        : (user.email.trim().isNotEmpty ? user.email.trim() : 'User #${user.id}');

    return Material(
      color: isSelected ? AppColor.lightPrimary : AppColor.bg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(() => _selectedUserId = user.id),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColor.primary : AppColor.border,
              width: isSelected ? 1.4 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildAvatar(user, radius: 18),
                  Text(
                    '#${user.id}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColor.textSecondary,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColor.deepPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColor.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListSection(List<RecentUserModel> filtered, bool isLoading) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) {
                    setState(() => _search = v.trim().toLowerCase());
                  },
                  decoration: InputDecoration(
                    hintText: 'Search user by name, email, phone or id...',
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColor.textSecondary,
                    ),
                    suffixIcon: _search.isNotEmpty
                        ? IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: AppColor.textSecondary,
                      ),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _search = '');
                      },
                    )
                        : null,
                    filled: true,
                    fillColor: AppColor.bg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColor.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColor.border),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                decoration: BoxDecoration(
                  color: AppColor.bg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColor.border),
                ),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'List View',
                      onPressed: () => setState(() => _isGridView = false),
                      icon: Icon(
                        Icons.view_list_rounded,
                        color: !_isGridView
                            ? AppColor.primary
                            : AppColor.textSecondary,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Grid View',
                      onPressed: () => setState(() => _isGridView = true),
                      icon: Icon(
                        Icons.grid_view_rounded,
                        color: _isGridView
                            ? AppColor.primary
                            : AppColor.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: isLoading && filtered.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                ? const Center(
              child: Text(
                'No users found.',
                style: TextStyle(
                  color: AppColor.textSecondary,
                  fontSize: 13,
                ),
              ),
            )
                : _isGridView
                ? GridView.builder(
              itemCount: filtered.length,
              gridDelegate:
              const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 260,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                mainAxisExtent: 125,
              ),
              itemBuilder: (context, index) {
                return _buildGridItem(filtered[index]);
              },
            )
                : ListView.separated(
              itemCount: filtered.length,
              separatorBuilder: (_, __) =>
              const SizedBox(height: 8),
              itemBuilder: (context, index) {
                return _buildListItem(filtered[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    final display = value.trim().isNotEmpty ? value.trim() : '—';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColor.bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColor.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColor.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColor.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  display,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColor.deepPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(RecentUserModel? user, {double? width}) {
    return SizedBox(
      width: width,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: user == null
            ? const Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Center(
            child: Text(
              'Select a user to view details.',
              style: TextStyle(
                fontSize: 13,
                color: AppColor.textSecondary,
              ),
            ),
          ),
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'User Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColor.deepPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  _buildAvatar(user, radius: 42),
                  const SizedBox(height: 10),
                  Text(
                    user.name.trim().isNotEmpty
                        ? user.name.trim()
                        : 'Suwidhaa User',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColor.deepPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Profile ID: ${user.id}${user.userId != null ? '  •  User ID: ${user.userId}' : ''}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColor.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _detailRow(Icons.phone_rounded, 'Phone Number', user.phoneNumber),
            _detailRow(Icons.email_rounded, 'Email Address', user.email),
            _detailRow(Icons.location_on_rounded, 'Address', user.address),
            _detailRow(
              Icons.calendar_today_rounded,
              'Created At',
              user.createdAt,
            ),
            _detailRow(
              Icons.update_rounded,
              'Updated At',
              user.updatedAt,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final allUsers = _controller.users;
      final isLoading = _controller.isLoading.value;

      final filtered = allUsers.where((user) {
        if (_search.isEmpty) return true;
        return user.name.toLowerCase().contains(_search) ||
            user.email.toLowerCase().contains(_search) ||
            user.phoneNumber.toLowerCase().contains(_search) ||
            user.address.toLowerCase().contains(_search) ||
            user.id.toString().contains(_search) ||
            (user.userId?.toString().contains(_search) ?? false);
      }).toList();

      RecentUserModel? selectedUser;
      if (_selectedUserId != null) {
        selectedUser = allUsers.firstWhereOrNull((u) => u.id == _selectedUserId);
      }
      selectedUser ??= filtered.isNotEmpty ? filtered.first : null;

      return Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  tooltip: 'Back to Dashboard',
                  onPressed: _handleBack,
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: AppColor.deepPrimary,
                  ),
                ),
                const SizedBox(width: 6),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Users',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColor.deepPrimary,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'View registered Suwidhaa users and their profile details.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColor.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Card(
                elevation: 0,
                color: AppColor.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppColor.border),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 820;

                    if (isWide) {
                      return Row(
                        children: [
                          Expanded(child: _buildListSection(filtered, isLoading)),
                          const VerticalDivider(
                            width: 1,
                            color: AppColor.border,
                          ),
                          _buildDetailsSection(selectedUser, width: 400),
                        ],
                      );
                    }

                    return Column(
                      children: [
                        Expanded(child: _buildListSection(filtered, isLoading)),
                        const Divider(height: 1, color: AppColor.border),
                        Flexible(
                          flex: 0,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: constraints.maxHeight * 0.48,
                            ),
                            child: _buildDetailsSection(selectedUser),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}