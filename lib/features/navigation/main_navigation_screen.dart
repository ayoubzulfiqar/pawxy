import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../server_sync/presentation/screens/servers_screen.dart';
import '../speed_test/presentation/screens/speed_test_screen.dart';
import '../vpn/presentation/screens/home_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _navigateToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Widget> screens = [
      HomeScreen(
        onNavigateToServers: () => _navigateToTab(2),
      ),
      const SpeedTestScreen(),
      ServersScreen(
        onSelectAndNavigateHome: () => _navigateToTab(0),
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background(isDark),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.cardBorder(isDark), width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _navigateToTab,
          backgroundColor: AppColors.backgroundSecondary(isDark),
          selectedItemColor: AppColors.pawxyOrange,
          unselectedItemColor: AppColors.textMuted(isDark),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.power_settings_new_rounded),
              activeIcon: Icon(Icons.power_settings_new_rounded,
                  color: AppColors.pawxyOrange),
              label: 'Connect',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bolt_rounded),
              activeIcon:
                  Icon(Icons.bolt_rounded, color: AppColors.pawxyOrange),
              label: 'Speed Test',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.dns_rounded),
              activeIcon:
                  Icon(Icons.dns_rounded, color: AppColors.pawxyOrange),
              label: 'Servers',
            ),
          ],
        ),
      ),
    );
  }
}
