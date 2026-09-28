import 'package:flutter/material.dart';

class EmptyTodoView extends StatelessWidget {
  const EmptyTodoView({
    super.key,
    this.message = 'ToDoはまだありません',
    this.description = '右下の「新規作成」から登録できます。',
  });

  final String message;
  final String description;

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
              message,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(description),
          ],
        ),
      ),
    );
  }
}