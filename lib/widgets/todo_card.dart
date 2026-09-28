import 'package:flutter/material.dart';

import '../models/todo_item.dart';
import '../utils/date_format.dart';

class TodoCard extends StatelessWidget {
  const TodoCard({
    super.key,
    required this.todo,
    required this.onChanged,
    required this.onTap,
    required this.onDelete,
  });

  final TodoItem todo;
  final ValueChanged<bool> onChanged;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 12, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: todo.isDone,
                onChanged: (value) => onChanged(value ?? false),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        todo.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              decoration: todo.isDone
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: todo.isDone ? Colors.grey : null,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text('記入日  ${formatDate(todo.entryDate)}'),
                      Text(
                        '実施日  ${todo.executionDate == null ? '未設定' : formatDate(todo.executionDate!)}',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                onPressed: onDelete,
                tooltip: '削除',
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        ),
      ),
    );
  }
}