import 'package:flutter/material.dart';

class RetroLoadingWidget extends StatefulWidget {
  final int totalDrinks;
  const RetroLoadingWidget({Key? key, required this.totalDrinks})
      : super(key: key);

  @override
  State<RetroLoadingWidget> createState() => _RetroLoadingWidgetState();
}

class _RetroLoadingWidgetState extends State<RetroLoadingWidget> {
  int _currentCount = 0;
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _startCounting();
  }

  Future<void> _startCounting() async {
    while (_currentCount < widget.totalDrinks) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (mounted) {
        setState(() {
          _currentCount++;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: DefaultTextStyle(
          style: const TextStyle(
            fontFamily: 'Courier',
            fontSize: 16,
            color: Color(0xFF00FF00), // Verde MS-DOS
            fontWeight: FontWeight.bold,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Loading Cocktails...'),
              const SizedBox(height: 8),
              Text('[$_currentCount/${widget.totalDrinks}]'),
              const SizedBox(height: 8),
              const Text('Please wait...'),
            ],
          ),
        ),
      ),
    );
  }
}
