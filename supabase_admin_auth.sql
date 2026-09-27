begin;

-- تحقق خادمي من أن المستخدم الحالي موجود في قائمة المشرفين.
create or replace function public.is_admin()
returns boolean
language sql
security definer
set search_path = public, pg_temp
as $$
  select exists (
    select 1
    from public.admin_users
    where user_id = auth.uid()
      and active = true
  );
$$;

revoke all on function public.is_admin() from public;
grant execute on function public.is_admin() to authenticated;

-- القراءة الإدارية تتم فقط بعد تسجيل دخول مستخدم موجود في admin_users.
alter table public.messages enable row level security;
alter table public.payment_claims enable row level security;

 drop policy if exists admin_read_messages on public.messages;
create policy admin_read_messages
on public.messages for select to authenticated
using (public.is_admin());

 drop policy if exists admin_read_payment_claims on public.payment_claims;
create policy admin_read_payment_claims
on public.payment_claims for select to authenticated
using (public.is_admin());

-- الدالة delete_message(uuid) التي نفذتها سابقًا هي المسؤولة عن الحذف.
-- لا تعِد إضافة نسخة تقبل p_code أو كلمة مرور.

commit;
