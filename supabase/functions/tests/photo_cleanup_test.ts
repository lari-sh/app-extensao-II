import {cleanupPhotos} from '../_shared/photo_cleanup.ts';
function assert(value:unknown,message:string):asserts value{if(!value)throw new Error(message);}
Deno.test('cleanup uses leased paths, awaits storage result and retains failed attempts',async()=>{
 const completed:unknown[][]=[];let fail=true;
 const client={rpc:async(name:string,args?:Record<string,unknown>)=>{
  if(name==='claim_photo_cleanup')return {data:[{job_id:'job',object_path:'immutable/path',lease_token:'lease'}],error:null};
  completed.push([args?.p_id,args?.p_token,args?.p_success]);return {data:null,error:null};
 },storage:{from:()=>({remove:async(paths:string[])=>{assert(paths[0]==='immutable/path','Only server-claimed path');return {error:fail?{message:'private'}:null};}})}};
 await cleanupPhotos(client as never);assert(completed[0][2]===false,'Removal failure persisted');
 fail=false;await cleanupPhotos(client as never);assert(completed[1][2]===true,'Successful deletion completes job');
});
