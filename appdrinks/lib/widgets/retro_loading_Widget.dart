import 'dart:async';

import 'package:flutter/material.dart';

class RetroLoadingWidget extends StatefulWidget {
  final int totalDrinks;
  final Stream<int>?
      loadingProgress; // Novo parâmetro para receber o progresso real

  const RetroLoadingWidget({
    super.key,
    required this.totalDrinks,
    this.loadingProgress,
  });

  @override
  State<RetroLoadingWidget> createState() => _RetroLoadingWidgetState();
}

class _RetroLoadingWidgetState extends State<RetroLoadingWidget> {
  int _currentCount = 0;
  StreamSubscription? _progressSubscription;

  @override
  void initState() {
    super.initState();
    _listenToProgress();
  }

  void _listenToProgress() {
    if (widget.loadingProgress != null) {
      _progressSubscription = widget.loadingProgress!.listen(
        (count) {
          if (mounted) {
            setState(() {
              _currentCount = count;
            });
          }
        },
      );
    } else {
      _startSimulatedCounting();
    }
  }

  Future<void> _startSimulatedCounting() async {
    while (_currentCount < widget.totalDrinks && mounted) {
      await Future.delayed(const Duration(milliseconds: 50));
      setState(() {
        _currentCount++;
      });
    }
  }

  @override
  void dispose() {
    _progressSubscription?.cancel();
    super.dispose();
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
            color: Color(0xFF00FF00),
            fontWeight: FontWeight.bold,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Loading Cocktails...'),
              const SizedBox(height: 8),
              Text('[$_currentCount/${widget.totalDrinks}]'),
              const SizedBox(height: 8),
              Text(_currentCount >= widget.totalDrinks
                  ? 'Starting app...'
                  : 'Loading drinks from cache...'),
            ],
          ),
        ),
      ),
    );
  }
}
