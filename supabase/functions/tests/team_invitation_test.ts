import { InvitationDependencies, InvitationError, teamInvitation } from '../_shared/team_invitation.ts';
function assert(value: unknown, message: string): asserts value { if (!value) throw new Error(message); }
const key = 'test-invitation-operation-00001';
function scenario() {
  const calls: string[] = [];
  let shouldSend = true;
  const deps: InvitationDependencies = {
    async authenticate() { calls.push('authenticate'); return { id: 'actor', session: 'session', exp: 9999999999 }; },
    async reserve(_actor, _key, _command, payload) { calls.push('reserve'); return { should_send: shouldSend, email: payload.email }; },
    async send() { calls.push('send'); return { userId: 'recipient' }; },
    async finish(_actor, _key, delivery) { calls.push('finish:' + delivery); return { state: 'confirmed' }; },
  };
  const request = (extra: Record<string, unknown> = {}) => new Request('http://local/team-invitation', {
    method: 'POST', headers: { authorization: 'Bearer fixture', 'content-type': 'application/json' },
    body: JSON.stringify({ action: 'invite', operation_key: key, name: 'Equipe', email: 'person@example.test', role: 'employee', ...extra }),
  });
  return { deps, calls, request, replay() { shouldSend = false; } };
}
Deno.test('invitation requires verified administrator before reservation or body processing', async () => {
  const s = scenario();
  const visitor = await teamInvitation(new Request('http://local', { method: 'POST' }), s.deps);
  assert(visitor.status === 401 && s.calls.length === 0, 'Anonymous denied before work');
  s.deps.authenticate = async () => { throw new InvitationError(403, 'administrator_required'); };
  const denied = await teamInvitation(s.request(), s.deps);
  assert(denied.status === 403 && s.calls.length === 0, 'Non-admin never calls sender');
});
Deno.test('invitation rejects forged actor fields, role and oversized input', async () => {
  for (const extra of [{ actor_id: 'forged' }, { role: 'owner' }, { operation_key: 'bad' }, { name: 'x'.repeat(5000) }]) {
    const s = scenario(); const response = await teamInvitation(s.request(extra), s.deps);
    assert([400, 413].includes(response.status), 'Malformed request rejected');
    assert(!s.calls.includes('send') && !s.calls.includes('reserve'), 'No privileged side effect');
  }
});
Deno.test('new invitation sends once; replay only reconciles and never repeats email', async () => {
  const s = scenario(); await teamInvitation(s.request(), s.deps);
  assert(s.calls.join(',') === 'authenticate,reserve,send,finish:sent', 'Reserve before sending');
  s.calls.length = 0; s.replay(); await teamInvitation(s.request(), s.deps);
  assert(s.calls.join(',') === 'authenticate,reserve,finish:uncertain', 'Replay does not resend');
});
Deno.test('timeout is reconciled without raw errors or a second send', async () => {
  const s = scenario(); s.deps.send = async () => { s.calls.push('send'); throw new Error('secret transport details'); };
  const response = await teamInvitation(s.request(), s.deps);
  assert(response.status === 202, 'Uncertain operation acknowledged');
  assert(s.calls.filter(x => x === 'send').length === 1 && s.calls.at(-1) === 'finish:uncertain', 'Single attempt then reconciliation');
  assert(!(await response.text()).includes('secret'), 'No raw failure leaked');
});
Deno.test('revocation at finalization prevents successful receipt after external call', async () => {
  const s = scenario(); s.deps.finish = async () => { throw new InvitationError(403, 'administrator_required'); };
  const response = await teamInvitation(s.request(), s.deps);
  assert(response.status === 403, 'Revalidation enforced');
});
Deno.test('existing account and SMTP failures become durable failure results', async () => {
  const s = scenario(); s.deps.send = async () => ({ code: 'existing_account' });
  s.deps.finish = async (_a, _k, delivery, _id, code) => {
    assert(delivery === 'failed' && code === 'existing_account', 'Known failure persisted');
    return { state: 'failed', code };
  };
  const response = await teamInvitation(s.request(), s.deps);
  assert((await response.json()).code === 'existing_account', 'Typed result');
});
Deno.test('GET reconciliation verifies actor and accepts only operation key', async () => {
  const s = scenario();
  const response = await teamInvitation(new Request('http://local?operation_key=' + key, { headers: { authorization: 'Bearer fixture' } }), s.deps);
  assert(response.status === 200 && !s.calls.includes('send'), 'GET cannot send');
  const forged = await teamInvitation(new Request('http://local?operation_key=' + key + '&actor_id=other', { headers: { authorization: 'Bearer fixture' } }), s.deps);
  assert(forged.status === 400, 'Arbitrary actor rejected');
});
