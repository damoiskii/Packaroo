import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class TitleBarIconWidget extends StatefulWidget {
  const TitleBarIconWidget({super.key});

  @override
  State<TitleBarIconWidget> createState() => _TitleBarIconWidgetState();
}

class _TitleBarIconWidgetState extends State<TitleBarIconWidget> {
  @override
  void initState() {
    super.initState();
    _setCustomTitleBar();
  }

  Future<void> _setCustomTitleBar() async {
    try {
      // Try custom title bar with icon
      await windowManager.setTitleBarStyle(
        TitleBarStyle.normal,
        windowButtonVisibility: true,
      );

      // Force set the icon again
      await windowManager.setIcon('assets/icons/icon.png');
    } catch (e) {
      print('Failed to set custom title bar: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      child: Row(
        children: [
          // Custom title bar with icon
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'assets/icons/icon.png',
              width: 16,
              height: 16,
            ),
          ),
          const Text(
            'Packaroo - Java Application Packager',
            style: TextStyle(fontSize: 14),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
