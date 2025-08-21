import 'package:flutter/material.dart';

class FancyBottomNav extends StatelessWidget {
  const FancyBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SizedBox(
          height: 85,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // The rounded, white bar
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0xFFFFFFFF), Color(0xFFF8F8F8)],
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 24,
                      offset: Offset(0, 12),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 34),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _NavIcon(
                      index: 0,
                      isSelected: currentIndex == 0,
                      icon: Icons.home_outlined,
                      selectedIcon: Icons.home,
                      onTap: onTap,
                    ),
                    _NavIcon(
                      index: 1,
                      isSelected: currentIndex == 1,
                      icon: Icons.bookmark_border,
                      selectedIcon: Icons.bookmark,
                      onTap: onTap,
                    ),
                    _NavIcon(
                      index: 2,
                      isSelected: currentIndex == 2,
                      icon: Icons.notifications_none,
                      selectedIcon: Icons.notifications,
                      onTap: onTap,
                    ),
                    _NavIcon(
                      index: 3,
                      isSelected: currentIndex == 3,
                      icon: Icons.person_outline,
                      selectedIcon: Icons.person,
                      onTap: onTap,
                    ),
                  ],
                ),
              ),

              // Small black dot "notch" at the top center
              Positioned(
                top: -5,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.index,
    required this.isSelected,
    required this.icon,
    required this.selectedIcon,
    required this.onTap,
  });

  final int index;
  final bool isSelected;
  final IconData icon;
  final IconData selectedIcon;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = isSelected ? Colors.black : Colors.grey;
    return InkResponse(
      onTap: () => onTap(index),
      radius: 28,
      containedInkWell: true,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color:
              isSelected ? Colors.black.withOpacity(0.06) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(isSelected ? selectedIcon : icon, size: 28, color: color),
      ),
    );
  }
}
