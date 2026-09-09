BEGIN;

-- Keep the web client compatible with instances that do not have a membership
-- billing schema. The frontend calls get_my_membership_overview() on every
-- authenticated session; without this stub PostgREST answers PGRST202
-- ("Could not find the function ... in the schema cache"). A future
-- membership module can replace the inactive response without changing the
-- RPC contract expected by membershipOverviewRepository.js.
create or replace function public.get_my_membership_overview()
returns jsonb
language sql
stable
security definer
set search_path = public
as $$
  select jsonb_build_object(
    'status', 'inactive',
    'tier', null,
    'supporter_since', null,
    'provider_connected', false,
    'subscription_access_active', false,
    'membership_level', null,
    'current_period_end', null,
    'cancels_at_period_end', false,
    'has_active_grant', false,
    'grant_is_lifetime', false,
    'grant_expires_at', null,
    'grant_kind', null,
    'grant_tier', null,
    'has_lifetime_grant', false,
    'lifetime_grant_tier', null
  );
$$;

revoke all on function public.get_my_membership_overview() from public;
grant execute on function public.get_my_membership_overview() to authenticated;

-- Existing PostgREST containers should expose the new RPC (and the
-- get_my_member_access() RPC from migration 11, which had no reload
-- notification) immediately after an upgrade, without requiring operators
-- to restart the stack.
NOTIFY pgrst, 'reload schema';

INSERT INTO nuvio_migrations.schema_migrations (version)
VALUES ('00000000000012')
ON CONFLICT (version) DO NOTHING;

COMMIT;
