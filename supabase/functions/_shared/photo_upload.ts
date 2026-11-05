import {createClient} from '@supabase/supabase-js';
import {uuid,noCache} from './photo_access.ts';
import {ImageInputError,MAX_FILE_BYTES,normalizeImage} from './image_validation.ts';
export {MAX_FILE_BYTES};
export const MAX_BODY_BYTES=5308416;
const headers={...noCache,'Access-Control-Allow-Methods':'GET, POST, OPTIONS','Content-Type':'application/json'};
const reply=(data:unknown,status=200)=>new Response(JSON.stringify(data),{status,headers});
export async function parseUpload(request:Request){
 const declared=request.headers.get('content-length');if(declared&&Number(declared)>MAX_BODY_BYTES)throw new ImageInputError(413,'body_size');
 if(!request.headers.get('content-type')?.startsWith('multipart/form-data;'))throw new ImageInputError(400,'multipart_required');
 const reader=request.body?.getReader();if(!reader)throw new ImageInputError(400,'empty_body');
 const chunks:Uint8Array[]=[];let length=0;
 try{while(true){const next=await reader.read();if(next.done)break;length+=next.value.length;if(length>MAX_BODY_BYTES){await reader.cancel();throw new ImageInputError(413,'body_size');}chunks.push(next.value);}}
 finally{reader.releaseLock();}
 const body=new Uint8Array(length);let offset=0;for(const chunk of chunks){body.set(chunk,offset);offset+=chunk.length;}
 let form:FormData;try{form=await new Request('http://local/parse',{method:'POST',headers:{'content-type':request.headers.get('content-type')!},body}).formData();}catch{throw new ImageInputError(400,'invalid_multipart');}
 if([...form.keys()].some(key=>!['animal_id','operation_key','file'].includes(key))||['animal_id','operation_key','file'].some(key=>form.getAll(key).length!==1))throw new ImageInputError(400,'invalid_fields');
 const animal=form.get('animal_id'),operation=form.get('operation_key'),file=form.get('file');
 if(typeof animal!=='string'||!uuid(animal)||typeof operation!=='string'||!/^[A-Za-z0-9_-]{32}$/.test(operation)||!(file instanceof File))throw new ImageInputError(400,'invalid_fields');
 if(file.size<1||file.size>MAX_FILE_BYTES||length-file.size>65536)throw new ImageInputError(413,'file_size');
 return {animalId:animal,operationKey:operation,bytes:new Uint8Array(await file.arrayBuffer())};
}
function rpcError(error:{code?:string}){return new ImageInputError(error.code==='42501'?403:error.code==='PT404'?404:error.code==='PT409'?409:error.code==='22023'?400:503,'operation_unavailable');}
export async function uploadPhoto(request:Request):Promise<Response>{
 if(request.method==='OPTIONS')return new Response(null,{status:204,headers});
 if(!['GET','POST'].includes(request.method))return reply({code:'method_not_allowed'},405);
 const backend=Deno.env.get('SUPABASE_URL'),serviceKey=Deno.env.get('SUPABASE_SERVICE_ROLE_KEY'),anon=Deno.env.get('SUPABASE_ANON_KEY');
 if(!backend||!serviceKey||!anon)return reply({code:'configuration'},503);
 const token=request.headers.get('authorization')?.replace(/^Bearer\s+/i,'');if(!token)return reply({code:'unauthenticated'},401);
 const actorClient=createClient(backend,anon,{auth:{persistSession:false,autoRefreshToken:false},global:{headers:{Authorization:'Bearer '+token}}});
 const verified=await actorClient.auth.getUser(token);if(verified.error||!verified.data.user)return reply({code:'unauthenticated'},401);
 const context=await actorClient.rpc('access_context');if(context.error||!context.data?.is_session_current||!context.data?.is_staff_active)return reply({code:'forbidden'},403);
 let session:string;try{session=JSON.parse(atob(token.split('.')[1].replaceAll('-','+').replaceAll('_','/'))).session_id;if(!uuid(session))throw 0;}catch{return reply({code:'unauthenticated'},401);}
 // Authorization completes before reading any upload body or using admin Storage.
 if(request.method==='GET'){
  const params=new URL(request.url).searchParams;const key=params.get('operation_key');
  if(params.size!==1||!key||!/^[A-Za-z0-9_-]{32}$/.test(key))return reply({code:'validation'},400);
  const result=await actorClient.rpc('get_photo_upload',{p_operation_key:key});if(result.error)throw rpcError(result.error);
  return result.data?reply(result.data):reply({code:'not_found'},404);
 }
 const input=await parseUpload(request);
 const digest=Array.from(new Uint8Array(await crypto.subtle.digest('SHA-256',input.bytes))).map(x=>x.toString(16).padStart(2,'0')).join('');
 const admin=createClient(backend,serviceKey,{auth:{persistSession:false,autoRefreshToken:false},global:{fetch:(input,init)=>fetch(input,{...init,signal:AbortSignal.timeout(60000)})}});
 const reserved=await admin.rpc('reserve_photo_upload',{p_animal_id:input.animalId,p_actor_id:verified.data.user.id,p_session_id:session,p_operation_key:input.operationKey,p_digest:digest});
 if(reserved.error)throw rpcError(reserved.error);const job=reserved.data;
 const result=async()=>{const read=await actorClient.rpc('get_photo_upload',{p_operation_key:input.operationKey});if(read.error)throw rpcError(read.error);return reply(read.data);};
 if(!job.should_upload)return result();
 try{
  const image=await normalizeImage(input.bytes);
  const valid=await admin.rpc('validate_photo_upload',{p_id:job.id,p_token:job.upload_token,p_mime:image.mime,p_size:image.bytes.length});if(valid.error)throw rpcError(valid.error);
  const stored=await admin.storage.from('animal-photos').upload(job.object_path,image.bytes,{contentType:image.mime,upsert:false,cacheControl:'0'});if(stored.error)throw new ImageInputError(503,'storage_unavailable');
  const attached=await admin.rpc('finalize_photo_upload',{p_id:job.id,p_actor_id:verified.data.user.id,p_session_id:session,p_token:job.upload_token});if(attached.error)throw rpcError(attached.error);
  return reply(attached.data);
 }catch(error){
  // No synchronous delete: finalization may have committed before a lost reply.
  await admin.rpc('fail_photo_upload',{p_id:job.id,p_token:job.upload_token});throw error;
 }
}
export async function handleUpload(request:Request){try{return await uploadPhoto(request);}catch(error){return error instanceof ImageInputError?reply({code:error.code},error.status):reply({code:'unavailable'},503);}}
