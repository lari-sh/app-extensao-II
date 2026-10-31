import {createClient} from '@supabase/supabase-js';
export const noCache={'Cache-Control':'no-store, private','Pragma':'no-cache','Access-Control-Allow-Origin':'*','Access-Control-Allow-Headers':'authorization, apikey, content-type, accept','Access-Control-Allow-Methods':'GET, OPTIONS','X-Content-Type-Options':'nosniff'};
export function failure(status:number,code:string){return new Response(JSON.stringify({code}),{status,headers:{...noCache,'Content-Type':'application/json'}});}
export function uuid(value:string|null):value is string{return value!==null&&/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(value);}
export async function readPhoto(request:Request):Promise<Response>{
 if(request.method==='OPTIONS')return new Response(null,{status:204,headers:noCache});
 if(request.method!=='GET')return failure(405,'methodNotAllowed');
 const url=new URL(request.url);
 if([...url.searchParams.keys()].some(key=>!['animal_id','photo_id'].includes(key))||url.searchParams.getAll('animal_id').length!==1||url.searchParams.getAll('photo_id').length!==1)return failure(400,'validation');
 const animalId=url.searchParams.get('animal_id'),photoId=url.searchParams.get('photo_id');
 if(!uuid(animalId)||!uuid(photoId))return failure(400,'validation');
 const backend=Deno.env.get('SUPABASE_URL'),key=Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
 if(!backend||!key)return failure(503,'configuration');
 const admin=createClient(backend,key,{auth:{persistSession:false,autoRefreshToken:false}});
 let actor:string|null=null,session:string|null=null;
 const token=request.headers.get('authorization')?.replace(/^Bearer\s+/i,'');
 if(token){
  const verified=await admin.auth.getUser(token);
  if(!verified.error&&verified.data.user){
   try{const payload=JSON.parse(atob(token.split('.')[1].replaceAll('-','+').replaceAll('_','/')));if(uuid(payload.session_id)){actor=verified.data.user.id;session=payload.session_id;}}catch{/* invalid token grants no private access */}
  }
 }
 const resolve=()=>admin.rpc('resolve_photo_read',{p_animal_id:animalId,p_photo_id:photoId,p_actor_id:actor,p_session_id:session});
 const resource=await resolve();if(resource.error)return failure(503,'unavailable');if(!resource.data)return failure(404,'notFound');
 const mime=resource.data.detected_mime;
 if(!['image/png','image/jpeg'].includes(mime))return failure(404,'notFound');
 const object=await admin.storage.from('animal-photos').download(resource.data.object_path);
 if(object.error)return failure(404,'notFound');
 const bytes=new Uint8Array(await object.data.arrayBuffer());
 if(bytes.length===0||bytes.length>5242880)return failure(404,'notFound');
 const current=await resolve();if(current.error||!current.data||current.data.object_path!==resource.data.object_path)return failure(404,'notFound');
 const binary=request.headers.get('accept')?.includes('application/octet-stream');
 return new Response(bytes,{headers:{...noCache,'Content-Type':binary?'application/octet-stream':mime,'X-Image-Type':mime,'Content-Length':String(bytes.length)}});
}
