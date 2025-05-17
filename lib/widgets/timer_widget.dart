import 'package:flutter/material.dart';

class TimerWidget extends StatelessWidget {
  final Duration duration;
  final bool isRunning;
  final VoidCallback onStart;
  final VoidCallback onStop;
  final VoidCallback? onReset;

  const TimerWidget({
    super.key,
    required this.duration,
    required this.isRunning,
    required this.onStart,
    required this.onStop,
    this.onReset,
  });

  String get _formatted {
    final m = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          _formatted,
          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        isRunning
            ? ElevatedButton.icon(
              onPressed: onStop,
              icon: const Icon(Icons.stop),
              label: const Text('Selesai'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            )
            : ElevatedButton.icon(
              onPressed: onStart,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Mulai'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
        if (onReset != null)
          TextButton(onPressed: onReset, child: const Text('Reset')),
      ],
    );
  }
}
