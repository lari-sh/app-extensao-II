begin;
select no_plan();
insert into auth.users(id) values('57000000-0000-4000-8000-000000000001');
insert into auth.sessions(id,user_id) values('67000000-0000-4000-8000-000000000001','57000000-0000-4000-8000-000000000001');
insert into public.staff_members(user_id,active) values('57000000-0000-4000-8000-000000000001',true);
insert into public.animals(id,name,species,sex,size,approximate_age,color,status,is_published) values
('77000000-0000-4000-8000-000000000001','006 Luna','dog','female','small','2 anos','Branco e preto','quarantine',false),
('77000000-0000-4000-8000-000000000002','006 Luna','dog','female','medium','3 anos','Marrom','treatment',true),
('77000000-0000-4000-8000-000000000003','006 Grupo gato','cat','male','small','1 ano',null,'adopted',false),
('77000000-0000-4000-8000-000000000004','006 Grupo disponível','cat','female','small','1 ano','Preto','available',true),
('77000000-0000-4000-8000-000000000005','006 % literal','dog','male','large','2 anos','Preto','available',false),
('77000000-0000-4000-8000-000000000006','006 _ literal','dog','male','large','2 anos','Preto','available',false),
('77000000-0000-4000-8000-000000000007',E'006 \\ literal','dog','male','large','2 anos','Preto','available',false),
('77000000-0000-4000-8000-000000000008','006 D''água','dog','male','large','2 anos','Preto','available',false);
insert into public.animals(id,name,species,sex,size,approximate_age)
 select ('77000000-0000-4000-8000-'||lpad((n+100)::text,12,'0'))::uuid,'006 Página '||lpad(n::text,3,'0'),'dog','male','large','2 anos' from generate_series(1,51)n;
