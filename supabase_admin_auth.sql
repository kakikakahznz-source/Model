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

-- =========================================================
-- تفعيل طلب بريدي موب يدويًا من لوحة الإدارة فقط
-- =========================================================

alter table public.payment_claims
  add column if not exists reviewed_at timestamptz,
  add column if not exists reviewed_by uuid references auth.users(id);

create or replace function public.approve_payment_claim(p_id uuid)
returns boolean
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_email text;
  v_ref text;
  v_device text;
  v_registered boolean;
begin
  if auth.uid() is null or not exists (
    select 1 from public.admin_users
    where user_id = auth.uid() and active = true
  ) then
    raise exception 'Admin access required' using errcode = '42501';
  end if;

  select email, tx_ref, device_id
    into v_email, v_ref, v_device
  from public.payment_claims
  where id = p_id and status = 'pending'
  for update;

  if v_email is null then
    raise exception 'Pending payment claim not found' using errcode = 'P0002';
  end if;

  -- استعمال دالة التسجيل الموجودة في المشروع، ثم جعل الحالة active مركزيًا.
  perform public.register_subscriber(
    v_email, '', '', 'transfer', '3500 DZD', v_ref, v_device
  );

  update public.subscribers
  set status = 'active'
  where email = v_email;

  update public.payment_claims
  set status = 'approved', reviewed_at = now(), reviewed_by = auth.uid()
  where id = p_id;

  return true;
end;
$$;

revoke all on function public.approve_payment_claim(uuid) from public;
revoke all on function public.approve_payment_claim(uuid) from anon;
grant execute on function public.approve_payment_claim(uuid) to authenticated;
