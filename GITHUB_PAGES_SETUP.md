# نشر الموقع على GitHub Pages

1. ارفع محتويات هذه الحزمة إلى المستودع.
2. من GitHub افتح **Settings → Pages**.
3. في **Build and deployment** اختر **Deploy from a branch**.
4. اختر فرع `main` والمجلد `/ (root)` ثم اضغط **Save**.
5. قبل استخدام لوحة الإدارة، نفّذ `supabase_admin_auth.sql` في Supabase بعد استبدال `YOUR_ADMIN_USER_UUID` بمعرّف مستخدم الإدارة.

> لا تضع كلمات مرور Supabase داخل الملفات. تسجيل الدخول يتم عبر Supabase Auth من صفحة `admin.html`.
