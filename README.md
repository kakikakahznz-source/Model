# generate-image

هذه Edge Function تستقبل صورة وبرومبت من الموقع، وتستدعي OpenAI من الخادم. **لا تضع مفتاح OpenAI داخل `index.html` أو GitHub.**

## النشر

من مجلد المشروع، بعد تثبيت Supabase CLI وتسجيل الدخول:

```bash
supabase functions deploy generate-image
supabase secrets set OPENAI_API_KEY=ضع_مفتاح_OpenAI_هنا
```

أو اضبط السر من Supabase Dashboard → Edge Functions → Secrets.

بعد النشر، يستدعي الموقع:

```text
https://YOUR_PROJECT_REF.supabase.co/functions/v1/generate-image
```

## ملاحظات الإنتاج

- استخدم Supabase Auth أو نظام اشتراك خادمي قبل فتح الوظيفة للعامة.
- أضف rate limiting وحصة يومية حتى لا يُستهلك رصيد OpenAI بشكل غير مقصود.
- لا تنشر قيمة `OPENAI_API_KEY` في المستودع أو رسائل عامة.
