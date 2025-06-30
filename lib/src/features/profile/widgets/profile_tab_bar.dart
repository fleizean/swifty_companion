import 'package:flutter/material.dart';

class FuturisticTabBar extends StatefulWidget {
  final List<String> tabs;
  final int selectedIndex;
  final Function(int) onTabChanged;

  const FuturisticTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabChanged,
  });

  @override
  State<FuturisticTabBar> createState() => _FuturisticTabBarState();
}

class _FuturisticTabBarState extends State<FuturisticTabBar>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.tabs.length,
        itemBuilder: (context, index) {
          final isSelected = widget.selectedIndex == index;
          
          return AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: isSelected ? _scaleAnimation.value : 1.0,
                child: GestureDetector(
                  onTapDown: (_) {
                    if (isSelected) _animationController.forward();
                  },
                  onTapUp: (_) {
                    if (isSelected) _animationController.reverse();
                    widget.onTabChanged(index);
                  },
                  onTapCancel: () {
                    if (isSelected) _animationController.reverse();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      gradient: isSelected 
                        ? const LinearGradient(
                            colors: [Color(0xFF00d4ff), Color(0xFF7209b7)],
                          )
                        : null,
                      color: isSelected ? null : Colors.white.withOpacity(0.1),
                      border: Border.all(
                        color: isSelected 
                          ? Colors.transparent
                          : Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                      boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF00d4ff).withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ]
                        : null,
                    ),
                    child: Center(
                      child: Text(
                        widget.tabs[index],
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}