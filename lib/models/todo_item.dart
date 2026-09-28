class TodoItem {
  TodoItem({
    this.id,
    required this.entryDate,
    this.executionDate,
    required this.title,
    this.isDone = false,
  });

  String? id;
  DateTime entryDate;
  DateTime? executionDate;
  String title;
  bool isDone;

  factory TodoItem.fromMap(Map<String, dynamic> map) {
    return TodoItem(
      id: map['id'] as String?,
      entryDate: DateTime.parse(map['entry_date'] as String),
      executionDate: map['execution_date'] == null
          ? null
          : DateTime.parse(map['execution_date'] as String),
      title: map['title'] as String,
      isDone: map['is_done'] as bool? ?? false,
    );
  }
}