import {createClient} from '@supabase/supabase-js';

function assert(value: unknown, message: string): asserts value {
  if (!value) throw new Error(message);
}
function environment() {
  const url = Deno.env.get('SUPABASE_URL') ?? '';
  assert(['127.0.0.1','localhost'].includes(new URL(url).hostname), 'Test requires local Supabase');
  const anon = Deno.env.get('SUPABASE_ANON_KEY');
  const key = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
  const password = Deno.env.get('FIXTURE_PASSWORD');
  assert(anon && key && password, 'Local fixture environment missing');
  const options = {auth: {persistSession: false, autoRefreshToken: false}};
  return {url, anon, password, admin: createClient(url,key,options), client: createClient(url,anon,options)};
}
Deno.test('public signup disabled while provisioned email login works', async () => {
  const {client,password} = environment();
  const signup = await client.auth.signUp({email: 'fixture-new@example.test',password});
  assert(signup.error && !signup.data.user, 'Public signup must be rejected');
  const login = await client.auth.signInWithPassword({email:'fixture-staff@example.test',password});
  assert(!login.error && login.data.session, 'Provisioned email login must work');
  const context = await client.rpc('access_context');
  assert(!context.error && context.data.is_staff_active === true, 'Current staff must be verified');
  await client.auth.signOut({scope:'local'});
});
Deno.test('anon and authenticated nonstaff cannot read notes or write animals', async () => {
  const {client,password} = environment();
  let notes = await client.from('animal_internal_details').select('*');
  assert(!notes.error && notes.data.length === 0, 'Anon must receive zero private records');
  const login = await client.auth.signInWithPassword({email:'fixture-nonstaff@example.test',password});
  assert(!login.error, 'Nonstaff fixture must sign in');
  notes = await client.from('animal_internal_details').select('*');
  assert(!notes.error && notes.data.length === 0, 'Nonstaff must receive zero private records');
  const write = await client.from('animals').update({name:'Illegal write'}).eq('id','00000000-0000-4000-8000-000000000001');
  assert(write.error, 'Direct writes must be forbidden');
  const bucket = await client.storage.from('animal-photos').list();
  assert(bucket.error || bucket.data?.length === 0, 'Direct Storage listing must expose zero objects');
  const objectPath = 'animals/00000000-0000-4000-8000-000000000001/10000000-0000-4000-8000-000000000001.png';
  const download = await client.storage.from('animal-photos').download(objectPath);
  assert(download.error, 'Direct Storage download must be forbidden');
  const signed = await client.storage.from('animal-photos').createSignedUrl(objectPath,60);
  assert(signed.error, 'Client must not mint signed URLs');
  await client.auth.signOut({scope:'local'});
});
Deno.test('membership and session revocation deny a still signed JWT', async () => {
  const {client,admin,password,url,anon} = environment();
  const login = await client.auth.signInWithPassword({email:'fixture-revocable@example.test',password});
  assert(!login.error && login.data.session, 'Revocable fixture must sign in');
  const userId = login.data.user.id;
  const token = login.data.session.access_token;
  const call = async () => {
    const response = await fetch(`${url}/rest/v1/rpc/access_context`, {method:'POST',headers:{apikey:anon,Authorization:`Bearer ${token}`,'Content-Type':'application/json'},body:'{}'});
    const data = await response.json();
    return response.ok && data.is_staff_active === true;
  };
  assert(await call(), 'Initial staff session must be authorized');
  try {
    const revoked = await admin.from('staff_members').update({active:false}).eq('user_id',userId);
    assert(!revoked.error, 'Membership revocation must succeed');
    assert(!await call(), 'Old JWT must lose staff access immediately');
  } finally {
    const restored = await admin.from('staff_members').update({active:true}).eq('user_id',userId);
    assert(!restored.error, 'Fixture membership restoration must succeed');
  }
  const logout = await admin.auth.admin.signOut(token,'global');
  assert(!logout.error, 'Server session revocation must succeed');
  assert(!await call(), 'Revoked session JWT must not restore private access');
});
