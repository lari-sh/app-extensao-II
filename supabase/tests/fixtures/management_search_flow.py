"""Local-only search/authorization/performance fixtures; preserve all existing data."""
import time,uuid
from team_fixture_support import create_user,sql,login,rpc,request,cleanup
actor,email=create_user('search'); outsider,other_email=create_user('search-outsider')
prefix='Search-'+uuid.uuid4().hex
sql(f"insert into public.staff_members(user_id,active,role,display_name) values('{actor}',true,'employee','Validação busca');")
try:
 sql(f"""insert into public.animals(name,species,sex,size,approximate_age,color,status,is_published)
 select '{prefix}-'||lpad(i::text,4,'0'),'dog','female','small','2 anos','preto e branco','quarantine',false from generate_series(1,5000) i;
 insert into public.animal_internal_details(animal_id,clinical_notes)
 select id,'Nota privada fora da busca' from public.animals where name like '{prefix}-%';""")
 token=login(email)
 query={'p_query':prefix}
 times=[]
 for _ in range(3):
  started=time.perf_counter();page=rpc('search_managed_animals',query,token);times.append(time.perf_counter()-started)
 assert page['total']==5000 and len(page['items'])==25 and page['cursor'],'Filter must precede paging'
 assert max(times)<2,'Local 5000-animal query exceeded 2 seconds'
 target=sql(f"select animal_code from public.animals where name='{prefix}-4999';")
 exact=rpc('search_managed_animals',{'p_query':' #'+target.lower()+' '},token)
 assert exact['total']==1 and exact['items'][0]['animal']['name']==prefix+'-4999','Beyond-first-page code must resolve globally'
 combined=rpc('search_managed_animals',{**query,'p_species':'dog','p_sex':'female','p_color':'PRETO','p_size':'small','p_status':'quarantine'},token)
 assert combined['total']==5000
 second=rpc('search_managed_animals',{**query,'p_cursor':page['cursor']},token)
 assert not ({x['animal']['id'] for x in page['items']} & {x['animal']['id'] for x in second['items']})
 assert sql(f"select count(*) from public.medication_treatments where animal_id in (select id from public.animals where name like '{prefix}-%');")=='0','Search fixtures deliberately have no calendar event'
 request('/rest/v1/rpc/search_managed_animals',query,expected=(401,403))
 request('/rest/v1/rpc/search_managed_animals',query,login(other_email),expected=403)
 sql(f"update public.staff_members set role='administrator' where user_id='{actor}';")
 assert rpc('search_managed_animals',{'p_query':target},token)['total']==1
 sql(f"insert into public.staff_members(user_id,active,role,display_name) values('{outsider}',true,'administrator','Administrador temporário de validação');")
 sql(f"update public.staff_members set role='employee',active=false where user_id='{actor}';")
 request('/rest/v1/rpc/search_managed_animals',query,token,expected=403)
 sql(f"update public.staff_members set active=true where user_id='{actor}';")
 request('/auth/v1/logout',{},token,expected=(200,204))
 request('/rest/v1/rpc/search_managed_animals',query,token,expected=(401,403))
 print('PASS: HTTP global filters/code/cursor, no calendar dependency, employee/admin and denied anonymous/nonstaff/inactive/revoked; 5000 rows seconds: '+','.join(f'{v:.3f}' for v in times))
finally:
 sql(f"delete from public.animals where name like '{prefix}-%';")
 cleanup()
