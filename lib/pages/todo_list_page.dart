import 'package:flutter/material.dart';

import '../models/todo_item.dart';
import '../repositories/supabase_todo_repository.dart';
import '../widgets/empty_todo_view.dart';
import '../widgets/todo_card.dart';
import 'todo_editor_page.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key, required this.repository});

  final SupabaseTodoRepository repository;

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final List<TodoItem> _todos = [];
  bool _isLoading = true;
  Object? _loadError;

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      await widget.repository.initializeAnonymousSession();
      final todos = await widget.repository.fetchTodos();
      if (!mounted) return;
      setState(() {
        _todos
          ..clear()
          ..addAll(todos);
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error;
        _isLoading = false;
      });
    }
  }

  void _showError(Object error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('保存に失敗しました: $error')),
    );
  }

  Future<void> _createTodo() async {
    final todo = await Navigator.of(context).push<TodoItem>(
      MaterialPageRoute(builder: (_) => const TodoEditorPage()),
    );
    if (todo != null && mounted) {
      try {
        final savedTodo = await widget.repository.createTodo(todo);
        if (mounted) setState(() => _todos.add(savedTodo));
      } catch (error) {
        if (mounted) _showError(error);
      }
    }
  }

  Future<void> _editTodo(TodoItem todo) async {
    final updatedTodo = await Navigator.of(context).push<TodoItem>(
      MaterialPageRoute(builder: (_) => TodoEditorPage(todo: todo)),
    );
    if (updatedTodo != null && mounted) {
      try {
        final savedTodo = await widget.repository.updateTodo(updatedTodo);
        if (mounted) {
          setState(() {
            final index = _todos.indexOf(todo);
            if (index != -1) _todos[index] = savedTodo;
          });
        }
      } catch (error) {
        if (mounted) _showError(error);
      }
    }
  }

  Future<void> _deleteTodo(TodoItem todo) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ToDoを削除'),
        content: const Text('このToDoを削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('削除'),
          ),
        ],
      ),
    );
    if (shouldDelete == true && mounted) {
      try {
        await widget.repository.deleteTodo(todo);
        if (mounted) setState(() => _todos.remove(todo));
      } catch (error) {
        if (mounted) _showError(error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortedTodos = [..._todos]
      ..sort((a, b) => b.entryDate.compareTo(a.entryDate));

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_loadError != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('ToDo管理')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('SupabaseからToDoを読み込めませんでした。'),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _loadTodos,
                  icon: const Icon(Icons.refresh),
                  label: const Text('再読み込み'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('ToDo管理'),
        actions: [
          IconButton(
            onPressed: _createTodo,
            tooltip: '新規作成',
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: sortedTodos.isEmpty
          ? const EmptyTodoView()
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: sortedTodos.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final todo = sortedTodos[index];
                return TodoCard(
                  todo: todo,
                  onChanged: (value) => _toggleTodo(todo, value),
                  onTap: () => _editTodo(todo),
                  onDelete: () => _deleteTodo(todo),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createTodo,
        icon: const Icon(Icons.add),
        label: const Text('新規作成'),
      ),
    );
  }

  Future<void> _toggleTodo(TodoItem todo, bool value) async {
    final previousValue = todo.isDone;
    setState(() => todo.isDone = value);
    try {
      await widget.repository.updateTodo(todo);
    } catch (error) {
      if (!mounted) return;
      setState(() => todo.isDone = previousValue);
      _showError(error);
    }
  }
}