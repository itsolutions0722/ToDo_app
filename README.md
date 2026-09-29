# todo_app

## Supabase設定

1. Supabaseプロジェクトを作成し、Authenticationの Google OAuth を有効にする。
2. Authentication > URL Configuration で以下の Redirect URL を追加する。

```text
io.supabase.todoapp://login-callback
```

3. SQL Editorで以下を実行する。

```sql
create table public.todos (
	id uuid primary key default gen_random_uuid(),
	user_id uuid not null references auth.users(id) on delete cascade,
	entry_date date not null,
	execution_date date,
	title text not null,
	is_done boolean not null default false,
	created_at timestamptz not null default now()
);

alter table public.todos enable row level security;

create policy "Users can read their own todos"
on public.todos for select
using ((select auth.uid()) = user_id);

create policy "Users can create their own todos"
on public.todos for insert
with check ((select auth.uid()) = user_id);

create policy "Users can update their own todos"
on public.todos for update
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

create policy "Users can delete their own todos"
on public.todos for delete
using ((select auth.uid()) = user_id);
```

4. URL、公開Publishable Key、Redirect URL を指定して起動する。

```powershell
flutter run --dart-define=SUPABASE_URL=https://hszymxdacwqeyjlwlydc.supabase.co --dart-define=SUPABASE_PUBLISHABLE_KEY=sb_publishable_duFnruWcV1QlM54_LXPOow_JeKOSrOR --dart-define=SUPABASE_REDIRECT_URL=io.supabase.todoapp://login-callback
```

VS Codeの実行ボタンを使う場合は、`.vscode/launch.json` の値を自分のSupabaseプロジェクトの値に変更し、実行構成 `todo_app (Supabase)` を選択する。

Googleログイン後のセッションはSupabase Flutter SDKが端末内に保持し、別端末でも同じ Google アカウントでログインできるようになります。
