-- Bucket-specific deny remains effective even if standard Storage grants or
-- permissive policies are added by platform setup or later application work.
create policy animal_photos_client_deny on storage.objects as restrictive
 for all to anon,authenticated
 using(bucket_id <> 'animal-photos') with check(bucket_id <> 'animal-photos');
create policy animal_photos_bucket_client_deny on storage.buckets as restrictive
 for all to anon,authenticated
 using(id <> 'animal-photos') with check(id <> 'animal-photos');
-- Service-only resolver; actor/session are verified by the Edge Function.
create function public.resolve_photo_read(p_animal_id uuid,p_photo_id uuid,p_actor_id uuid default null,p_session_id uuid default null)
returns jsonb language sql stable security definer set search_path='' as $$
 select jsonb_build_object('object_path',j.object_path,'detected_mime',j.detected_mime)
 from public.animals a join public.photo_upload_jobs j on j.id=a.primary_photo_id and j.animal_id=a.id
 where a.id=p_animal_id and j.id=p_photo_id and j.state='attached'
 and ((a.is_published and a.status<>'adopted') or private.is_current_staff(p_actor_id,p_session_id));
$$;
revoke all on function public.resolve_photo_read(uuid,uuid,uuid,uuid) from public,anon,authenticated;
grant execute on function public.resolve_photo_read(uuid,uuid,uuid,uuid) to service_role;
