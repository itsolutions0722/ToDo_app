import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/supabase_config.dart';
import 'pages/todo_list_page.dart';
import 'repositories/supabase_todo_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String? startupError;

  try {
    if (SupabaseConfig.isConfigured) {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        publishableKey: SupabaseConfig.publishableKey,
      );

      final repository = SupabaseTodoRepository(Supabase.instance.client);
      await repository.initializeAnonymousSession();
    }
  } catch (error) {
    startupError = 'Supabaseへ接続できませんでした。\n'
        'ネットワーク接続、Supabase URL、匿名ログインの有効状態を確認してください。\n\n'
        '$error';
  }

  runApp(MainApp(startupError: startupError));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key, this.startupError});

  final String? startupError;

  @override
  Widget build(BuildContext context) {
    if (!SupabaseConfig.isConfigured) {
      return const MaterialApp(home: _SupabaseSetupPage());
    }

    if (startupError != null) {
      return MaterialApp(
        title: 'ToDo管理',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        home: _SupabaseLoginErrorPage(error: startupError!),
      );
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

class _SupabaseLoginErrorPage extends StatelessWidget {
  const _SupabaseLoginErrorPage({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 56, color: Colors.redAccent),
              const SizedBox(height: 16),
              const Text(
                '匿名ログインに失敗しました。',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                error,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
