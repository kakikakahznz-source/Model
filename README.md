# عارضتي | MyModel

موقع static لتحويل صور الملابس إلى جلسات تصوير بالذكاء الاصطناعي.

## تشغيل نسخة التجربة

```bash
python3 -m http.server 8787 --bind 0.0.0.0
```

ثم افتح `index.html`.

## ملاحظات أمنية مهمة

- حالة الاشتراك لا تُقبل من `localStorage` أو من معاملات URL. يجب أن تأتي من تحقق مركزي عبر Supabase.
- لوحة الإدارة معطّلة في النسخة static؛ لا تضع رمز إدارة داخل HTML أو JavaScript. لإعادتها، استخدم Supabase Auth/Edge Functions وRLS، ثم اجعل المتصفح يستعمل جلسة مصادقة لا سرًا مشتركًا.
- يجب تفعيل RLS ومنع القراءة العامة لجداول `subscribers`, `messages`, و`payment_claims`.
- يجب التحقق من PayPal عبر webhook خادمي قبل تفعيل أي اشتراك.
- هذه النسخة مناسبة للتجربة التقنية، وليست بديلًا عن backend آمن لمعالجة المدفوعات.

## Google Flow

يتم عرض واجهة Flow داخل modal ومحاولة تحميلها داخل iframe. حاليًا يمنع Google هذا التضمين عبر `X-Frame-Options: SAMEORIGIN`، لذلك تظهر آليًا رسالة fallback مع خيار المتابعة في نفس الصفحة، دون فتح نافذة جديدة. لا يمكن تجاوز هذه الحماية من JavaScript بأمان.

## لوحة الإدارة الآمنة

صفحة `admin.html` تستخدم Supabase Auth بالبريد وكلمة المرور، ثم تتحقق من وجود المستخدم في `public.admin_users` عبر `public.is_admin()`. لا يوجد رمز إدارة ثابت داخل الواجهة.

قبل تسجيل الدخول، نفّذ الملف `supabase_admin_auth.sql` في Supabase SQL Editor، ثم أضف User UID إلى `public.admin_users`. لا تعِد إضافة أي دالة تقبل `p_code`.
