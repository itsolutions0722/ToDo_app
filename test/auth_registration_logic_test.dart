import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/pages/auth_page.dart';

void main() {
  test('未登録アカウントの認証エラーは新規登録候補として扱う', () {
    expect(shouldOfferSignUp('Invalid login credentials'), isTrue);
    expect(shouldOfferSignUp('User not found'), isTrue);
    expect(shouldOfferSignUp('メールアドレスまたはパスワードが違います'), isTrue);
    expect(shouldOfferSignUp('Network request failed'), isFalse);
  });
}
