import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/todo_item.dart';
import '../repositories/supabase_todo_repository.dart';
import '../widgets/empty_todo_view.dart';
import '../widgets/todo_card.dart';
import 'todo_editor_page.dart';

enum TodoFilter { all, pending, done }

enum TodoSortOrder { newestFirst, oldestFirst }

List<TodoItem> filterTodos(List<TodoItem> todos, TodoFilter filter) {
  switch (filter) {
    case TodoFilter.all:
      return [...todos];
    case TodoFilter.pending:
      return todos.where((todo) => !todo.isDone).toList();
    case TodoFilter.done:
      return todos.where((todo) => todo.isDone).toList();
  }
}

List<TodoItem> sortTodosByEntryDate(List<TodoItem> todos, bool oldestFirst) {
  final sorted = [...todos];
  sorted.sort((a, b) {
    return oldestFirst
        ? a.entryDate.compareTo(b.entryDate)
        : b.entryDate.compareTo(a.entryDate);
  });
  return sorted;
}

List<TodoItem> removeCompletedTodos(List<TodoItem> todos) {
  return todos.where((todo) => !todo.isDone).toList();
}

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
  TodoFilter _selectedFilter = TodoFilter.pending;
  TodoSortOrder _sortOrder = TodoSortOrder.newestFirst;

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
      if (!widget.repository.isSignedIn) {
        throw StateError('ログインが必要です。Googleログインを行ってください。');
      }

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

  Future<void> _signOut() async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ログアウト'),
        content: const Text('この端末からログアウトしますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ログアウト'),
          ),
        ],
      ),
    );

    if (shouldSignOut != true || !mounted) {
      return;
    }

    try {
      await Supabase.instance.client.auth.signOut();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ログアウトしました。')),
        );
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ログアウトに失敗しました: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Supabase.instance.client.auth.currentUser;
    final currentUserEmail = currentUser?.email?.trim() ?? '';
    final avatarLetter = currentUserEmail.isNotEmpty
        ? currentUserEmail[0].toUpperCase()
        : 'T';
    final sortedTodos = sortTodosByEntryDate(
      _todos,
      _sortOrder == TodoSortOrder.oldestFirst,
    );
    final filteredTodos = filterTodos(sortedTodos, _selectedFilter);

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
      drawer: Drawer(
        child: Container(
          color: const Color(0xFFF2F2F7),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                accountName: const Text('ToDo管理'),
                accountEmail: Text(currentUserEmail.isNotEmpty
                    ? currentUserEmail
                    : '未ログイン'),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    avatarLetter,
                    style: const TextStyle(color: Colors.indigo),
                  ),
                ),
                decoration: const BoxDecoration(
                  color: Colors.indigo,
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildSettingsTile(
                      icon: Icons.arrow_downward,
                      title: '記入日順（新しい順）',
                      selected: _sortOrder == TodoSortOrder.newestFirst,
                      onTap: () {
                        setState(() => _sortOrder = TodoSortOrder.newestFirst);
                        Navigator.of(context).pop();
                      },
                    ),
                    _buildSettingsTile(
                      icon: Icons.arrow_upward,
                      title: '記入日順（古い順）',
                      selected: _sortOrder == TodoSortOrder.oldestFirst,
                      onTap: () {
                        setState(() => _sortOrder = TodoSortOrder.oldestFirst);
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _buildSettingsTile(
                  icon: Icons.delete_sweep_outlined,
                  title: '完了済みを一括削除',
                  isDestructive: true,
                  onTap: () async {
                    Navigator.of(context).pop();
                    await _deleteCompletedTodos();
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _buildSettingsTile(
                  icon: Icons.logout,
                  title: 'ログアウト',
                  isDestructive: true,
                  onTap: () async {
                    Navigator.of(context).pop();
                    await _signOut();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        leading: Builder(
          builder: (context) {
            return IconButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              tooltip: 'メニュー',
              icon: const Icon(Icons.menu),
            );
          },
        ),
        title: const Text('ToDo管理'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Chip(
              avatar: const Icon(Icons.verified_user, size: 16),
              label: Text(
                currentUserEmail.isNotEmpty ? currentUserEmail : '未ログイン',
              ),
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            ),
          ),
          IconButton(
            onPressed: _createTodo,
            tooltip: '新規作成',
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Wrap(
              spacing: 8,
              children: TodoFilter.values.map((filter) {
                final isSelected = _selectedFilter == filter;
                return ChoiceChip(
                  label: Text(_filterLabel(filter)),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _selectedFilter = filter),
                  selectedColor: Theme.of(context).colorScheme.primaryContainer,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? Theme.of(context).colorScheme.onPrimaryContainer
                        : null,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: filteredTodos.isEmpty
                ? EmptyTodoView(
                    message: _selectedFilter == TodoFilter.all
                        ? 'ToDoはまだありません'
                        : '条件に一致するToDoはありません',
                    description: _selectedFilter == TodoFilter.all
                        ? '右下の「新規作成」から登録できます。'
                        : '別の絞り込み条件を試してください。',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                    itemCount: filteredTodos.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final todo = filteredTodos[index];
                      return TodoCard(
                        todo: todo,
                        onChanged: (value) => _toggleTodo(todo, value),
                        onTap: () => _editTodo(todo),
                        onDelete: () => _deleteTodo(todo),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createTodo,
        icon: const Icon(Icons.add),
        label: const Text('新規作成'),
      ),
    );
  }

  String _filterLabel(TodoFilter filter) {
    switch (filter) {
      case TodoFilter.all:
        return 'すべて';
      case TodoFilter.pending:
        return '未完了';
      case TodoFilter.done:
        return '完了';
    }
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    bool selected = false,
    bool isDestructive = false,
    bool showChevron = true,
    required VoidCallback onTap,
  }) {
    final color = isDestructive ? Colors.red : const Color(0xFF1C1C1E);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 28,
              alignment: Alignment.center,
              child: Icon(icon, size: 22, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: color,
                ),
              ),
            ),
            if (showChevron)
              Icon(
                selected ? Icons.check : Icons.chevron_right,
                color: selected ? Colors.blue : Colors.grey.shade500,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleTodo(TodoItem todo, bool value) async {
    final previousValue = todo.isDone;
    setState(() => todo.isDone = value);
    try {
  widget.repository.updateTodo(todo);
    } catch (error) {
      if (!mounted) return;
      setState(() => todo.isDone = previousValue);
      _showError(error);
    }
  }

  Future<void> _deleteCompletedTodos() async {
    final completedTodos = _todos.where((todo) => todo.isDone).toList();
    if (completedTodos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('完了済みのToDoはありません。')),
      );
      return;
    }

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('完了済みを一括削除'),
        content: Text('${completedTodos.length}件の完了済みToDoを削除しますか？'),
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

    if (shouldDelete != true || !mounted) {
      return;
    }

    try {
      final targetIds = completedTodos
          .where((todo) => todo.id != null)
          .map((todo) => todo.id!)
          .toList();

      for (final id in targetIds) {
        await widget.repository.deleteTodo(
          completedTodos.firstWhere((todo) => todo.id == id),
        );
      }

      if (mounted) {
        setState(() => _todos.removeWhere((todo) => todo.isDone));
      }
    } catch (error) {
      if (mounted) _showError(error);
    }
  }
}