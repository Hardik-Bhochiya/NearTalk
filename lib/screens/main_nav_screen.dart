import 'package:flutter/material.dart';
import 'home/home_screen.dart';
import 'community/communities_screen.dart';
import 'chat/chat_list_screen.dart';
import 'profile/profile_screen.dart';
import 'question/ask_question_screen.dart';

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
    SizedBox.shrink(), // Placeholder for center Ask button
    ChatListScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const activeColor = Color(0xFF6D28D9);
    const inactiveColor = Color(0xFF94A3B8);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex == 2 ? 0 : _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF101624) : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // 1. Home
              _buildNavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                isSelected: _currentIndex == 0,
                onTap: () => setState(() => _currentIndex = 0),
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),
              // 2. Communities
              _buildNavItem(
                icon: Icons.groups_outlined,
                selectedIcon: Icons.groups_rounded,
                label: 'Communities',
                isSelected: _currentIndex == 1,
                onTap: () => setState(() => _currentIndex = 1),
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),
              // 3. Center Elevated Ask Button
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      fullscreenDialog: true,
                      builder: (_) => const AskQuestionScreen(),
                    ),
                  );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x667C3AED),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.add, color: Colors.white, size: 26),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Ask',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: activeColor,
                      ),
                    ),
                  ],
                ),
              ),
              // 4. Chats
              _buildNavItem(
                icon: Icons.chat_bubble_outline_rounded,
                selectedIcon: Icons.chat_bubble_rounded,
                label: 'Chats',
                isSelected: _currentIndex == 3,
                onTap: () => setState(() => _currentIndex = 3),
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),
              // 5. Profile
              _buildNavItem(
                icon: Icons.person_outline_rounded,
                selectedIcon: Icons.person_rounded,
                label: 'Profile',
                isSelected: _currentIndex == 4,
                onTap: () => setState(() => _currentIndex = 4),
                activeColor: activeColor,
                inactiveColor: inactiveColor,
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
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? (selectedIcon ?? icon) : icon,
              size: 24,
              color: isSelected ? activeColor : inactiveColor,
            ),
            const SizedBox(height: 3),
            Text(
              label,
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
