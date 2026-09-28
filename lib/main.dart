import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/supabase_config.dart';
import 'pages/todo_list_page.dart';
import 'repositories/supabase_todo_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (SupabaseConfig.isConfigured) {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.publishableKey,
    );
  }
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    if (!SupabaseConfig.isConfigured) {
      return const MaterialApp(home: _SupabaseSetupPage());
    }

    return MaterialApp(
      title: 'ToDo管理',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: TodoListPage(
        repository: SupabaseTodoRepository(Supabase.instance.client),
      ),
    );
  }
}

class _SupabaseSetupPage extends StatelessWidget {
  const _SupabaseSetupPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Supabaseの接続情報が設定されていません。\n'
            'SUPABASE_URL と SUPABASE_PUBLISHABLE_KEY を --dart-define で設定してください。',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
