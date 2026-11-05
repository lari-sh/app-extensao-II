import { createClient } from '@supabase/supabase-js';

type Actor = { id: string; session: string; exp: number };
type Json = Record<string, unknown>;
export interface InvitationDependencies {
  authenticate(token: string): Promise<Actor | null>;
  reserve(actor: Actor, key: string, command: string, payload: Json): Promise<Json>;
  finish(actor: Actor, key: string, delivery: string, userId?: string, code?: string): Promise<Json>;
  send(email: string): Promise<{ userId?: string; code?: string }>;
}
export class InvitationError extends Error {
  constructor(public status: number, public code: string) { super(code); }
}
const headers = {
  'Cache-Control': 'no-store, private', 'Content-Type': 'application/json',
  'Access-Control-Allow-Origin': '*', 'Access-Control-Allow-Headers': 'authorization, apikey, content-type',
  'Access-Control-Allow-Methods': 'GET, POST, OPTIONS', 'X-Content-Type-Options': 'nosniff',
};
const reply = (value: unknown, status = 200) => new Response(JSON.stringify(value), { status, headers });
const validKey = (value: unknown): value is string => typeof value === 'string' && /^[A-Za-z0-9_-]{16,128}$/.test(value);
const uuid = (value: unknown): value is string => typeof value === 'string' && /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(value);

async function body(request: Request): Promise<Json> {
  if (!request.headers.get('content-type')?.startsWith('application/json')) throw new InvitationError(400, 'invalid_input');
  if (Number(request.headers.get('content-length') || 0) > 4096) throw new InvitationError(413, 'body_size');
  const reader = request.body?.getReader();
  if (!reader) throw new InvitationError(400, 'invalid_input');
  const chunks: Uint8Array[] = []; let size = 0;
  try {
    while (true) {
      const { value, done } = await reader.read(); if (done) break;
      size += value.length;
      if (size > 4096) { await reader.cancel(); throw new InvitationError(413, 'body_size'); }
      chunks.push(value);
    }
  } finally { reader.releaseLock(); }
  const bytes = new Uint8Array(size); let offset = 0;
  for (const chunk of chunks) { bytes.set(chunk, offset); offset += chunk.length; }
  try {
    const result = JSON.parse(new TextDecoder().decode(bytes));
    if (!result || Array.isArray(result) || typeof result !== 'object') throw 0;
    return result;
  } catch { throw new InvitationError(400, 'invalid_input'); }
}
function rpcFailure(error: { code?: string; message?: string }): InvitationError {
  const permitted = new Set(['administrator_required', 'operation_conflict', 'existing_account', 'already_member',
    'invitation_exists', 'invitation_version_conflict', 'invitation_unavailable', 'invitation_opened',
    'invitation_cooldown', 'invitation_rate_limited', 'invalid_invitation_input', 'operation_not_found']);
  return new InvitationError(error.code === '42501' ? 403 : error.code === 'PT409' ? 409 :
    error.code === 'PT429' ? 429 : error.code === 'PT404' ? 404 : error.code === '22023' || error.code === '22P02' ? 400 : 503,
    permitted.has(error.message || '') ? error.message! : 'operation_unavailable');
}

