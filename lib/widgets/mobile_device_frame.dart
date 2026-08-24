import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MobileDeviceFrame extends StatefulWidget {
  final Widget child;

  const MobileDeviceFrame({super.key, required this.child});

  @override
  State<MobileDeviceFrame> createState() => _MobileDeviceFrameState();
}

class _MobileDeviceFrameState extends State<MobileDeviceFrame> {
  String _currentTime = '';

  @override
  void initState() {
    super.initState();
    _updateTime();
  }

  void _updateTime() {
    _currentTime = DateFormat('h:mm').format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isDesktopOrWide = mediaQuery.size.width > 650;

    if (!isDesktopOrWide) {
      return widget.child;
    }

    _updateTime();

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Center(
        child: Container(
          width: 415,
          height: 870,
          margin: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(48),
            border: Border.all(color: const Color(0xFF334155), width: 3.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 36,
                spreadRadius: 8,
                offset: const Offset(0, 16),
              ),
              BoxShadow(
                color: const Color(0xFF7C3AED).withValues(alpha: 0.15),
                blurRadius: 48,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(44),
            child: Stack(
              children: [
                // Inner mobile screen content
                Column(
                  children: [
                    // Simulated Mobile Status Bar
                    Container(
                      height: 44,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF0B0F19)
                          : Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _currentTime,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
                            ),
                          ),
                          // Dynamic Island / Speaker Pill
                          Container(
                            width: 90,
                            height: 22,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.signal_cellular_4_bar_rounded,
                                size: 14,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : const Color(0xFF0F172A),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.wifi_rounded,
                                size: 15,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : const Color(0xFF0F172A),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.battery_full_rounded,
                                size: 16,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : const Color(0xFF0F172A),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // App Content
                    Expanded(child: widget.child),
                    // Bottom Home Indicator Bar
                    Container(
                      height: 20,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF101624)
                          : Colors.white,
                      alignment: Alignment.center,
                      child: Container(
                        width: 120,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFF94A3B8),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
