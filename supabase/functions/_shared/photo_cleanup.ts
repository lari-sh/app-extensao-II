import {createClient,type SupabaseClient} from '@supabase/supabase-js';
export async function cleanupPhotos(admin:SupabaseClient){
 const claimed=await admin.rpc('claim_photo_cleanup');if(claimed.error)throw new Error('claim_failed');
 let removed=0,failed=0;
 for(const job of claimed.data??[]){
  let success=false;
  try{const result=await admin.storage.from('animal-photos').remove([job.object_path]);success=!result.error;}catch{/* retry persists below */}
  const complete=await admin.rpc('complete_photo_cleanup',{p_id:job.job_id,p_token:job.lease_token,p_success:success});
  if(complete.error)throw new Error('completion_failed');
  if(success)removed++;else failed++;
 }
 return {removed,failed};
}
export async function handleCleanup(request:Request){
 const secret=Deno.env.get('PHOTO_CLEANUP_SECRET');
 if(!secret||request.headers.get('authorization')!=='Bearer '+secret)return new Response(null,{status:401});
 if(request.method!=='POST')return new Response(null,{status:405});
 try{
  const admin=createClient(Deno.env.get('SUPABASE_URL')!,Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,{auth:{persistSession:false,autoRefreshToken:false},global:{fetch:(input,init)=>fetch(input,{...init,signal:AbortSignal.timeout(60000)})}});
  return Response.json(await cleanupPhotos(admin),{headers:{'Cache-Control':'no-store'}});
 }catch{return Response.json({code:'unavailable'},{status:503});}
}
