UPDATE "lookup"."physicians" SET "name"='dr name' WHERE ("id"='1');
update ris.requests set request.physician =1;
delete from "lookup"."physicians" where id > 1;
UPDATE "lookup"."physicians" SET "name"='dr.' WHERE ("id"='1');

-- step 1
select * FROM lookup.physicians;
update ris.requests set request.physician =1 where (request).physician = 1770;
update ris.requests set request.physician =1 where (request).physician = 1771;
delete FROM lookup.physicians where id in (1770,1771);
UPDATE lookup.physicians_pk_counter SET physician_pk=76;

create view ris.reportlog 
as
with cte_Log as (
SELECT new_row->'patnumber'::text as patnumber, 
       event_time, 
       new_row->'report'->'reportcontent' as reportcontent,
       new_row->'report'->'readingby'::text as readingby, 
       new_row->'report'->'reportedby'::text as reportedby 
from ris.audit  
)
select ROW_NUMBER() OVER w, event_time, patnumber::text,readingby::text,reportedby::text,reportcontent 
from cte_Log
WINDOW w AS ();

ALTER view ris.reportlog OWNER TO ris;

SELECT * from ris.reportlog 
where patnumber::int = 12802 and row_number=2
--where patnumber::text = '12802'::text 
ORDER BY event_time desc

select row_number as id,event_time as date,patnumber,reportcontent 
from ris.reportlog  
where patnumber::int = 13940

select (report).*  from ris.requests where patnumber = 12957


--select * from ris.requests where patnumber = 13940
--select * from ris.audit where (new_row.patnumber) = 13940 LIMIT 1
create index concurrently idx_log_new_row_on_audit ON ris.audit USING GIN (new_row jsonb_path_ops);


create view ris.reportlog 
as
with cte_Log as (
SELECT new_row->'patnumber'::text as patnumber, 
       event_time, 
       new_row->'report'->'reportcontent' as reportcontent,
       new_row->'report'->'readingby'::text as readingby, 
       new_row->'report'->'reportedby'::text as reportedby 
from ris.audit  
)
select ROW_NUMBER() OVER w, event_time, patnumber::text,readingby::text,reportedby::text,reportcontent 
from cte_Log
WINDOW w AS ();

ALTER view ris.reportlog OWNER TO ris;

SELECT * from ris.reportlog 
where patnumber::int = 13940 

select * from ris.requestformresult(13940,1);
select row_number as id,event_time as date,patnumber,reportcontent 
from ris.reportlog  
where patnumber::int = 13940
ORDER BY row_number DESC

update ris.requests set report.reportcontent=
where patnumber = 13940;
