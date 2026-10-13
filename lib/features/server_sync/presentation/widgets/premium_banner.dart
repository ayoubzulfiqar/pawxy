import 'package:flutter/material.dart';

/// Legacy banner stub - Pawxy VPN is 100% free for all users.
class PremiumBanner extends StatelessWidget {
  final VoidCallback onTap;

  const PremiumBanner({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
