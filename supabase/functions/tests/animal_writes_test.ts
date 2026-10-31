import {createClient} from '@supabase/supabase-js';

function assert(value: unknown, message: string): asserts value {if(!value)throw new Error(message);}
Deno.test('two sessions persist private edits; atomic rollback, concurrent retry and current authorization',async()=>{
 const url=Deno.env.get('SUPABASE_URL')!,key=Deno.env.get('SUPABASE_ANON_KEY')!,adminKey=Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,password=Deno.env.get('FIXTURE_PASSWORD')!;
 assert(['localhost','127.0.0.1'].includes(new URL(url).hostname),'Disposable local backend required');
 const options={auth:{persistSession:false,autoRefreshToken:false}};
 const first=createClient(url,key,options),second=createClient(url,key,options),visitor=createClient(url,key,options),admin=createClient(url,adminKey,options);
 const prefix=crypto.randomUUID().replaceAll('-','');const editKey=crypto.randomUUID().replaceAll('-','');
 let id:string|undefined;let actor:string|undefined;
 try{
  for(const client of [first,second]){const login=await client.auth.signInWithPassword({email:'fixture-staff@example.test',password});assert(!login.error,'Fixture login');actor=login.data.user!.id;}
  const payload={name:'Cadastro integrado',approximate_age:'2 anos',species:'dog',sex:'female',size:'medium',clinical_notes:'Nota privada',care_records:[{kind:'vaccination',description:'Vacina registrada'}]};
  const request=()=>first.rpc('save_animal',{p_operation_key:prefix,p_payload:payload});
  const [a,b]=await Promise.all([request(),second.rpc('save_animal',{p_operation_key:prefix,p_payload:payload})]);
  assert(!a.error&&!b.error,'Concurrent saves succeed');id=a.data.animal.id;
  assert(a.data.animal.id===b.data.animal.id,'Concurrent same key creates one animal');
  const recovered=await first.rpc('get_write_operation',{p_operation_key:prefix});assert(!recovered.error&&recovered.data.animal.id===id,'Lost response reconciles by same key');
  const read=await second.rpc('get_managed_animal',{p_animal_id:id});assert(!read.error&&read.data.clinical_notes==='Nota privada'&&read.data.care_records.length===1,'Other session reads complete committed data');
  const edit=await second.rpc('save_animal',{p_operation_key:editKey,p_payload:{...payload,id,name:'Nome editado'}});assert(!edit.error,'Second session edits');
  const updated=await first.rpc('get_managed_animal',{p_animal_id:id});assert(!updated.error&&updated.data.animal.name==='Nome editado','First session reads remote edit');
  const invalid=await first.rpc('save_animal',{p_operation_key:crypto.randomUUID().replaceAll('-',''),p_payload:{...payload,id,name:'Não deve persistir',care_records:[{kind:'medication',description:''}]}});assert(invalid.error,'Invalid care fails');
  const unchanged=await second.rpc('get_managed_animal',{p_animal_id:id});assert(!unchanged.error&&unchanged.data.animal.name==='Nome editado','Invalid save rolls back entire aggregate');
  const publicRow=await visitor.from('animals').select('*').eq('id',id!);assert(!publicRow.error&&publicRow.data.length===0,'New animal remains private');
  const notes=await visitor.from('animal_internal_details').select('*').eq('animal_id',id!);assert(!notes.error&&notes.data.length===0,'No clinical information for visitor');
  const direct=await first.from('animals').update({name:'Bypass'}).eq('id',id!);assert(direct.error,'Direct client writes denied');
  const conflict=await request();assert(!conflict.error&&conflict.data.animal.name==='Cadastro integrado','Replay returns original result without reverting edit');
 }finally{
  if(id)await admin.from('animals').delete().eq('id',id);
  if(actor)await admin.from('write_operations').delete().eq('actor_id',actor).in('operation_key',[prefix,editKey]);
  await Promise.all([first.auth.signOut({scope:'local'}),second.auth.signOut({scope:'local'})]);
 }
});