function dependencies(): InvitationDependencies {
  const url = Deno.env.get('SUPABASE_URL'), anon = Deno.env.get('SUPABASE_ANON_KEY'), key = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
  if (!url || !anon || !key) throw new InvitationError(503, 'configuration');
  const options = { auth: { persistSession: false, autoRefreshToken: false } };
  const admin = createClient(url, key, { ...options, global: {
    fetch: (input, init) => fetch(input, { ...init, signal: AbortSignal.timeout(15000) }),
  } });
  const params = (actor: Actor, operationKey: string) => ({ p_actor_id: actor.id, p_session_id: actor.session,
    p_jwt_exp: actor.exp, p_operation_key: operationKey });
  return {
    async authenticate(token) {
      const client = createClient(url, anon, { ...options, global: { headers: { Authorization: 'Bearer ' + token } } });
      const verified = await client.auth.getUser(token);
      if (verified.error || !verified.data.user) return null;
      const context = await client.rpc('access_context');
      if (context.error || !context.data?.is_session_current || !context.data?.can_manage_team || context.data?.staff_role !== 'administrator') throw new InvitationError(403, 'administrator_required');
      // JWT contents are used only after the Auth server verified that token.
      let claims;
      try { claims = JSON.parse(atob(token.split('.')[1].replaceAll('-', '+').replaceAll('_', '/'))); }
      catch { return null; }
      if (!uuid(claims.session_id) || typeof claims.exp !== 'number' || !Number.isFinite(claims.exp) || claims.exp <= Date.now() / 1000) return null;
      return { id: verified.data.user.id, session: claims.session_id, exp: claims.exp };
    },
    async reserve(actor, operationKey, command, payload) {
      const result = await admin.rpc('reserve_team_invitation', { ...params(actor, operationKey), p_command: command, p_payload: payload });
      if (result.error) throw rpcFailure(result.error); return result.data;
    },
    async finish(actor, operationKey, delivery, userId, code) {
      const result = await admin.rpc('finish_team_invitation', { ...params(actor, operationKey), p_delivery: delivery,
        p_auth_user_id: userId || null, p_error_code: code || null });
      if (result.error) throw rpcFailure(result.error); return result.data;
    },
    async send(email) {
      const result = await admin.auth.admin.inviteUserByEmail(email, {
        redirectTo: 'br.org.abrigodosanjos.app://auth/invite',
      });
      if (result.error) {
        if ([429].includes(result.error.status || 0)) return { code: 'rate_limited' };
        if (['email_exists', 'user_already_exists'].includes(result.error.code || '')) return { code: 'existing_account' };
        // Auth fetch/timeouts may have succeeded upstream: do not resend blindly.
        if (result.error.name === 'AuthRetryableFetchError' || !result.error.status || result.error.status >= 500) throw new InvitationError(503, 'send_uncertain');
        return { code: 'send_failed' };
      }
      if (!result.data.user?.id) throw new InvitationError(503, 'send_uncertain');
      return { userId: result.data.user.id };
    },
  };
}

export async function teamInvitation(request: Request, injected?: InvitationDependencies): Promise<Response> {
  if (request.method === 'OPTIONS') return new Response(null, { status: 204, headers });
  if (!['GET', 'POST'].includes(request.method)) return reply({ code: 'method_not_allowed' }, 405);
  try {
    const token = request.headers.get('authorization')?.replace(/^Bearer\s+/i, '');
    if (!token) return reply({ code: 'unauthenticated' }, 401);
    const deps = injected || dependencies();
    const actor = await deps.authenticate(token);
    if (!actor) return reply({ code: 'unauthenticated' }, 401);
    if (request.method === 'GET') {
      const query = new URL(request.url).searchParams;
      const key = query.get('operation_key');
      if (query.size !== 1 || !validKey(key)) throw new InvitationError(400, 'invalid_input');
      return reply(await deps.finish(actor, key, 'uncertain'));
    }
    const input = await body(request);
    const action = input.action, operationKey = input.operation_key;
    if (!validKey(operationKey) || !['invite', 'resend'].includes(action as string)) throw new InvitationError(400, 'invalid_input');
    let payload: Json;
    if (action === 'invite') {
      if (Object.keys(input).length !== 5 || typeof input.name !== 'string' || typeof input.email !== 'string' ||
        !['administrator', 'employee'].includes(input.role as string)) throw new InvitationError(400, 'invalid_input');
      payload = { name: input.name, email: input.email, role: input.role };
    } else {
      if (Object.keys(input).length !== 4 || !uuid(input.invitation_id) || !Number.isSafeInteger(input.expected_version) || Number(input.expected_version) < 1) throw new InvitationError(400, 'invalid_input');
      payload = { invitation_id: input.invitation_id, expected_version: input.expected_version };
    }
    const job = await deps.reserve(actor, operationKey, action as string, payload);
    if (!job.should_send) return reply(await deps.finish(actor, operationKey, 'uncertain'));
    let sent;
    try { sent = await deps.send(job.email as string); }
    catch { return reply(await deps.finish(actor, operationKey, 'uncertain'), 202); }
    return reply(await deps.finish(actor, operationKey, sent.userId ? 'sent' : 'failed', sent.userId, sent.code));
  } catch (error) {
    return error instanceof InvitationError ? reply({ code: error.code }, error.status) : reply({ code: 'operation_unavailable' }, 503);
  }
}
