import {createClient} from '@supabase/supabase-js';
function assert(value:unknown,message:string):asserts value {if(!value)throw new Error(message);}
function environment(){const url=Deno.env.get('SUPABASE_URL')!,anon=Deno.env.get('SUPABASE_ANON_KEY')!,key=Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,password=Deno.env.get('FIXTURE_PASSWORD')!;assert(['127.0.0.1','localhost'].includes(new URL(url).hostname),'Local tests only');const options={auth:{persistSession:false,autoRefreshToken:false}};return {password,admin:createClient(url,key,options),client:createClient(url,anon,options)};}
Deno.test('session context distinguishes nonstaff from revoked session and metadata grants no role',async()=>{
 const {client,admin,password}=environment();
 const login=await client.auth.signInWithPassword({email:'fixture-nonstaff@example.test',password});assert(!login.error&&login.data.user,'Nonstaff fixture login');const user=login.data.user;
 try{
  const metadata=await admin.auth.admin.updateUserById(user.id,{user_metadata:{is_staff:true,role:'admin'}});assert(!metadata.error,'Set untrusted metadata');
  const renewed=await client.auth.signInWithPassword({email:'fixture-nonstaff@example.test',password});assert(!renewed.error,'Renew JWT with metadata');
  const context=await client.rpc('access_context');assert(!context.error&&context.data.is_session_current===true,'Valid nonstaff session');assert(context.data.is_staff_active===false,'Metadata cannot grant staff');
  const notes=await client.from('animal_internal_details').select('*');assert(!notes.error&&notes.data.length===0,'No private rows');
  const token=renewed.data.session!.access_token;const revoked=await admin.auth.admin.signOut(token,'global');assert(!revoked.error,'Revoke session');
  const current=await client.rpc('access_context');assert(!current.error&&current.data.is_session_current===false,'Still signed JWT is no longer a valid session');
 }finally{
  await admin.auth.admin.updateUserById(user.id,{user_metadata:{...user.user_metadata,is_staff:null,role:null}});
  await client.auth.signOut({scope:'local'});
 }
});
