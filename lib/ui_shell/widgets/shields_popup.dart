import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaelix/core/privacy/shields_provider.dart';

class ShieldsPopup extends ConsumerWidget {
  const ShieldsPopup({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(shieldsCounterProvider);
    return AlertDialog(
      title: const Text('Shields'),
      content: Text('Blocked resources: $count'),
      actions: [
        TextButton(
          onPressed: () {
            ref.read(shieldsCounterProvider.notifier).reset();
            Navigator.of(context).pop();
          },
          child: const Text('Reset'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
