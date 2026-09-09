-- Keep the web client compatible with self-hosted instances that do not have
-- a membership billing schema. A future membership module can replace the
-- empty response without changing the RPC contract.
create or replace function public.get_my_member_access()
returns jsonb
language sql
stable
security definer
set search_path = public
as $$
  select jsonb_build_object(
    'tier', null,
    'entitlements', '[]'::jsonb
  );
$$;

revoke all on function public.get_my_member_access() from public;
grant execute on function public.get_my_member_access() to authenticated;
