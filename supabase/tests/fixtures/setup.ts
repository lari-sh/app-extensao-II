import { createClient } from "@supabase/supabase-js";

// This deliberately supports local disposable instances only. No remote override.
const url = new URL(Deno.env.get("SUPABASE_URL") ?? "http://127.0.0.1:54321");
if (!['127.0.0.1', 'localhost'].includes(url.hostname) || url.port !== '54321' ||
    Deno.env.get('ALLOW_LOCAL_FIXTURES') !== 'true') {
  throw new Error('Fixtures permitidas somente na instancia local explicitamente autorizada.');
}
const key = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
const password = Deno.env.get('FIXTURE_PASSWORD');
if (!key || !password || password.length < 12) {
  throw new Error('Configure chave administrativa local e senha exclusiva de teste (12+ caracteres).');
}
const admin = createClient(url.href, key, {auth: {persistSession: false, autoRefreshToken: false}});
function requireSuccess<T extends {data: unknown; error: unknown}>(result: T): T["data"] {
  if (result.error) throw new Error('Falha ao preparar fixture; confira schema e configuracao local.');
  return result.data;
}
const listed = requireSuccess(await admin.auth.admin.listUsers({perPage: 1000}));
const actors: Record<string, string> = {};
for (const role of ['staff', 'nonstaff', 'revocable']) {
  const email = `fixture-${role}@example.test`;
  let user = listed.users.find((candidate) => candidate.email === email);
  if (!user) {
    user = requireSuccess(await admin.auth.admin.createUser({email, password, email_confirm: true})).user ?? undefined;
  } else {
    requireSuccess(await admin.auth.admin.updateUserById(user.id, {password, email_confirm: true}));
  }
  if (!user) throw new Error('Nao foi possivel criar ator de teste.');
  actors[role] = user.id;
}
requireSuccess(await admin.from('staff_members').upsert([
  {user_id: actors.staff, active: true}, {user_id: actors.revocable, active: true},
  {user_id: actors.nonstaff, active: false},
]));
const animals = Array.from({length: 60}, (_, i) => ({
  id: `00000000-0000-4000-8000-${String(i + 1).padStart(12, '0')}`,
  name: `Animal de teste ${String(i + 1).padStart(2, '0')}`,
  species: i % 2 === 0 ? 'dog' : 'cat', sex: i % 2 === 0 ? 'female' : 'male',
  size: ['small', 'medium', 'large'][i % 3], approximate_age: '2 anos',
  public_description: 'Fixture isolada; nunca importar para producao.',
  status: i === 59 ? 'adopted' : 'available', is_published: i !== 58,
}));
requireSuccess(await admin.from('animals').upsert(animals));
requireSuccess(await admin.from('animal_internal_details').upsert(animals.map((animal) => ({
  animal_id: animal.id, clinical_notes: 'Nota interna de teste', created_by: actors.staff, updated_by: actors.staff,
}))));
// A real 1x1 PNG; malformed and mismatched bytes are also available to HTTP tests.
export const pngBytes = Uint8Array.from(atob('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR4nGM4Kqv1HwAEwwIMevLbSwAAAABJRU5ErkJggg=='), c => c.charCodeAt(0));
export const invalidImageBytes = new TextEncoder().encode('not an image');
const authClient = createClient(url.href, key, {auth: {persistSession: false, autoRefreshToken: false}});
const signed = requireSuccess(await authClient.auth.signInWithPassword({email: 'fixture-staff@example.test', password}));
if (!signed.session) throw new Error('Sessao de fixture ausente.');
const claims = JSON.parse(atob(signed.session.access_token.split('.')[1].replaceAll('-', '+').replaceAll('_', '/')));
for (const [index, animal] of animals.slice(0, 2).entries()) {
  const id = `10000000-0000-4000-8000-${String(index + 1).padStart(12, '0')}`;
  const path = `animals/${animal.id}/${id}.png`;
  // Admin client keeps its own credentials: sign-in uses a separate client below.
  const privileged = createClient(url.href, key, {auth: {persistSession: false, autoRefreshToken: false}});
  requireSuccess(await privileged.from('photo_upload_jobs').upsert({
    id, animal_id: animal.id, actor_id: actors.staff, actor_session_id: claims.session_id,
    operation_key: String(index + 1).padStart(32, '0'), object_path: path,
    payload_digest: 'fixture-only', detected_mime: 'image/png', byte_size: pngBytes.length, state: 'attached',
  }));
  requireSuccess(await privileged.storage.from('animal-photos').upload(path, pngBytes, {contentType: 'image/png', upsert: true}));
  requireSuccess(await privileged.from('animals').update({primary_photo_id: id}).eq('id', animal.id));
}
console.log('Fixtures locais preparadas: 60 animais, 3 atores e 2 fotos. Nenhuma credencial exibida.');
