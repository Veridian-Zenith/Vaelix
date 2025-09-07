import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search or enter address',
                prefixIcon: Icon(Icons.search),
              ),
              onSubmitted: (q) {
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
