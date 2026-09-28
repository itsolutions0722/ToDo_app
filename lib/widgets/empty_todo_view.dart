import 'package:flutter/material.dart';

class EmptyTodoView extends StatelessWidget {
  const EmptyTodoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.checklist, size: 64, color: Colors.indigo.shade200),
            const SizedBox(height: 16),
            Text(
              'ToDoはまだありません',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text('右下の「新規作成」から登録できます。'),
          ],
        ),
      ),
    );
  }
}