# نشر الموقع على GitHub Pages وSupabase

1. ارفع ملفات الموقع إلى GitHub Pages.
2. نفّذ `supabase_admin_auth.sql` بعد استبدال `YOUR_ADMIN_USER_UUID`.
3. انشر الوظيفة من مجلد المشروع:

```bash
supabase functions deploy generate-image
supabase secrets set OPENAI_API_KEY=ضع_مفتاح_OpenAI_هنا
```

لا تضع مفتاح OpenAI داخل `index.html` أو GitHub. الواجهة تستخدم الخانات داخل الموقع، والوظيفة الخادمية تستدعي OpenAI.
