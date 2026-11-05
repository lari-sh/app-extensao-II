import {createClient} from '@supabase/supabase-js';

function assert(value: unknown, message: string): asserts value {if(!value)throw new Error(message);}
Deno.test('two sessions persist private edits; atomic rollback, concurrent retry and current authorization',async()=>{
 const url=Deno.env.get('SUPABASE_URL')!,key=Deno.env.get('SUPABASE_ANON_KEY')!,adminKey=Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,password=Deno.env.get('FIXTURE_PASSWORD')!;
 assert(['localhost','127.0.0.1'].includes(new URL(url).hostname),'Disposable local backend required');
 const options={auth:{persistSession:false,autoRefreshToken:false}};
 const first=createClient(url,key,options),second=createClient(url,key,options),visitor=createClient(url,key,options),admin=createClient(url,adminKey,options);
 const prefix=crypto.randomUUID().replaceAll('-','');const editKey=crypto.randomUUID().replaceAll('-','');const lostKey=crypto.randomUUID().replaceAll('-','');
 const lost=createClient(url,key,{...options,global:{fetch:async(input,init)=>{
  const response=await fetch(input,init);
  if(String(input).endsWith('/rest/v1/rpc/save_animal')&&response.ok){
   await response.arrayBuffer();
   throw new TypeError('Simulated transport loss after server commit');
  }
  return response;
 }}});
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
  const loginLost=await lost.auth.signInWithPassword({email:'fixture-staff@example.test',password});assert(!loginLost.error,'Transport-loss fixture login');
  const lostPayload={...payload,id,name:'Resposta perdida'};
  const dropped=await lost.rpc('save_animal',{p_operation_key:lostKey,p_payload:lostPayload});assert(dropped.error,'Client receives transport failure after commit');
  const confirmed=await first.rpc('get_write_operation',{p_operation_key:lostKey});assert(!confirmed.error&&confirmed.data.animal.id===id&&confirmed.data.animal.name==='Resposta perdida','Other session reconciles committed result after dropped transport');
  const retry=await second.rpc('save_animal',{p_operation_key:lostKey,p_payload:lostPayload});assert(!retry.error&&retry.data.animal.id===id,'Same-key retry never creates another animal');
 }finally{
  if(id)await admin.from('animals').delete().eq('id',id);
  if(actor)await admin.from('write_operations').delete().eq('actor_id',actor).in('operation_key',[prefix,editKey,lostKey]);
  await Promise.all([first.auth.signOut({scope:'local'}),second.auth.signOut({scope:'local'}),lost.auth.signOut({scope:'local'})]);
 }
});
