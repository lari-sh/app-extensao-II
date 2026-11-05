import {readPhoto,failure} from '../_shared/photo_access.ts';
Deno.serve(async request=>{try{return await readPhoto(request);}catch{return failure(503,'unavailable');}});
