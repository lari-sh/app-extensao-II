"""Delete only this local search journey's owned medication/animal rows."""
import uuid
from team_fixture_support import sql

def cleanup_search_animals(actor_id, animal_ids):
    actor = str(uuid.UUID(actor_id))
    ids = ','.join("'" + str(uuid.UUID(value)) + "'" for value in animal_ids)
    if not ids:
        return
    sql(f"""begin;
    do $guard$ begin
      if not exists(select 1 from auth.users where id='{actor}' and email like 'fixture-team-%-android-search@example.test') then
        raise exception 'not a disposable search actor';
      end if;
      if exists(select 1 from public.animals a where a.id in ({ids}) and
        (a.name !~ '^Luna Busca [a-f0-9]{{8}}$' or a.primary_photo_id is not null or not exists(
          select 1 from public.write_operations w where w.actor_id='{actor}' and w.result#>>'{{animal,id}}'=a.id::text))) then
        raise exception 'not an owned disposable search animal';
      end if;
    end $guard$;
    delete from private.medication_operations where actor_id='{actor}';
    delete from public.medication_application_events where application_id in
      (select a.id from public.medication_applications a join public.medication_treatments t on t.id=a.treatment_id where t.animal_id in ({ids}));
    delete from public.medication_applications where treatment_id in
      (select id from public.medication_treatments where animal_id in ({ids}));
    delete from public.medication_treatment_revisions where treatment_id in
      (select id from public.medication_treatments where animal_id in ({ids}));
    delete from public.medication_treatments where animal_id in ({ids});
    delete from public.write_operations where actor_id='{actor}';
    delete from public.animals where id in ({ids});
    commit;""")
