import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RetroLoadingWidget extends StatefulWidget {
  final int totalDrinks;
  final Stream<int>? loadingProgress;
  final bool showCounter;

  const RetroLoadingWidget({
    super.key,
    required this.totalDrinks,
    this.loadingProgress,
    required this.showCounter,
  });

  @override
  State<RetroLoadingWidget> createState() => _RetroLoadingWidgetState();
}

class _RetroLoadingWidgetState extends State<RetroLoadingWidget> {
  int _currentCount = 0;
  StreamSubscription? _progressSubscription;
  final int _speedFactor = 5;
  final int _baseInterval = 30;
  bool _showRetro = true;

  @override
  void initState() {
    super.initState();
    _checkIfFirstRun();
  }

  Future<void> _checkIfFirstRun() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstRun = prefs.getBool('first_run') ?? true;

    setState(() {
      _showRetro = isFirstRun;
    });

    if (isFirstRun) {
      await prefs.setBool('first_run', false);
      _listenToProgress();
    } else {
      // Simula o loading sem o efeito retro
      _simulateLoadingWithoutRetro();
    }
  }

  Future<void> _simulateLoadingWithoutRetro() async {
    while (_currentCount < widget.totalDrinks && mounted) {
      await Future.delayed(
          const Duration(milliseconds: 2000)); // Intervalo mais curto
      if (mounted) {
        setState(() {
          _currentCount = math.min(
              _currentCount, widget.totalDrinks); // Aumenta mais rápido
        });
      }
    }
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

        if (_currentCount >= widget.totalDrinks) {
          await Future.delayed(const Duration(milliseconds: 2000));
        }
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
            fontSize: 14,
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
              if (_showRetro)
                Text(_currentCount >= widget.totalDrinks
                    ? 'Starting app...'
                    : '')
            ],
          ),
        ),
      ),
    );
  }
}