insert into public.animal_internal_details(animal_id,clinical_notes) select id,'Segredo exclusivo não pesquisável' from public.animals where id::text like '77000000-%';
select set_config('request.jwt.claims','{"sub":"57000000-0000-4000-8000-000000000001","session_id":"67000000-0000-4000-8000-000000000001","role":"authenticated"}',true);
set local role authenticated;
select is((public.search_managed_animals(' 006 lUnA ')->>'total')::int,2,'nome parcial/trim/case e homônimos');
select is((public.search_managed_animals('006 Luna')->'items'->0->'animal'->>'animal_code'),(select animal_code from public.animals where id='77000000-0000-4000-8000-000000000001'),'resultado expõe código correto');
select is((public.search_managed_animals(' #'||lower((select animal_code from public.animals where id='77000000-0000-4000-8000-000000000001'))||' ')->>'total')::int,1,'código completo normalizado');
select is((public.search_managed_animals('006 Luna','dog','female',' PRETO ','small','quarantine')->>'total')::int,1,'cinco filtros combinados e cor parcial');
select is((public.search_managed_animals(null,null,null,null,null,'adopted')->'items' @> '[{"animal":{"id":"77000000-0000-4000-8000-000000000003"}}]')::boolean,true,'adotado privado incluído');
select is((public.search_managed_animals('006 Luna')->>'total')::int,2,'sem depender de evento/dia ou publicação');
select is((public.search_managed_animals('006 %')->>'total')::int,1,'percentual literal');
select is((public.search_managed_animals('006 _')->>'total')::int,1,'underscore literal');
select is((public.search_managed_animals(E'006 \\')->>'total')::int,1,'barra literal');
select is((public.search_managed_animals('006 D''água')->>'total')::int,1,'apóstrofo parametrizado');
select is((public.search_managed_animals('Segredo exclusivo')->>'total')::int,0,'notas não são pesquisadas');
select is((public.search_managed_animals('006 Grupo',p_color=>'preto')->>'total')::int,1,'cor filtra e não inclui null');
select is((public.search_managed_animals('006 Grupo')->>'total')::int,2,'sem cor inclui null');
select is(jsonb_array_length(public.search_managed_animals('006 Página')->'items'),25,'página fixa 25');
select is((public.search_managed_animals('006 Página')->>'total')::int,51,'total antes de paginar');
create temporary table search_page as select public.search_managed_animals('006 Página') as value;
select is((public.search_managed_animals('006 Página',p_cursor=>(select value->'cursor' from search_page))->'items'->0->'animal'->>'name'),'006 Página 026','segunda página estável');
select is((public.search_managed_animals('006 Página 051')->'items'->0->'animal'->>'name'),'006 Página 051','encontra fora das páginas carregadas');
select is(public.search_managed_animals('006 Página',p_cursor=>jsonb_build_array('006 Página 050','77000000-0000-4000-8000-000000000150'))->'cursor','null'::jsonb,'última página sem cursor');
select is(jsonb_array_length(public.search_managed_animals('006 Página',p_cursor=>jsonb_build_array('006 Página 026','77000000-0000-4000-8000-000000000126'))->'items'),25,'última página cheia');
select is(public.search_managed_animals('006 Página',p_cursor=>jsonb_build_array('006 Página 026','77000000-0000-4000-8000-000000000126'))->'cursor','null'::jsonb,'sem página extra quando restam exatamente 25');
select throws_ok($$select public.search_managed_animals(repeat('x',81))$$,'22023','invalid_search_filter','texto longo rejeitado');
select throws_ok($$select public.search_managed_animals(p_species=>'bird')$$,'22023','invalid_search_filter','espécie inválida');
select throws_ok($$select public.search_managed_animals(p_sex=>'x')$$,'22023','invalid_search_filter','sexo inválido');
select throws_ok($$select public.search_managed_animals(p_size=>'x')$$,'22023','invalid_search_filter','porte inválido');
select throws_ok($$select public.search_managed_animals(p_status=>'x')$$,'22023','invalid_search_filter','situação inválida');
select throws_ok($$select public.search_managed_animals(p_color=>repeat('x',81))$$,'22023','invalid_search_filter','cor longa rejeitada');
select throws_ok($$select public.search_managed_animals(p_cursor=>'{}')$$,'22023','invalid_search_cursor','cursor objeto rejeitado');
select throws_ok($$select public.search_managed_animals(p_cursor=>'["x","inválido"]')$$,'22023','invalid_search_cursor','UUID de cursor inválido');
select throws_ok($$select public.search_managed_animals(p_cursor=>'[]')$$,'22023','invalid_search_cursor','cursor vazio rejeitado');
select throws_ok($$select public.search_managed_animals(p_cursor=>'[1,"77000000-0000-4000-8000-000000000001"]')$$,'22023','invalid_search_cursor','nome de cursor deve ser texto');
select is((public.search_managed_animals('   ',p_color=>'   ')->>'total')::bigint,(select count(*) from public.animals),'vazio e espaços não limitam os animais autorizados');
reset role;
insert into auth.users(id) values('57000000-0000-4000-8000-000000000002'),('57000000-0000-4000-8000-000000000003');
insert into auth.sessions(id,user_id) values('67000000-0000-4000-8000-000000000002','57000000-0000-4000-8000-000000000002'),('67000000-0000-4000-8000-000000000003','57000000-0000-4000-8000-000000000003');
insert into public.staff_members(user_id,active) values('57000000-0000-4000-8000-000000000002',false);
select set_config('request.jwt.claims','{"sub":"57000000-0000-4000-8000-000000000002","session_id":"67000000-0000-4000-8000-000000000002","role":"authenticated"}',true);
set local role authenticated;
select throws_ok($$select public.search_managed_animals('006')$$,'42501','staff_required','vínculo inativo negado');
reset role;
select set_config('request.jwt.claims','{"sub":"57000000-0000-4000-8000-000000000003","session_id":"67000000-0000-4000-8000-000000000003","role":"authenticated"}',true);
set local role authenticated;
select throws_ok($$select public.search_managed_animals('006')$$,'42501','staff_required','conta sem vínculo negada');
reset role;
select set_config('request.jwt.claims','{"sub":"57000000-0000-4000-8000-000000000001","session_id":"67000000-0000-4000-8000-000000000001","role":"authenticated"}',true);
reset role;
delete from auth.sessions where id='67000000-0000-4000-8000-000000000001';
set local role authenticated;
select throws_ok($$select public.search_managed_animals('006')$$,'42501','staff_required','sessão revogada negada');
reset role;
select ok(not has_function_privilege('anon','public.search_managed_animals(text,text,text,text,text,text,jsonb)','EXECUTE'),'anônimo sem execute');
set local role anon;
select throws_ok($$select public.search_managed_animals('006')$$,'42501',null,'chamada direta anônima negada');
reset role;
select * from finish();rollback;
