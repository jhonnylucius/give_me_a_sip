import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

class RetroLoadingWidget extends StatefulWidget {
  final int totalDrinks;
  final Stream<int>? loadingProgress;

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
  final int _speedFactor =
      2; // Fator de velocidade - ajuste conforme necessário
  final int _baseInterval = 40; // Intervalo base em millisegundos

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
            setState(() => _currentCount = count);
          }
        },
      );
    } else {
      _startSimulatedCounting();
    }
  }

  Future<void> _startSimulatedCounting() async {
    while (_currentCount < widget.totalDrinks && mounted) {
      await Future.delayed(Duration(milliseconds: _baseInterval));
      if (mounted) {
        setState(() {
          _currentCount =
              math.min(_currentCount + _speedFactor, widget.totalDrinks);
        });
      }
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
              const Text('Loading Cocktails...'),
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
