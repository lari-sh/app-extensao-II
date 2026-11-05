import {createClient} from '@supabase/supabase-js';
import {png,paddedPng} from './image_fixtures.ts';
function assert(value:unknown,message:string):asserts value{if(!value)throw new Error(message);}
Deno.test('real upload authorization, normalization, concurrent substitution, replay and cleanup preserve current image',async()=>{
 const url=Deno.env.get('SUPABASE_URL')!,key=Deno.env.get('SUPABASE_ANON_KEY')!,adminKey=Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,password=Deno.env.get('FIXTURE_PASSWORD')!;
 assert(['localhost','127.0.0.1'].includes(new URL(url).hostname),'Local fixture tests only');
 const options={auth:{persistSession:false,autoRefreshToken:false}};const staff=createClient(url,key,options),admin=createClient(url,adminKey,options),nonstaff=createClient(url,key,options);
 const login=await staff.auth.signInWithPassword({email:'fixture-staff@example.test',password});assert(!login.error,'Staff login');
 const other=await nonstaff.auth.signInWithPassword({email:'fixture-nonstaff@example.test',password});assert(!other.error,'Nonstaff login');
 const token=login.data.session!.access_token;const operation=crypto.randomUUID().replaceAll('-','');let animal:string|undefined;
 const upload=async(bytes:Uint8Array,op:string,credential=token)=>{
  const form=new FormData();form.set('animal_id',animal!);form.set('operation_key',op);form.set('file',new Blob([new Uint8Array(bytes)]),'fixture.jpg');
  return fetch(url+'/functions/v1/animal-photo-upload',{method:'POST',headers:{apikey:key,Authorization:'Bearer '+credential},body:form});
 };
 try{
  const saved=await staff.rpc('save_animal',{p_operation_key:operation,p_payload:{name:'Photo HTTP fixture',species:'dog',sex:'female',size:'small',approximate_age:'1'}});assert(!saved.error,'Create private animal');animal=saved.data.animal.id;
  const denied=await upload(png,operation,other.data.session!.access_token);assert(denied.status===403,'Nonstaff denied before body processing');await denied.body?.cancel();
  const first=await upload(paddedPng(5242880),operation);assert(first.status===200,'Exact 5MB valid file accepted: '+first.status);const one=await first.json();assert(one.state==='attached','Full decode and attach');
  const invalid=await upload(new Uint8Array([255,216,255,0]),crypto.randomUUID().replaceAll('-',''));assert(invalid.status===422,'Corrupted JPEG rejected');await invalid.body?.cancel();
  let current=await staff.rpc('get_managed_animal',{p_animal_id:animal});assert(current.data.animal.primary_photo_id===one.photo_id,'Failure preserves old image');
  const [a,b]=await Promise.all([upload(png,crypto.randomUUID().replaceAll('-','')),upload(png,crypto.randomUUID().replaceAll('-',''))]);assert(a.status===200&&b.status===200,'Concurrent uploads confirmed');await a.json();await b.json();
  current=await staff.rpc('get_managed_animal',{p_animal_id:animal});const currentId=current.data.animal.primary_photo_id;
  const replay=await upload(paddedPng(5242880),operation);const replayed=await replay.json();assert(replay.status===200&&replayed.photo_id===one.photo_id&&replayed.current_photo_id===currentId,'Original result and current association separate');
  const conflict=await upload(png,operation);assert(conflict.status===409,'Different payload conflicts');await conflict.body?.cancel();
  const reconciled=await fetch(url+'/functions/v1/animal-photo-upload?operation_key='+operation,{headers:{apikey:key,Authorization:'Bearer '+token}});assert(reconciled.status===200&&(await reconciled.json()).photo_id===one.photo_id,'Lost response reconciles original job');
  const read=()=>fetch(url+`/functions/v1/animal-photo-read?animal_id=${animal}&photo_id=${currentId}`,{headers:{apikey:key}});
  const privateRead=await read();assert(privateRead.status===404,'Private photo hidden');await privateRead.body?.cancel();
  await admin.from('animals').update({is_published:true}).eq('id',animal!);const publicRead=await read();assert(publicRead.status===200&&publicRead.headers.get('cache-control')?.includes('no-store'),'Published bytes no cache');await publicRead.arrayBuffer();
  const direct=await staff.storage.from('animal-photos').createSignedUrl(animal+'/'+currentId,60);assert(direct.error,'Direct signed URL denied');
  const clean=()=>fetch(url+'/functions/v1/animal-photo-cleanup',{method:'POST',headers:{Authorization:'Bearer '+Deno.env.get('PHOTO_CLEANUP_SECRET')}});const workers=await Promise.all([clean(),clean()]);for(const response of workers){assert(response.status===200,'Concurrent internal cleanup authorized');await response.json();}
  const afterCleanup=await read();assert(afterCleanup.status===200,'Cleanup cannot delete current photo');await afterCleanup.arrayBuffer();
  await admin.from('animals').update({is_published:false}).eq('id',animal!);const hidden=await read();assert(hidden.status===404,'Hidden photo denied immediately');await hidden.body?.cancel();
  const lostKey=crypto.randomUUID().replaceAll('-','');const lostReply=await upload(png,lostKey);assert(lostReply.status===200,'Commit before simulated lost response');await lostReply.body?.cancel();
  const lostCheck=await fetch(url+'/functions/v1/animal-photo-upload?operation_key='+lostKey,{headers:{apikey:key,Authorization:'Bearer '+token}});assert(lostCheck.status===200&&(await lostCheck.json()).state==='attached','Response loss reconciles without new upload');
 }finally{
  if(animal){
   const jobs=await admin.from('photo_upload_jobs').select('id,object_path').eq('animal_id',animal);
   await admin.from('animals').update({primary_photo_id:null}).eq('id',animal);
   for(const job of jobs.data??[]){await admin.storage.from('animal-photos').remove([job.object_path]);await admin.from('photo_cleanup_queue').delete().eq('job_id',job.id);}
   await admin.from('photo_upload_jobs').update({previous_photo_id:null}).eq('animal_id',animal);
   await admin.from('photo_upload_jobs').delete().eq('animal_id',animal);await admin.from('animals').delete().eq('id',animal);
   await admin.from('write_operations').delete().eq('actor_id',login.data.user!.id).eq('operation_key',operation);
  }
  await staff.auth.signOut({scope:'local'});await nonstaff.auth.signOut({scope:'local'});
 }
});
