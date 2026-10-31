import {createClient} from '@supabase/supabase-js';
function assert(value:unknown,message:string):asserts value {if(!value)throw new Error(message);}
Deno.test('photo proxy serves current public bytes without cache and denies after hiding/adoption',async()=>{
 const url=Deno.env.get('SUPABASE_URL')!;const key=Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;const anon=Deno.env.get('SUPABASE_ANON_KEY')!;
 assert(['127.0.0.1','localhost'].includes(new URL(url).hostname),'Local environment required');
 const admin=createClient(url,key,{auth:{persistSession:false,autoRefreshToken:false}});
 const id='00000000-0000-4000-8000-000000000001',photo='10000000-0000-4000-8000-000000000001';
 const address=`${url}/functions/v1/animal-photo-read?animal_id=${id}&photo_id=${photo}`;
 const read=()=>fetch(address,{headers:{apikey:anon,Accept:'application/octet-stream','If-None-Match':'anything'},redirect:'manual'});
 const response=await read();assert(response.status===200,'Public current photo must be readable');
 assert(response.headers.get('cache-control')==='no-store, private','No cache');assert(response.headers.get('pragma')==='no-cache','No legacy cache');
 assert(!response.headers.has('location'),'No redirect');const bytes=new Uint8Array(await response.arrayBuffer());assert(bytes[0]===137&&bytes[1]===80,'PNG bytes');
 try {
  const hidden=await admin.from('animals').update({is_published:false}).eq('id',id);assert(!hidden.error,'Hide fixture');
  const denied=await read();assert(denied.status===404,'New request after hiding denied');await denied.arrayBuffer();
  const adopted=await admin.from('animals').update({is_published:true,status:'adopted'}).eq('id',id);assert(!adopted.error,'Adopt fixture');
  const deniedAdopted=await read();assert(deniedAdopted.status===404,'New request after adoption denied');await deniedAdopted.arrayBuffer();
 }finally {const restored=await admin.from('animals').update({is_published:true,status:'available'}).eq('id',id);assert(!restored.error,'Restore fixture');}
 const arbitrary=await fetch(`${address}&object_path=secret`,{headers:{apikey:anon}});assert(arbitrary.status===400,'Arbitrary path rejected');await arbitrary.arrayBuffer();
});

Deno.test('private photo requires current staff session and cannot be requested as another animal',async()=>{
 const url=Deno.env.get('SUPABASE_URL')!,key=Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,anon=Deno.env.get('SUPABASE_ANON_KEY')!,password=Deno.env.get('FIXTURE_PASSWORD')!;
 assert(['127.0.0.1','localhost'].includes(new URL(url).hostname),'Local environment required');
 const options={auth:{persistSession:false,autoRefreshToken:false}};
 const admin=createClient(url,key,options),staff=createClient(url,anon,options);
 const login=await staff.auth.signInWithPassword({email:'fixture-revocable@example.test',password});
 assert(!login.error&&login.data.session,'Fixture login');const token=login.data.session.access_token,user=login.data.user.id;
 const id='00000000-0000-4000-8000-000000000002',photo='10000000-0000-4000-8000-000000000002';
 const address=`${url}/functions/v1/animal-photo-read?animal_id=${id}&photo_id=${photo}`;
 async function status(jwt?:string){const response=await fetch(address,{headers:{apikey:anon,...(jwt?{Authorization:`Bearer ${jwt}`}:{})},redirect:'manual'});await response.arrayBuffer();return response.status;}
 try {
  const hidden=await admin.from('animals').update({is_published:false}).eq('id',id);assert(!hidden.error,'Hide private fixture');
  assert(await status()===404,'Anon denied private photo');assert(await status(token)===200,'Current staff allowed');
  const removed=await admin.from('staff_members').update({active:false}).eq('user_id',user);assert(!removed.error,'Remove membership');
  assert(await status(token)===404,'Old JWT with revoked membership denied');
  const restored=await admin.from('staff_members').update({active:true}).eq('user_id',user);assert(!restored.error,'Restore membership');
  const revoked=await admin.auth.admin.signOut(token,'global');assert(!revoked.error,'Revoke session');
  assert(await status(token)===404,'Old JWT with removed session denied');
 }finally {
  await admin.from('staff_members').update({active:true}).eq('user_id',user);
  await admin.from('animals').update({is_published:true}).eq('id',id);
 }
 const mismatch=await fetch(`${url}/functions/v1/animal-photo-read?animal_id=00000000-0000-4000-8000-000000000001&photo_id=${photo}`,{headers:{apikey:anon}});
 assert(mismatch.status===404,'Photo must belong to requested animal');await mismatch.arrayBuffer();
 const rpc=await staff.rpc('resolve_photo_read',{p_animal_id:id,p_photo_id:photo});
 assert(rpc.error,'Client must not receive server-only resolver metadata');
});
