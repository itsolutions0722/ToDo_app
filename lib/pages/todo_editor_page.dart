import 'package:flutter/material.dart';

import '../models/todo_item.dart';
import '../utils/date_format.dart';

class TodoEditorPage extends StatefulWidget {
  const TodoEditorPage({super.key, this.todo});

  final TodoItem? todo;

  @override
  State<TodoEditorPage> createState() => _TodoEditorPageState();
}

class _TodoEditorPageState extends State<TodoEditorPage> {
  late final TextEditingController _titleController;
  late DateTime _entryDate;
  DateTime? _executionDate;
  late bool _isDone;

  bool get _isEditing => widget.todo != null;

  @override
  void initState() {
    super.initState();
    final todo = widget.todo;
    _titleController = TextEditingController(text: todo?.title ?? '');
    _entryDate = todo?.entryDate ?? DateTime.now();
    _executionDate = todo?.executionDate;
    _isDone = todo?.isDone ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickEntryDate() async {
    final picked = await _pickDate(_entryDate);
    if (picked != null) setState(() => _entryDate = picked);
  }

  Future<void> _pickExecutionDate() async {
    final picked = await _pickDate(_executionDate ?? _entryDate);
    if (picked != null) setState(() => _executionDate = picked);
  }

  Future<DateTime?> _pickDate(DateTime initialDate) {
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: '日付を選択',
      cancelText: 'キャンセル',
      confirmText: '決定',
    );
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ToDoを入力してください。')),
      );
      return;
    }
    Navigator.pop(
      context,
      TodoItem(
        id: widget.todo?.id,
        entryDate: _entryDate,
        executionDate: _executionDate,
        title: title,
        isDone: _isDone,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'ToDoを編集' : 'ToDoを新規作成'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          tooltip: '戻る',
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            onPressed: _save,
            tooltip: '保存',
            icon: const Icon(Icons.save_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Text('基本情報', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.edit_calendar),
            title: const Text('記入日'),
            subtitle: Text(formatDate(_entryDate)),
            trailing: const Icon(Icons.chevron_right),
            onTap: _pickEntryDate,
          ),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event_available),
            title: const Text('実施日'),
            subtitle: Text(
              _executionDate == null
                  ? '未設定'
                  : formatDate(_executionDate!),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_executionDate != null)
                  IconButton(
                    onPressed: () => setState(() => _executionDate = null),
                    tooltip: '実施日をクリア',
                    icon: const Icon(Icons.clear),
                  ),
                const Icon(Icons.chevron_right),
              ],
            ),
            onTap: _pickExecutionDate,
          ),
          const SizedBox(height: 24),
          Text('内容', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          TextField(
            controller: _titleController,
            autofocus: !_isEditing,
            minLines: 3,
            maxLines: 6,
            textInputAction: TextInputAction.newline,
            decoration: const InputDecoration(
              hintText: 'ToDoを入力',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('完了'),
            subtitle: const Text('チェック済みとして表示する'),
            value: _isDone,
            onChanged: (value) => setState(() => _isDone = value),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check),
            label: Text(_isEditing ? '更新する' : '作成する'),
          ),
        ],
      ),
    );
  }
}