import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/config/supabase_config.dart';

void main() {
  test('Google OAuth uses a custom app scheme callback URL', () {
    expect(SupabaseConfig.redirectUrl, 'io.supabase.todoapp://login-callback');
  });
}
