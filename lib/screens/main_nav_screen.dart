import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home/home_screen.dart';
import 'community/communities_screen.dart';
import 'search/search_screen.dart';
import 'chat/chat_list_screen.dart';
import 'profile/profile_screen.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    CommunitiesScreen(),
    SearchScreen(),
    ChatListScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final chat = context.watch<ChatProvider>();
    final user = auth.currentUser;

    // Check for unread indicators
    final pendingRequests = auth.getPendingIncomingRequests().length;
    final totalUnreadMessages = chat.rooms.fold<int>(0, (sum, r) => sum + r.unreadCount);
    final chatBadgeCount = pendingRequests + totalUnreadMessages;

    const activeColor = Color(0xFF58A6FF); // GitHub Blue
    const inactiveColor = Color(0xFF8B949E); // GitHub Muted Gray

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF161B22),
          border: Border(
            top: BorderSide(
              color: Color(0xFF30363D),
              width: 1,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: SafeArea(
          child: Row(
            children: [
              // 1. Home
              Expanded(
                child: _buildNavItem(
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home_rounded,
                  label: 'Home',
                  isSelected: _currentIndex == 0,
                  onTap: () => setState(() => _currentIndex = 0),
                  activeColor: activeColor,
                  inactiveColor: inactiveColor,
                ),
              ),
              // 2. Communities
              Expanded(
                child: _buildNavItem(
                  icon: Icons.groups_outlined,
                  selectedIcon: Icons.groups_rounded,
                  label: 'Communities',
                  isSelected: _currentIndex == 1,
                  onTap: () => setState(() => _currentIndex = 1),
                  activeColor: activeColor,
                  inactiveColor: inactiveColor,
                ),
              ),
              // 3. Search (Center button between Communities and Chat)
              Expanded(
                child: _buildNavItem(
                  icon: Icons.search_rounded,
                  selectedIcon: Icons.search,
                  label: 'Search',
                  isSelected: _currentIndex == 2,
                  onTap: () => setState(() => _currentIndex = 2),
                  activeColor: activeColor,
                  inactiveColor: inactiveColor,
                ),
              ),
              // 4. Chat (Instagram DM Style)
              Expanded(
                child: _buildNavItem(
                  icon: Icons.chat_bubble_outline_rounded,
                  selectedIcon: Icons.chat_bubble_rounded,
                  label: 'Chat',
                  isSelected: _currentIndex == 3,
                  onTap: () => setState(() => _currentIndex = 3),
                  activeColor: activeColor,
                  inactiveColor: inactiveColor,
                  badgeCount: chatBadgeCount,
                ),
              ),
              // 5. Profile
              Expanded(
                child: _buildNavItem(
                  icon: Icons.person_outline_rounded,
                  selectedIcon: Icons.person_rounded,
                  label: 'Profile',
                  isSelected: _currentIndex == 4,
                  onTap: () => setState(() => _currentIndex = 4),
                  activeColor: activeColor,
                  inactiveColor: inactiveColor,
                  customAvatar: user?.avatarUrl,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    IconData? selectedIcon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required Color activeColor,
    required Color inactiveColor,
    int badgeCount = 0,
    String? customAvatar,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.topRight,
              clipBehavior: Clip.none,
              children: [
                if (customAvatar != null)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? activeColor : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(customAvatar, style: const TextStyle(fontSize: 14)),
                  )
                else
                  Icon(
                    isSelected ? (selectedIcon ?? icon) : icon,
                    size: 22,
                    color: isSelected ? activeColor : inactiveColor,
                  ),
                if (badgeCount > 0)
                  Positioned(
                    right: -6,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF85149),
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
                      alignment: Alignment.center,
                      child: Text(
                        badgeCount > 9 ? '9+' : '$badgeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
