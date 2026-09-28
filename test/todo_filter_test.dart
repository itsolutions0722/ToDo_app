import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/models/todo_item.dart';
import 'package:todo_app/pages/todo_list_page.dart';

void main() {
  group('Todo filter', () {
    final todos = [
      TodoItem(
        title: '買い物',
        entryDate: DateTime(2026, 9, 1),
        isDone: false,
      ),
      TodoItem(
        title: '会議資料',
        entryDate: DateTime(2026, 9, 2),
        isDone: true,
      ),
      TodoItem(
        title: '掃除',
        entryDate: DateTime(2026, 9, 3),
        isDone: false,
      ),
    ];

    test('すべてを返す', () {
      final filtered = filterTodos(todos, TodoFilter.all);

      expect(filtered.length, 3);
      expect(filtered.map((todo) => todo.title), ['買い物', '会議資料', '掃除']);
    });

    test('未実施のみを返す', () {
      final filtered = filterTodos(todos, TodoFilter.pending);

      expect(filtered.length, 2);
      expect(filtered.every((todo) => !todo.isDone), isTrue);
    });

    test('完了のみを返す', () {
      final filtered = filterTodos(todos, TodoFilter.done);

      expect(filtered.length, 1);
      expect(filtered.single.isDone, isTrue);
      expect(filtered.single.title, '会議資料');
    });

    test('記入日順で新しい順に並ぶ', () {
      final ordered = sortTodosByEntryDate(todos, false);

      expect(ordered.map((todo) => todo.title), ['掃除', '会議資料', '買い物']);
    });

    test('記入日順で古い順に並ぶ', () {
      final ordered = sortTodosByEntryDate(todos, true);

      expect(ordered.map((todo) => todo.title), ['買い物', '会議資料', '掃除']);
    });

    test('完了済みを一括削除できる', () {
      final remaining = removeCompletedTodos(todos);

      expect(remaining.length, 2);
      expect(remaining.every((todo) => !todo.isDone), isTrue);
    });
  });
}
