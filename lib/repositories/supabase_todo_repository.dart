import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/todo_item.dart';

class SupabaseTodoRepository {
  SupabaseTodoRepository(this._client);

  final SupabaseClient _client;

  Future<void> initializeAnonymousSession() async {
    if (_client.auth.currentUser == null) {
      await _client.auth.signInAnonymously();
    }
  }

  Future<List<TodoItem>> fetchTodos() async {
    final rows = await _client
        .from('todos')
        .select('id, entry_date, execution_date, title, is_done')
        .order('entry_date', ascending: false);

    return (rows as List)
        .map((row) => TodoItem.fromMap(Map<String, dynamic>.from(row)))
        .toList();
  }

  Future<TodoItem> createTodo(TodoItem todo) async {
    final row = await _client
        .from('todos')
        .insert({
          'user_id': _userId,
          'entry_date': _dateValue(todo.entryDate),
          'execution_date': todo.executionDate == null
              ? null
              : _dateValue(todo.executionDate!),
          'title': todo.title,
          'is_done': todo.isDone,
        })
        .select('id, entry_date, execution_date, title, is_done')
        .single();

    return TodoItem.fromMap(Map<String, dynamic>.from(row));
  }

  Future<TodoItem> updateTodo(TodoItem todo) async {
    final id = todo.id;
    if (id == null) {
      throw StateError('更新対象のToDo IDがありません。');
    }

    final row = await _client
        .from('todos')
        .update({
          'entry_date': _dateValue(todo.entryDate),
          'execution_date': todo.executionDate == null
              ? null
              : _dateValue(todo.executionDate!),
          'title': todo.title,
          'is_done': todo.isDone,
        })
        .eq('id', id)
        .select('id, entry_date, execution_date, title, is_done')
        .single();

    return TodoItem.fromMap(Map<String, dynamic>.from(row));
  }

  Future<void> deleteTodo(TodoItem todo) async {
    final id = todo.id;
    if (id == null) {
      throw StateError('削除対象のToDo IDがありません。');
    }
    await _client.from('todos').delete().eq('id', id);
  }

  String get _userId {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('匿名認証のセッションがありません。');
    }
    return userId;
  }

  String _dateValue(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}