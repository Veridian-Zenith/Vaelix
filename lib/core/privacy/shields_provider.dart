import 'package:flutter_riverpod/flutter_riverpod.dart';

final shieldsCounterProvider =
    StateNotifierProvider<ShieldsCounterNotifier, int>((ref) {
      return ShieldsCounterNotifier();
    });

class ShieldsCounterNotifier extends StateNotifier<int> {
  ShieldsCounterNotifier() : super(0);

  void increment() => state = state + 1;

  void reset() => state = 0;
}
