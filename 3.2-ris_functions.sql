--FUNCTION 

--ris.requestformresult
CREATE OR REPLACE FUNCTION ris.requestformresult(pno INTEGER, sno INTEGER)
RETURNS ris.requestformresult AS
$$
with CTE_Request AS (
select 
seqno,patnumber,(patient).mrn,(patient).name,(patient).age,(patient).sex,(patient).phone,
(request).regdate::timestamp without time zone,status,examdate::timestamp without time zone,condition,(patient).mobility,(patient).pattype,(request).receiptno,(request).jobtype,
(request).modality,(request).submodality,(request).examinationtype,
(request).referalhos,(request).referalUnit,(request).physician,(request).phyphone,(request).clinicaldata,(request).scanimg,(request).createdby,(request).prevexamno,(request).prevexamtype,
(exam).examstartat,(exam).examendat,(exam).modalityno,(exam).contrast,(exam).dos,(exam).isreaction,(exam).reaction,(exam).note,(exam).examBy,
(report).readingstartAt,(report).readingBy,(report).pendingapprovalBy,(report).reportcontent,
(report).additionalimageRem,reporteddate,statusby,date_trunc('hour', age(now(),(exam).examendat::timestamp)) as duration
from ris.requests as r where deleted_at is null)
select r.seqno,r.patnumber,r.mrn,initcap(r.name) as name,r.sex,r.age,r.phone,
r.regdate,r.status,r.examdate,r.condition,r.mobility,r.pattype,r.receiptno,r.jobtype,
m.name as modality,r.submodality,initcap(e.name) as examinationtype,
initcap(h.name) as referalhos,initcap(d.name) as referalUnit,initcap(p.name) as physician,r.phyphone,r.clinicaldata,
r.scanimg,initcap(rec.full_name) as createdby,r.prevexamno,r.prevexamtype,
r.examstartat,r.examendat,r.modalityno,r.contrast,r.dos,r.isreaction,r.reaction,r.note,initcap(rad.full_name) as examBy,
r.readingstartAt,initcap(res1.full_name) as readingBy,initcap(res2.full_name) as pendingapprovalBy,r.reportcontent,
r.additionalimageRem,r.reporteddate,initcap(rep.full_name) as statusby, r.duration::text
from CTE_Request as r
LEFT JOIN lookup.examinationtypes as e on r.examinationtype = e.id
LEFT JOIN lookup.modality as m on r.modality = m.id
LEFT JOIN lookup.referalHospital as h on r.referalhos = h.id
LEFT JOIN membership.departments as d on r.referalUnit = d.id
LEFT JOIN lookup.physicians as p on r.physician = p.id
LEFT JOIN membership.users as rec on r.createdby = rec.user_id
LEFT JOIN membership.users as rep on r.statusby = rep.user_id
LEFT JOIN membership.users as rad on r.examBy = rad.user_id
LEFT JOIN membership.users as res1 on r.readingBy = res1.user_id
LEFT JOIN membership.users as res2 on r.pendingapprovalBy = res2.user_id
where r.patnumber=pno and r.seqno=sno
$$ LANGUAGE SQL;

--deletedrequestformresult
CREATE OR REPLACE FUNCTION ris.deletedrequestformresult(pno INTEGER, sno INTEGER)
RETURNS ris.requestformresult AS
$$
with CTE_Request AS (
select 
seqno,patnumber,(patient).mrn,(patient).name,(patient).age,(patient).sex,(patient).phone,
(request).regdate,status,examdate,condition,(patient).mobility,(patient).pattype,(request).receiptno,(request).jobtype,
(request).modality,(request).submodality,(request).examinationtype,
(request).referalhos,(request).referalUnit,(request).physician,(request).phyphone,(request).clinicaldata,(request).scanimg,(request).createdby,(request).prevexamno,(request).prevexamtype,
(exam).examstartat,(exam).examendat,(exam).modalityno,(exam).contrast,(exam).dos,(exam).isreaction,(exam).reaction,(exam).note,(exam).examBy,
(report).readingstartAt,(report).readingBy,(report).pendingapprovalBy,(report).reportcontent,
(report).additionalimageRem,reporteddate,statusby,date_trunc('hour', age(now(),(exam).examendat::timestamp)) as duration
from ris.requests as r where deleted_at is not null)
select r.seqno,r.patnumber,r.mrn,initcap(r.name) as name,r.sex,r.age,r.phone,
r.regdate,r.status,r.examdate,r.condition,r.mobility,r.pattype,r.receiptno,r.jobtype,
m.name as modality,r.submodality,initcap(e.name) as examinationtype,
initcap(h.name) as referalhos,initcap(d.name) as referalUnit,initcap(p.name) as physician,r.phyphone,r.clinicaldata,
r.scanimg,initcap(rec.full_name) as createdby,r.prevexamno,r.prevexamtype,
r.examstartat,r.examendat,r.modalityno,r.contrast,r.dos,r.isreaction,r.reaction,r.note,initcap(rad.full_name) as examBy,
r.readingstartAt,initcap(res1.full_name) as readingBy,initcap(res2.full_name) as pendingapprovalBy,r.reportcontent,
r.additionalimageRem,r.reporteddate,initcap(rep.full_name) as statusby, r.duration::text
from CTE_Request as r
LEFT JOIN lookup.examinationtypes as e on r.examinationtype = e.id
LEFT JOIN lookup.modality as m on r.modality = m.id
LEFT JOIN lookup.referalHospital as h on r.referalhos = h.id
LEFT JOIN membership.departments as d on r.referalUnit = d.id
LEFT JOIN lookup.physicians as p on r.physician = p.id
LEFT JOIN membership.users as rec on r.createdby = rec.user_id
LEFT JOIN membership.users as rep on r.statusby = rep.user_id
LEFT JOIN membership.users as rad on r.examBy = rad.user_id
LEFT JOIN membership.users as res1 on r.readingBy = res1.user_id
LEFT JOIN membership.users as res2 on r.pendingapprovalBy = res2.user_id
where r.patnumber=pno and r.seqno=sno
$$ LANGUAGE SQL;

--ris.get_assignementcount
create or replace function ris.get_assignementcount()
returns setof ris.summary
as $$
DECLARE 
  outsummary ris.summary;
BEGIN
SET join_collapse_limit = 1;
	FOR outsummary IN
with cte_order as(
select r.status as status, r.assignedto,r.assigneddate,U.full_name AS Name
from ris.requests as r 
LEFT JOIN membership.users as u on u.user_id = ANY(r.assignedto)
where (U.full_name is NOT NULL) and (deleted_at is null)
)
select status, Name, COUNT(*) 
FROM cte_order 
GROUP BY rollup(status, Name)
	LOOP
		RETURN NEXT outsummary;
	END LOOP;
END;
$$ LANGUAGE PLPGSQL;

create or replace function ris.get_assignementcount(date,date, int)
returns setof ris.summary
as $$
DECLARE
  fromdate alias for $1;
  todate alias for $2; 
  roleid alias for $3; 
  outsummary ris.summary;
BEGIN
SET join_collapse_limit = 1;
	FOR outsummary IN
	with cte_order as(
select r.assignedto,U.full_name AS Name
from ris.requests as r 
LEFT JOIN membership.users as u on u.user_id = ANY(r.assignedto)
where  u.user_role = roleid
       AND (date_ge(r.assigneddate::date,fromdate::date) and date_le(r.assigneddate::date,todate::date))
       AND (deleted_at is null)
)
select  '' as status,Name, COUNT(*) 
FROM cte_order 
GROUP BY NAME
	LOOP
		RETURN NEXT outsummary;
	END LOOP;
END;
$$ LANGUAGE PLPGSQL;


--ris.get_register_orders
create or replace function ris.get_register_orders(int)
returns setof ris.registerresult
as $$
DECLARE 
	patid alias for $1;
  outorder ris.registerresult;
BEGIN
SET join_collapse_limit = 1;
	FOR outorder IN
select (request).regdate,o.examdate, o.condition,o.status,o.seqno,o.patnumber,(patient).mrn,(patient).name,(patient).sex,
(patient).age,(patient).phone,r.name as region, s.name as subcity,(request).receiptno,
(request).jobtype, m.name as modality,e.name as examinationtype,d.name as referalUnit, p.name as physician,
u.full_name as createdby,(request).clinicaldata,(exam).modalityno
FROM ris.requests as o
INNER JOIN lookup.modality as m on (request).modality = m.id
INNER JOIN lookup.examinationtypes as e on (request).examinationtype = e.id
Left JOIN lookup.physicians as p on (request).physician = p.id
INNER JOIN membership.users as u on (request).createdby = u.user_id
LEft JOIN membership.departments as d on (request).referalUnit = d.id
LEFT OUTER JOIN lookup.regions as r on (patient).region = r."id"
LEFT OUTER JOIN lookup.subcities as s on (patient).subcity = s."id"

where (o.PatNumber = patid) and deleted_at is null
ORDER BY o.condition,o.examdate desc

	LOOP
		RETURN NEXT outorder;
	END LOOP;
END;
$$ LANGUAGE PLPGSQL;

--ris.get_receptionrows
create or replace function ris.get_receptionrows(date,date,text[],text,text)
returns setof ris.recroomresult
as $$
DECLARE 
	fromdate alias for $1;
	todate alias for $2; 
  stat alias for $3;
  modno alias for $4;
  infostat alias for $5;
	outrecroom ris.recroomresult;
BEGIN
SET join_collapse_limit = 1;
	FOR outrecroom IN
with cte_order as(
select seqno,patnumber,(patient).mrn,(patient).name,(patient).age,(patient).sex,replace((patient).phone::text, '-'::text, ''::text)as phone,
(request).regdate,examdate,"condition",status,statusby,(request).jobtype,(request).modality,(request).examinationtype,(request).referalhos,
(request).referalUnit,(request).physician,
date_trunc('hour', age(now(),examdate::timestamp)) as beforeexamdate,
 date_trunc('hour', age(now(),examdate::timestamp)) as afterexamdate,
(remark).status as patstatus
 from ris.requests where deleted_at is null)
select o.seqno,o.patnumber,o.mrn,initcap(o.name) as name,o.age,o.sex,o.phone,o.regdate,o.examdate,
o.condition,o.status,o.statusby, u.full_name as statusbyname, o.jobtype,m.name as modality,initcap(e.name) as examinationtype,o.referalhos,
p.name as physician,d.name as referalUnit,o.beforeexamdate,o.afterexamdate,o.patstatus
from cte_order as o
INNER JOIN lookup.modality as m on o.modality = m.id
INNER JOIN lookup.examinationtypes as e on o.examinationtype = e.id
INNER JOIN lookup.physicians as p on o.physician = p.id
left JOIN membership.departments as d on d.id = o.referalUnit
left JOIN membership.users as u on u.user_id = o.statusby
where (date_ge(o.regdate::date,fromdate::date) and date_le(o.regdate::date,todate::date))
      AND (o.status::text LIKE ANY (stat))
			AND (o.patstatus like infostat or infostat IS NULL )
      AND ((lower(o.phone) like modno OR modno IS NULL )
          OR (lower(o.mrn) like modno OR modno IS NULL  )  
          OR (lower(o.name) like modno OR modno IS NULL  ))
ORDER BY  date_trunc('hour', age(now(),examdate::timestamp)) DESC
--o.patstatus desc ,
	LOOP
		RETURN NEXT outrecroom;
	END LOOP;
END;
$$ LANGUAGE PLPGSQL;

create or replace function ris.get_receptionrows(date,date,text[],text)
returns setof ris.recroomresult
as $$
DECLARE 
	fromdate alias for $1;
	todate alias for $2; 
  stat alias for $3;
	modno alias for $4;
  
	outrecroom ris.recroomresult;
BEGIN
SET join_collapse_limit = 1;
	FOR outrecroom IN
with cte_order as(
select seqno,patnumber,(patient).mrn,(patient).name,(patient).age,(patient).sex,replace((patient).phone::text, '-'::text, ''::text)as phone,
(request).regdate,examdate,"condition",status,statusby,(request).jobtype,(request).modality,(request).examinationtype,(request).referalhos,
(request).referalUnit,(request).physician,
date_trunc('hour', age(now(),examdate::timestamp)) as beforeexamdate,
 date_trunc('hour', age(now(),examdate::timestamp)) as afterexamdate,
(remark).status as patstatus
 from ris.requests where deleted_at is null)
select o.seqno,o.patnumber,o.mrn,initcap(o.name) as name,o.age,o.sex,o.phone,o.regdate,o.examdate,
o.condition,o.status,o.statusby, u.full_name as statusbyname, o.jobtype,m.name as modality,initcap(e.name) as examinationtype,o.referalhos,
p.name as physician,d.name as referalUnit,o.beforeexamdate,o.afterexamdate,o.patstatus
from cte_order as o
INNER JOIN lookup.modality as m on o.modality = m.id
INNER JOIN lookup.examinationtypes as e on o.examinationtype = e.id
INNER JOIN lookup.physicians as p on o.physician = p.id
left JOIN membership.departments as d on d.id = o.referalUnit
left JOIN membership.users as u on u.user_id = o.statusby
where (date_ge(o.regdate::date,fromdate::date) and date_le(o.regdate::date,todate::date))
      AND (o.status::text LIKE ANY (stat))
			AND ((lower(o.phone) like modno OR modno IS NULL )
          OR (lower(o.mrn) like modno OR modno IS NULL  )  
          OR (lower(o.name) like modno OR modno IS NULL  ))
ORDER BY  date_trunc('hour', age(now(),examdate::timestamp)) DESC
--o.patstatus desc ,
	LOOP
		RETURN NEXT outrecroom;
	END LOOP;
END;
$$ LANGUAGE PLPGSQL;

--ris.get_examroomlogs
create or replace function ris.get_examroomrows(date,date,int,text[],text)
returns setof ris.examroomresult
as $$
DECLARE 
	fromdate alias for $1;
	todate alias for $2;
  unit alias for $3;
  stat alias for $4;
  modno alias for $5;
	outexamroom ris.examroomresult;
BEGIN
SET join_collapse_limit = 1;
	FOR outexamroom IN

with cte_order as(
select seqno,patnumber,(patient).mrn,(patient).name,(patient).age,(patient).sex,(patient).phone,
(request).regdate,examdate, 

date_trunc('hour', age(now(),(request).regdate::timestamp)) as requestdur,

"condition",status,statusby,
(exam).examstartat,

date_trunc('hour', age(now(),examdate)) as examstartatdur,

(exam).examendat,

date_trunc('hour', age(now(),(exam).examstartat::timestamp)) as examendatdur,

(request).jobtype,(request).modality,(request).examinationtype,(request).referalhos,
(request).referalUnit,(request).physician 
from ris.requests where deleted_at is null)
select o.seqno,o.patnumber,o.mrn,initcap(o.name) as name,o.age,o.sex,o.phone,o.regdate,o.examdate,requestdur,
o.examstartat,o.examstartatdur,o.examendat,o.examendatdur,
o.condition,o.status,o.statusby, u.full_name as statusbyname,o.jobtype,m.name as modality,initcap(e.name) as examinationtype,o.referalhos,p.name as physician,d.name as referalUnit
from cte_order as o
INNER JOIN lookup.modality as m on o.modality = m.id
INNER JOIN lookup.examinationtypes as e on o.examinationtype = e.id
INNER JOIN lookup.physicians as p on o.physician = p.id
left JOIN membership.departments as d on d.id = o.referalUnit
left JOIN membership.users as u on u.user_id = o.statusby


where (date_ge(o.examdate::date,fromdate::date) and date_le(o.examdate::date,todate::date))
      AND (m.id = unit)
      AND (o.status::text LIKE ANY (stat))
AND ((lower(o.phone) like modno OR modno IS NULL )
          OR (lower(o.mrn) like modno OR modno IS NULL  )  
          OR (lower(o.name) like modno OR modno IS NULL  ))
ORDER BY o.examdate desc
	LOOP
		RETURN NEXT outexamroom;
	END LOOP;
END;
$$ LANGUAGE PLPGSQL;

--- Exam Room For Admin
create or replace function ris.get_examroomrowsforadmin(date,date,text[],text)
returns setof ris.examroomresult
as $$
DECLARE 
	fromdate alias for $1;
	todate alias for $2;
  stat alias for $3;
  modno alias for $4;
	outexamroom ris.examroomresult;
BEGIN
SET join_collapse_limit = 1;
	FOR outexamroom IN

with cte_order as(
select seqno,patnumber,(patient).mrn,(patient).name,(patient).age,(patient).sex,(patient).phone,
(request).regdate,examdate, 

date_trunc('hour', age(now(),(request).regdate::timestamp)) as requestdur,

"condition",status,statusby,
(exam).examstartat,

date_trunc('hour', age(now(),examdate)) as examstartatdur,

(exam).examendat,

date_trunc('hour', age(now(),(exam).examstartat::timestamp)) as examendatdur,

(request).jobtype,(request).modality,(request).examinationtype,(request).referalhos,
(request).referalUnit,(request).physician 
from ris.requests
where deleted_at is null)
select o.seqno,o.patnumber,o.mrn,initcap(o.name) as name,o.age,o.sex,o.phone,o.regdate,o.examdate,requestdur,
o.examstartat,o.examstartatdur,o.examendat,o.examendatdur,
o.condition,o.status,o.statusby, u.full_name as statusbyname,o.jobtype,m.name as modality,initcap(e.name) as examinationtype,o.referalhos,p.name as physician,d.name as referalUnit
from cte_order as o
INNER JOIN lookup.modality as m on o.modality = m.id
INNER JOIN lookup.examinationtypes as e on o.examinationtype = e.id
INNER JOIN lookup.physicians as p on o.physician = p.id
left JOIN membership.departments as d on d.id = o.referalUnit
left JOIN membership.users as u on u.user_id = o.statusby

where (date_ge(o.examdate::date,fromdate::date) and date_le(o.examdate::date,todate::date))
      AND (o.status::text LIKE ANY (stat))
      AND ((lower(o.phone) like modno OR modno IS NULL )
          OR (lower(o.mrn) like modno OR modno IS NULL  )  
          OR (lower(o.name) like modno OR modno IS NULL  ))
ORDER BY o.status asc ,o.condition asc
	LOOP
		RETURN NEXT outexamroom;
	END LOOP;
END;
$$ LANGUAGE PLPGSQL;

--ris.get_reportroomlogs
create or replace function ris.get_reportroomrows(timestamp without time zone,timestamp without time zone,int,text[],varchar,text[])
returns setof ris.reportroomresult
as $$
DECLARE 
	fromdate alias for $1;
	todate alias for $2;
  modid alias for $3;
  region alias for $4;
  modno alias for $5;
  stat alias for $6;
  
	outreportroom ris.reportroomresult;
BEGIN
SET join_collapse_limit = 1;
	FOR outreportroom IN
with cte_order as(
select seqno,patnumber,"condition",status,statusby,(patient).mrn,(patient).name,(patient).age,(patient).sex,(patient).phone,
examdate,(exam).examendat,(exam).modalityno,(request).modality as modalityid,(request).modality,
(request).submodality,(request).examinationtype,(request).jobtype,(request).physician, (request).referalUnit,
(report).readingstartAt,(report).additionalimageAt,(report).showpatientAt,(report).consultAt,(report).pendingapprovalAt,
reporteddate,
date_trunc('hour', age(now(),(exam).examendat::timestamp)) as duration,(print).printcount,assigneddate,
assignedto,assignedby
from ris.requests
where deleted_at is null)
select o.seqno,o.patnumber,o.condition,o.status,o.statusby, initcap(u.full_name) as statusbyname,o.mrn,initcap(o.name) as name,o.age,o.sex,o.phone,
o.examdate,o.examendat,o.modalityno,o.modalityid,m.name as modality,o.submodality,initcap(e.name) as examinationtype,o.jobtype,
p.name as physician,d.name as referalUnit,
o.readingstartAt,o.additionalimageAt,o.showpatientAt,o.consultAt,o.pendingapprovalAt,o.reporteddate,o.duration,o.printcount,o.assigneddate,
o.assignedto,array_to_string(array_agg(r.full_name ORDER BY r.user_role ASC),' / ') AS assignedtolable,o.assignedby
from cte_order as o
LEFT JOIN lookup.modality as m on o.modality = m.id
INNER JOIN lookup.examinationtypes as e on o.examinationtype = e.id
INNER JOIN lookup.physicians as p on o.physician = p.id
left JOIN membership.departments as d on d.id = o.referalUnit
left JOIN membership.users as u on u.user_id = o.statusby
LEFT JOIN membership.users as r on  r.user_id = any(o.assignedto)
group by o.seqno,o.patnumber,o.condition,o.status,o.statusby, u.full_name,o.mrn,o.name,o.age,o.sex,o.phone,
o.examdate,o.examendat,o.modalityno,o.modalityid,m.name,o.submodality,e.name,o.jobtype,p.name,d.name,
o.readingstartAt,o.additionalimageAt,o.showpatientAt,o.consultAt,o.pendingapprovalAt,o.reporteddate,o.duration,o.printcount,o.assignedto,o.assigneddate,o.assignedby
having (date_ge(o.examendat::date,fromdate::date) and date_le(o.examendat::date,todate::date))
       AND(o.modalityid = modid OR modid IS NULL)
			 AND ((lower(o.modalityno) like modno OR modno IS NULL )
          OR (lower(o.mrn) like modno OR modno IS NULL  )  
          OR (lower(o.name) like modno OR modno IS NULL  ))
			 AND(o.submodality::text LIKE ANY (region))
       AND (o.status::text LIKE ANY (stat))
ORDER BY o.status ,o.condition asc 
	LOOP
		RETURN NEXT outreportroom;
	END LOOP;
END;
$$ LANGUAGE PLPGSQL;

create or replace function ris.get_reportroomrows(date,date,int,text[],varchar,text[],smallint[])
returns setof ris.reportroomresult
as $$
DECLARE 
	fromdate alias for $1;
	todate alias for $2;
  modid alias for $3;
  region alias for $4;
  modno alias for $5;
  stat alias for $6;
  assignfor alias for $7;
	outreportroom ris.reportroomresult;
BEGIN
SET join_collapse_limit = 1;
	FOR outreportroom IN
with cte_order as(
select seqno,patnumber,"condition",status,statusby,(patient).mrn,(patient).name,(patient).age,(patient).sex,(patient).phone,
examdate,(exam).examendat,(exam).modalityno,(request).modality as modalityid,(request).modality,
(request).submodality,(request).examinationtype,(request).jobtype,(request).physician, (request).referalUnit,
(report).readingstartAt,(report).additionalimageAt,(report).showpatientAt,(report).consultAt,(report).pendingapprovalAt,
reporteddate,
date_trunc('hour', age(now(),(exam).examendat::timestamp)) as duration,(print).printcount,assigneddate,
assignedto,assignedby
from ris.requests
where deleted_at is null)
select o.seqno,o.patnumber,o.condition,o.status,o.statusby, initcap(u.full_name) as statusbyname,o.mrn,initcap(o.name) as name,o.age,o.sex,o.phone,
o.examdate,o.examendat,o.modalityno,o.modalityid,m.name as modality,o.submodality,initcap(e.name) as examinationtype,o.jobtype,
p.name as physician,d.name as referalUnit,
o.readingstartAt,o.additionalimageAt,o.showpatientAt,o.consultAt,o.pendingapprovalAt,o.reporteddate,o.duration,o.printcount,o.assigneddate,
o.assignedto,array_to_string(array_agg(r.full_name ORDER BY r.user_role ASC),' / ') AS assignedtolable,o.assignedby
from cte_order as o
LEFT JOIN lookup.modality as m on o.modality = m.id
INNER JOIN lookup.examinationtypes as e on o.examinationtype = e.id
INNER JOIN lookup.physicians as p on o.physician = p.id
left JOIN membership.departments as d on d.id = o.referalUnit
left JOIN membership.users as u on u.user_id = o.statusby
LEFT JOIN membership.users as r on  r.user_id = any(o.assignedto)
group by o.seqno,o.patnumber,o.condition,o.status,o.statusby, u.full_name,o.mrn,o.name,o.age,o.sex,o.phone,
o.examdate,o.examendat,o.modalityno,o.modalityid,m.name,o.submodality,e.name,o.jobtype,p.name,d.name,
o.readingstartAt,o.additionalimageAt,o.showpatientAt,o.consultAt,o.pendingapprovalAt,o.reporteddate,o.duration,o.printcount,
o.assignedto,o.assigneddate,o.assignedby
having (date_ge(o.examendat::date,fromdate::date) and date_le(o.examendat::date,todate::date))
AND ((lower(o.modalityno) like modno OR modno IS NULL )
          OR (lower(o.mrn) like modno OR modno IS NULL  )  
          OR (lower(o.name) like modno OR modno IS NULL  ))       
			 AND(o.modalityid = modid OR modid IS NULL)
			 AND(o.submodality::text LIKE ANY (region))
       AND (o.status::text LIKE ANY (stat))
       AND(o.assignedto @> (assignfor::smallint[]))
ORDER BY o.status ,o.condition asc 
	LOOP
		RETURN NEXT outreportroom;
	END LOOP;
END;
$$ LANGUAGE PLPGSQL;

--ris.get_myreportedlogs
create or replace function ris.get_myreportedlogs(timestamp without time zone,timestamp without time zone,int,text[],text,text,text[], int)
returns setof ris.reportroomresult
as $$
DECLARE 
	fromdate alias for $1;
	todate alias for $2;
  modid alias for $3;
  region alias for $4;
  examtype alias for $5;
  modno alias for $6;
  stat alias for $7;
  residentid alias for $8;
	outreportroom ris.reportroomresult;
BEGIN
SET join_collapse_limit = 1;
	FOR outreportroom IN 
with cte_order as(
select seqno,patnumber,"condition",status,statusby,(patient).mrn,(patient).name,(patient).age,(patient).sex,(patient).phone,
examdate,(exam).examendat,(exam).modalityno,(request).modality as modalityid,(request).modality,
(request).submodality,(request).examinationtype,(request).jobtype,(request).physician, (request).referalUnit,
 (report).readingstartAt,(report).additionalimageAt,(report).showpatientAt,(report).consultAt,(report).pendingapprovalAt,reporteddate,
 date_trunc('hour', age(reporteddate::timestamp,(exam).examendat::timestamp)) as duration,(print).printcount,assigneddate
from ris.requests
where deleted_at is null and status='reported')
select o.seqno,o.patnumber,o.condition,o.status,o.statusby, initcap(u.full_name) as statusbyname,o.mrn,initcap(o.name) as name,o.age,o.sex,o.phone,
o.examdate,o.examendat,o.modalityno,o.modalityid,m.name as modality,o.submodality,initcap(e.name) as examinationtype,o.jobtype,p.name as physician,d.name as referalUnit,
o.readingstartAt,o.additionalimageAt,o.showpatientAt,o.consultAt,o.pendingapprovalAt,o.reporteddate,o.duration,o.printcount,o.assigneddate
from cte_order as o
INNER JOIN lookup.modality as m on o.modality = m.id
INNER JOIN lookup.examinationtypes as e on o.examinationtype = e.id
INNER JOIN lookup.physicians as p on o.physician = p.id
left JOIN membership.departments as d on d.id = o.referalUnit
left JOIN membership.users as u on u.user_id = o.statusby
where (date_ge(o.reporteddate::date,fromdate::date) and date_le(o.reporteddate::date,todate::date))
        AND ((lower(o.modalityno) like modno OR modno IS NULL )
           OR (lower(o.mrn) like modno OR modno IS NULL  )  
           OR (lower(o.name) like modno OR modno IS NULL  ))
 			 AND(o.modalityid = modid OR modid IS NULL)
        AND(e.name ilike examtype OR examtype IS NULL)
        AND(o.submodality::text LIKE ANY (region))
       AND (o.status::text LIKE ANY (stat))
ORDER BY o.reporteddate desc
	LOOP
		RETURN NEXT outreportroom;
	END LOOP;
END;
$$ LANGUAGE PLPGSQL; 



--ris.get_reportedlogs
create or replace function ris.get_reportedlogs(timestamp without time zone,timestamp without time zone,int,text[],text,text,text[])
returns setof ris.reportroomresult
as $$
DECLARE 
	fromdate alias for $1;
	todate alias for $2;
  modid alias for $3;
  region alias for $4;
  examtype alias for $5;
  modno alias for $6;
  stat alias for $7;

	outreportroom ris.reportroomresult;
BEGIN
SET join_collapse_limit = 1;
	FOR outreportroom IN
with cte_order as(
select seqno,patnumber,"condition",status,statusby,(patient).mrn,(patient).name,(patient).age,(patient).sex,(patient).phone,
examdate,(exam).examendat,(exam).modalityno,(request).modality as modalityid,(request).modality,
(request).submodality,(request).examinationtype,(request).jobtype,(request).physician, (request).referalUnit,
(report).readingstartAt,(report).additionalimageAt,(report).showpatientAt,(report).consultAt,(report).pendingapprovalAt,reporteddate,
 date_trunc('hour', age(reporteddate::timestamp,(exam).examendat::timestamp)) as duration,(print).printcount,assigneddate
from ris.requests
where deleted_at is null and status='reported')
select o.seqno,o.patnumber,o.condition,o.status,o.statusby, initcap(u.full_name) as statusbyname,o.mrn,initcap(o.name) as name,o.age,o.sex,o.phone,
o.examdate,o.examendat,o.modalityno,o.modalityid,m.name as modality,o.submodality,initcap(e.name) as examinationtype,o.jobtype,p.name as physician,d.name as referalUnit,
o.readingstartAt,o.additionalimageAt,o.showpatientAt,o.consultAt,o.pendingapprovalAt,o.reporteddate,o.duration,o.printcount,o.assigneddate
from cte_order as o
INNER JOIN lookup.modality as m on o.modality = m.id
INNER JOIN lookup.examinationtypes as e on o.examinationtype = e.id
INNER JOIN lookup.physicians as p on o.physician = p.id
left JOIN membership.departments as d on d.id = o.referalUnit
left JOIN membership.users as u on u.user_id = o.statusby
where (date_ge(o.reporteddate::date,fromdate::date) and date_le(o.reporteddate::date,todate::date))
       AND ((lower(o.modalityno) like modno OR modno IS NULL )
          OR (lower(o.mrn) like modno OR modno IS NULL  )  
          OR (lower(o.name) like modno OR modno IS NULL  ))
			 AND(o.modalityid = modid OR modid IS NULL)
       AND(e.name ilike examtype OR examtype IS NULL)
       AND(o.submodality::text LIKE ANY (region))
      AND (o.status::text LIKE ANY (stat))
ORDER BY o.reporteddate desc 
	LOOP
		RETURN NEXT outreportroom;
	END LOOP;
END;
$$ LANGUAGE PLPGSQL;

--ris.get_reportedlogs2
create or replace function ris.get_reportedlogs2(timestamp without time zone,timestamp without time zone,int,text[],text,text,text[])
returns setof ris.reportroomresult
as $$
DECLARE 
	fromdate alias for $1;
	todate alias for $2;
  modid alias for $3;
  region alias for $4;
  examtype alias for $5;
  modno alias for $6;
  stat alias for $7;

	outreportroom ris.reportroomresult;
BEGIN
SET join_collapse_limit = 1;
	FOR outreportroom IN

with cte_order as(
select seqno,patnumber,"condition",status,statusby,(patient).mrn,(patient).name,(patient).age,(patient).sex,(patient).phone,
examdate,(exam).examendat,(exam).modalityno,(request).modality as modalityid,(request).modality,
(request).submodality,(request).examinationtype,(request).jobtype,(request).physician, (request).referalUnit,
(report).readingstartAt,(report).additionalimageAt,(report).showpatientAt,(report).consultAt,(report).pendingapprovalAt,reporteddate,
 date_trunc('hour', age(reporteddate::timestamp,(exam).examendat::timestamp)) as duration,(print).printcount,assignedto
from ris.requests
where deleted_at is null and status='reported')
select o.seqno,o.patnumber,o.condition,o.status,o.statusby, initcap(u.full_name) as statusbyname,o.mrn,initcap(o.name) as name,o.age,o.sex,o.phone,
o.examdate,o.examendat,o.modalityno,o.modalityid,m.name as modality,o.submodality,initcap(e.name) as examinationtype,o.jobtype,p.name as physician,d.name as referalUnit,
o.readingstartAt,o.additionalimageAt,o.showpatientAt,o.consultAt,o.pendingapprovalAt,o.reporteddate,o.duration,o.printcount
, o.assignedto,array_to_string(array_agg(r.full_name ORDER BY r.user_role ASC),' / ') AS assignedtolable
from cte_order as o
INNER JOIN lookup.modality as m on o.modality = m.id
INNER JOIN lookup.examinationtypes as e on o.examinationtype = e.id
INNER JOIN lookup.physicians as p on o.physician = p.id
left JOIN membership.departments as d on d.id = o.referalUnit
left JOIN membership.users as u on u.user_id = o.statusby
LEFT JOIN membership.users as r on  r.user_id = any(o.assignedto)

GROUP BY o.seqno,o.patnumber,o.condition,o.status,o.statusby, u.full_name,o.mrn,o.name,o.age,o.sex,o.phone,
o.examdate,o.examendat,o.modalityno,o.modalityid,m.name,o.submodality,e.name,o.jobtype,p.name,d.name,
o.readingstartAt,o.additionalimageAt,o.showpatientAt,o.consultAt,o.pendingapprovalAt,o.reporteddate,o.duration,
o.printcount, o.assignedto

HAVING (date_ge(o.reporteddate::date,fromdate::date) and date_le(o.reporteddate::date,todate::date))
       AND ((lower(o.modalityno) like modno OR modno IS NULL )
          OR (lower(o.mrn) like modno OR modno IS NULL  )  
          OR (lower(o.name) like modno OR modno IS NULL  ))
			 AND(o.modalityid = modid OR modid IS NULL)
       AND(e.name ilike examtype OR examtype IS NULL)
       AND(o.submodality::text LIKE ANY (region))
      AND (o.status::text LIKE ANY (stat))
ORDER BY o.reporteddate 
	LOOP
		RETURN NEXT outreportroom;
	END LOOP;
END;
$$ LANGUAGE PLPGSQL;

--ris.get_myreportedlogs2
create or replace function ris.get_myreportedlogs2(timestamp without time zone,timestamp without time zone,int,text[],text,text,text[], int)
returns setof ris.reportroomresult
as $$
DECLARE 
	fromdate alias for $1;
	todate alias for $2;
  modid alias for $3;
  region alias for $4;
  examtype alias for $5;
  modno alias for $6;
  stat alias for $7;
  senior alias for $8;
	outreportroom ris.reportroomresult;
BEGIN
SET join_collapse_limit = 1;
	FOR outreportroom IN
with cte_order as(
select seqno,patnumber,"condition",status,statusby,(patient).mrn,(patient).name,(patient).age,(patient).sex,(patient).phone,
examdate,assignedto,(exam).examendat,(exam).modalityno,(request).modality as modalityid,(request).modality,
(request).submodality,(request).examinationtype,(request).jobtype,(request).physician, (request).referalUnit,
(report).readingstartAt,(report).additionalimageAt,(report).showpatientAt,(report).consultAt,(report).pendingapprovalAt,reporteddate,
 date_trunc('hour', age(reporteddate::timestamp,(exam).examendat::timestamp)) as duration,(print).printcount,assigneddate
from ris.requests
where deleted_at is null and status='reported')
select o.seqno,o.patnumber,o.condition,o.status,o.statusby, initcap(u.full_name) as statusbyname,o.mrn,initcap(o.name) as name,o.age,o.sex,o.phone,
o.examdate,o.examendat,o.modalityno,o.modalityid,m.name as modality,o.submodality,initcap(e.name) as examinationtype,o.jobtype,p.name as physician,d.name as referalUnit,
o.readingstartAt,o.additionalimageAt,o.showpatientAt,o.consultAt,o.pendingapprovalAt,o.reporteddate,o.duration,o.printcount,o.assigneddate
from cte_order as o
INNER JOIN lookup.modality as m on o.modality = m.id
INNER JOIN lookup.examinationtypes as e on o.examinationtype = e.id
INNER JOIN lookup.physicians as p on o.physician = p.id
left JOIN membership.departments as d on d.id = o.referalUnit
left JOIN membership.users as u on u.user_id = o.statusby
where (date_ge(o.reporteddate::date,fromdate::date) and date_le(o.reporteddate::date,todate::date))
       AND ((lower(o.modalityno) like modno OR modno IS NULL )
          OR (lower(o.mrn) like modno OR modno IS NULL  )  
          OR (lower(o.name) like modno OR modno IS NULL  ))
			 AND(o.modalityid = modid OR modid IS NULL)
       AND(e.name ilike examtype OR examtype IS NULL)
       AND(o.submodality::text LIKE ANY (region))
      AND (o.status::text LIKE ANY (stat))
      AND (assignedto[2] = senior)
ORDER BY o.reporteddate desc 
	LOOP
		RETURN NEXT outreportroom;
	END LOOP;
END;
$$ LANGUAGE PLPGSQL;


--get_archivedlogs
create or replace function ris.get_archivedlogs(int,text[],text,text)
returns setof ris.archivedresult
as $$
DECLARE 
	modid alias for $1;
  region alias for $2;
  examtype alias for $3;
  modno alias for $4;
  
	outarchivedrow ris.archivedresult;
BEGIN
SET join_collapse_limit = 1;
	FOR outarchivedrow IN
with cte_order as(
select seqno,patnumber,"condition",status,statusby,(patient).mrn,(patient).name,(patient).age,(patient).sex,(patient).phone,
examdate,(exam).examendat,(exam).modalityno,(request).modality as modalityid,(request).modality,
(request).submodality,(request).examinationtype,
 date_trunc('day', age(now()::timestamp,COALESCE((exam).examendat::timestamp,examdate::timestamp))) as duration
from ris.requests
where deleted_at is not null)
select o.seqno,o.patnumber,o.condition,o.status,o.statusby, initcap(u.full_name) as statusbyname,o.mrn,initcap(o.name) as name,o.age,o.sex,o.phone,
o.examdate,o.examendat,o.modalityno,o.modalityid,m.name as modality,o.submodality,initcap(e.name) as examinationtype,
o.duration
from cte_order as o
INNER JOIN lookup.modality as m on o.modality = m.id
INNER JOIN lookup.examinationtypes as e on o.examinationtype = e.id
left JOIN membership.users as u on u.user_id = o.statusby

where ((lower(o.modalityno) like modno OR modno IS NULL )
          OR (lower(o.mrn) like modno OR modno IS NULL  )  
          OR (lower(o.name) like modno OR modno IS NULL  ))
			 AND(o.modalityid = modid OR modid IS NULL)
       AND(e.name ilike examtype OR examtype IS NULL)
       AND(o.submodality::text LIKE ANY (region))
       
ORDER BY o.examdate  desc
	LOOP
		RETURN NEXT outarchivedrow;
	END LOOP;
END;
$$ LANGUAGE PLPGSQL;
--ris.get_examrequestbypatientnoseqno
create or replace function ris.get_examrequestbypatientnoseqno(int,int)
returns setof ris.examresult as $$
SET join_collapse_limit = 1;
with cte_order as(
select seqno,patnumber,(patient).mrn,(patient).name,(patient).age,(patient).sex,
(patient).phone,(patient).region,(patient).subcity,examdate,reportdate,condition,status,(request).regdate,(request).receiptno,(patient).pattype,(patient).mobility,(request).jobtype,(request).modality,(request).submodality,(request).examinationtype,(request).referalhos,
(request).referalUnit,(request).physician,(request).phyphone, (request).clinicaldata, (request).prevexamno, (request).prevexamtype, (request).createdby,
(request).cr, (request).bun,(request).scanimg,
(exam).examstartat,(exam).examendat,(exam).modalityno,(exam).contrast,(exam).dos,(exam).isreaction,(exam).reaction,(exam).note,(exam).examBy

from ris.requests
where deleted_at is null)
select o.seqno,o.patnumber,o.mrn,o.name,o.age,o.sex,o.phone,g.name as region, s.name as subcity,
o.examdate,o.reportdate,o.condition,o.status,o.regdate,o.receiptno,o.pattype,o.mobility,
o.jobtype,m.id as modalityid, m.name as modality,o.submodality,e.id as examinationtypeid, e.name as examinationtype,h.name as referalhos,u.name as referalUnit,
initcap(p.name) as physician,o.phyphone, d.name as department,o.clinicaldata,o.prevexamno,o.prevexamtype,r.full_name as createdby,
o.cr,o.bun,o.scanimg,
o.examstartat,o.examendat,o.modalityno,o.contrast,o.dos,o.isreaction,o.reaction,o.note, x.full_name as examBy 
from cte_order as o
INNER JOIN lookup.modality as m on o.modality = m.id
INNER JOIN lookup.examinationtypes as e on o.examinationtype = e.id
INNER JOIN lookup.physicians as p on o.physician = p.id
left JOIN membership.departments as d on d.id = p.department
left JOIN lookup.referalhospital as h on h.id = o.referalhos
left JOIN membership.departments as u on u.id = o.referalUnit
LEFT JOIN membership.users as r on r.user_id = o.createdby 
LEFT JOIN membership.users as x on x.user_id = o.examBy 
LEFT OUTER JOIN lookup.regions as g on o.region = g."id"
LEFT OUTER JOIN lookup.subcities as s on o.subcity = s."id"
where  o.patnumber=$1 and o.seqno = $2;
$$ LANGUAGE SQL;

--ris.get_examrequestexist

create or replace function ris.get_examrequestexist(int,int,int,date)
returns setof ris.examresult as $$
SET join_collapse_limit = 1;
with cte_order as(
select seqno,patnumber,(patient).mrn,(patient).name,(patient).age,(patient).sex,
(patient).phone,(patient).region,(patient).subcity,examdate,reportdate,condition,status,(request).regdate,(request).receiptno,(patient).pattype,(patient).mobility,(request).jobtype,(request).modality,(request).submodality,(request).examinationtype,(request).referalhos,
(request).referalUnit,(request).physician,(request).phyphone, (request).clinicaldata, (request).prevexamno, (request).prevexamtype, (request).createdby,
(request).cr, (request).bun,(request).scanimg,
(exam).examstartat,(exam).examendat,(exam).modalityno,(exam).contrast,(exam).dos,(exam).isreaction,(exam).reaction,(exam).note,(exam).examBy

from ris.requests
where deleted_at is null)
select o.seqno,o.patnumber,o.mrn,o.name,o.age,o.sex,o.phone,g.name as region, s.name as subcity,
o.examdate,o.reportdate,o.condition,o.status,o.regdate,o.receiptno,o.pattype,o.mobility,
o.jobtype,m.id as modalityid, m.name as modality,o.submodality,e.id as examinationtypeid, e.name as examinationtype,h.name as referalhos,u.name as referalUnit,p.name as physician,
o.phyphone, d.name as department,o.clinicaldata,o.prevexamno,o.prevexamtype,r.full_name as createdby,
o.cr,o.bun,o.scanimg,
o.examstartat,o.examendat,o.modalityno,o.contrast,o.dos,o.isreaction,o.reaction,o.note, x.full_name as examBy 
from cte_order as o
INNER JOIN lookup.modality as m on o.modality = m.id
INNER JOIN lookup.examinationtypes as e on o.examinationtype = e.id
INNER JOIN lookup.physicians as p on o.physician = p.id
left JOIN membership.departments as d on d.id = p.department
left JOIN lookup.referalhospital as h on h.id = o.referalhos
left JOIN membership.departments as u on u.id = o.referalUnit
LEFT JOIN membership.users as r on r.user_id = o.createdby 
LEFT JOIN membership.users as x on x.user_id = o.examBy 
LEFT OUTER JOIN lookup.regions as g on o.region = g."id"
LEFT OUTER JOIN lookup.subcities as s on o.subcity = s."id"
where  o.patnumber=$1 and m.id = $2 and e.id = $3 
AND (date_ge(o.regdate::date,$4::date) and date_le(o.regdate::date,$4::date));
$$ LANGUAGE SQL;

--ris.get_appointments
create or replace function ris.get_appointments(date,ris.appointmenttype,int)
returns setof ris.appointmentresult
as $$
DECLARE 
	appointat alias for $1;
  stat alias for $2;
  moda alias for $3;
	outappoin ris.appointmentresult;
BEGIN
SET join_collapse_limit = 1;
	FOR outappoin IN
SELECT a.PatNumber,a.SeqNo,upper(m.name) as modality,upper(e.name) as examinationtype,a.MRN, a.Name, a.Age, a.Sex,P.Phone, r.name as region, c.name as Subcity,a.RegistrationDate,a.AppointedDate,a.Days,a.Reason, 
u.full_name as createdby
FROM ris.appointments as a
left JOIN lookup.modality as m on a.modality = m.id
left JOIN lookup.examinationtypes as e on a.examinationtype = e.id
INNER JOIN core.patients as p on p.PatNumber = a.PatNumber 
INNER JOIN membership.users as u on u.user_id = a.createdby
inner join lookup.regions as r on p.regionid = r.id 
left JOIN lookup.subcities as c on p.subcityid = c.id 

where (date_ge(a.AppointedDate::date,appointat::date) 
      and date_le(a.AppointedDate::date,appointat::date))
			AND (a.modality = moda OR moda IS NULL)
      AND (a.Reason = stat OR stat IS NULL)

ORDER BY a.RegistrationDate asc
	LOOP
		RETURN NEXT outappoin;
	END LOOP;
END;
$$ LANGUAGE PLPGSQL;

--ris.get_patientappointments
create or replace function ris.get_patientappointments(int)
returns setof ris.patientappointmentresult
as $$
DECLARE 
	patno alias for $1;
  outappoin ris.patientappointmentresult;
BEGIN
SET join_collapse_limit = 1;
	FOR outappoin IN
SELECT initcap(m.name) as modality,initcap(e.name) as examinationtype,a.AppointedDate,a.Days,a.Reason
FROM ris.appointments as a
left JOIN lookup.modality as m on a.modality = m.id
left JOIN lookup.examinationtypes as e on a.examinationtype = e.id
where (a.PatNumber = patno)
ORDER BY a.AppointedDate desc
	LOOP
		RETURN NEXT outappoin;
	END LOOP;
END;
$$ LANGUAGE PLPGSQL;

--ris.get_total_appointed
CREATE OR REPLACE FUNCTION ris.get_total_appointed(dt date, modalityid integer) RETURNS integer AS $$
BEGIN
  RETURN (select count(examdate)
  from ris.requests
  where (date_ge(examdate::date,dt::date) 
      and date_le(examdate::date,dt::date))
      and deleted_at is null 
      and (request).modality= modalityid) as total;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION ris.get_total_appointed(dt date) RETURNS integer AS $$
BEGIN
  RETURN (select count(reportdate)
  from ris.requests
  where (date_ge(reportdate::date,dt::date) 
      and deleted_at is null
      and date_le(reportdate::date,dt::date))) as total;
END;
$$ LANGUAGE plpgsql;

--ris.get_examtemplog
create or replace function ris.get_examtemplog(varchar,ris.status,date,date)
returns setof ris.examtemplogresult
as $$
DECLARE 
  term alias for $1;
  stat alias for $2;
  fromdate alias for $3;
  todate alias for $4;
  outlog ris.examtemplogresult;
BEGIN
  SET join_collapse_limit = 1;
	FOR outlog IN
SELECT p.PatNumber,p.seqno,initcap(p.Name) as Name,p.CardNo,p.Sex,p.Age,initcap(m.name) as modality,
initcap(e.name) as examinationtype,p.createdby,r.status
FROM ris.examtemplog as p
INNER JOIN ris.requests as r on p.patnumber = r.patnumber and p.seqno = r.seqno 
left JOIN lookup.modality as m on p.modality = m.id
left JOIN lookup.examinationtypes as e on p.examinationtype = e.id
where ((p.CardNo ILIKE term OR term IS NULL) 
			   OR (p.name ILIKE term OR term IS NULL)
         OR (m.name ILIKE term OR term IS NULL)
         OR (e.name ILIKE term OR term IS NULL))
         AND (r.status = stat OR stat IS NULL)
         AND (date_ge(p.createdat::date,fromdate::date) and date_le(p.createdat::date,todate::date))
      
ORDER BY p.createdat desc
	LOOP
		RETURN NEXT outlog;
	END LOOP;
END;
$$ LANGUAGE PLPGSQL;

--ris.get_examtemplogcount
create or replace function ris.get_examtemplogcount(varchar,ris.status,date,date)
returns setof int
as $$
DECLARE 
	term alias for $1;
  stat alias for $2;
  fromdate alias for $3;
  todate alias for $4;
	total int;
BEGIN
		SELECT count(*)
		into total
		FROM ris.examtemplog	 as p
		left JOIN lookup.modality as m on p.modality = m.id
		left JOIN lookup.examinationtypes as e on p.examinationtype = e.id
    where ((p.CardNo ILIKE term OR term IS NULL) 
			   OR (p.name ILIKE term OR term IS NULL)
         OR (m.name ILIKE term OR term IS NULL)
         OR (e.name ILIKE term OR term IS NULL))
         AND (p.Status = stat OR stat IS NULL)
         AND (date_ge(p.createdat::date,fromdate::date) and date_le(p.createdat::date,todate::date));
		return query
		select total;
END;
$$ LANGUAGE PLPGSQL;

--get_additionalimagelogs
create or replace function ris.get_additionalimagelogs(date, date, text[],text)
returns SETOF ris.additionalimagelogresults
as $$
DECLARE 
	fromdate alias for $1;
	todate alias for $2; 
  stat alias for $3;
  term alias for $4;
  outlog ris.additionalimagelogresults;
BEGIN
SET join_collapse_limit = 1;
	FOR outlog IN
with cte_additionalimagelogs as
(
	with cte_addimgtemp as(
select *
 from ris.additionalimagelogs
 where examstatus = 'additional image') 
select r.*, e.remark as additionalRemark
from cte_addimgtemp as r 
INNER JOIN ris.requests as e on (r.patnumber = e.patnumber) and (r.seqno = e.seqno) 
)
select id,stage,seqno,patnumber,examstatus,mrn,patname,sex,age,modality,region,examtype,remark,status,registerby,registerat,modalityno,processed
,(additionalRemark).status as info
from cte_additionalimagelogs

where (date_ge(registerat::date,fromdate::date) and date_le(registerat::date,todate::date))
      AND (status::text LIKE ANY (stat))
			AND (search_field @@ to_tsquery(term) OR term IS NULL)
ORDER BY  registerat DESC, patnumber DESC, status DESC
	LOOP
		RETURN NEXT outlog;
	END LOOP;
END;
$$ LANGUAGE PLPGSQL;

--end get_additionalimagelogs
--get_additionalimagelogs
create or replace function ris.get_additionalimagelogs(text[],text)
returns SETOF ris.additionalimagelogresults
as $$
DECLARE 
	stat alias for $1;
  term alias for $2;
  outlog ris.additionalimagelogs;
BEGIN
SET join_collapse_limit = 1;
	FOR outlog IN
with cte_additionalimagelogs as
(
	with cte_addimgtemp as(
select *
 from ris.additionalimagelogs
 where examstatus = 'additional image') 
select r.*, e.remark as additionalRemark
from cte_addimgtemp as r 
INNER JOIN ris.requests as e on (r.patnumber = e.patnumber) and (r.seqno = e.seqno) 
)
select id,stage,seqno,patnumber,examstatus,mrn,patname,sex,age,modality,region,examtype,remark,status,registerby,registerat,modalityno,processed
,(additionalRemark).status as info
from cte_additionalimagelogs
where (status::text LIKE ANY (stat))
			AND (search_field @@ to_tsquery(term) OR term IS NULL)
ORDER BY  registerat DESC, patnumber DESC, status DESC
	LOOP
		RETURN NEXT outlog;
	END LOOP;
END;
$$ LANGUAGE PLPGSQL;
create or replace function ris.get_additionalimagelogs(text[],text)
returns SETOF ris.additionalimagelogresults
as $$
DECLARE 
	stat alias for $1;
  term alias for $2;
  outlog ris.additionalimagelogs;
BEGIN
SET join_collapse_limit = 1;
	FOR outlog IN
with cte_additionalimagelogs as
(
	with cte_addimgtemp as(
select *
 from ris.additionalimagelogs
 where examstatus = 'additional image') 
select r.*, e.remark as additionalRemark
from cte_addimgtemp as r 
INNER JOIN ris.requests as e on (r.patnumber = e.patnumber) and (r.seqno = e.seqno) 
)
select id,stage,seqno,patnumber,examstatus,mrn,patname,sex,age,modality,region,examtype,remark,status,registerby,registerat,modalityno,processed
,(additionalRemark).status as info
from cte_additionalimagelogs
where (status::text LIKE ANY (stat))
			AND (search_field @@ to_tsquery(term) OR term IS NULL)
ORDER BY  registerat DESC, patnumber DESC, status DESC
	LOOP
		RETURN NEXT outlog;
	END LOOP;
END;
$$ LANGUAGE PLPGSQL;
--end get_additionalimagelogs

--ris.get_registeredrows

CREATE OR REPLACE FUNCTION ris.get_registeredrows(timestamp with time zone,timestamp with time zone,text[],text)
    RETURNS SETOF ris.recroomresult AS 
$$
DECLARE 
	fromdate alias for $1;
	todate alias for $2; 
  stat alias for $3;
	modno alias for $4;
  outrecroom ris.recroomresult;
BEGIN
SET join_collapse_limit = 1;
	FOR outrecroom IN
with cte_order as(
select seqno,patnumber,(patient).mrn,(patient).name,(patient).age,(patient).sex,replace((patient).phone::text, '-'::text, ''::text)as phone,
(request).regdate,examdate,"condition",status,statusby,(request).jobtype,(request).modality,(request).examinationtype,(request).referalhos,
(request).referalUnit,(request).physician,
date_trunc('hour', age(now(),examdate::timestamp)) as beforeexamdate,
 date_trunc('hour', age(now(),examdate::timestamp)) as afterexamdate,
(remark).status as patstatus
 from ris.requests where deleted_at is null)
select o.seqno,o.patnumber,o.mrn,initcap(o.name) as name,o.age,o.sex,o.phone,o.regdate,o.examdate,
o.condition,o.status,o.statusby, u.full_name as statusbyname, o.jobtype,m.name as modality,initcap(e.name) as examinationtype,o.referalhos,
p.name as physician,d.name as referalUnit,o.beforeexamdate,o.afterexamdate,o.patstatus
from cte_order as o
INNER JOIN lookup.modality as m on o.modality = m.id
INNER JOIN lookup.examinationtypes as e on o.examinationtype = e.id
INNER JOIN lookup.physicians as p on o.physician = p.id
left JOIN membership.departments as d on d.id = o.referalUnit
left JOIN membership.users as u on u.user_id = o.statusby
where (date_ge(o.regdate::date,fromdate::date) and date_le(o.regdate::date,todate::date))
       AND (o.status::text LIKE ANY (stat))
      AND ((lower(o.phone) like modno OR modno IS NULL )
          OR (lower(o.mrn) like modno OR modno IS NULL  )  
          OR (lower(o.name) like modno OR modno IS NULL  ))
ORDER BY o.examdate 
	LOOP
		RETURN NEXT outrecroom;
	END LOOP;
END;
$$ LANGUAGE PLPGSQL;


--ris.get_showpatientrows
CREATE OR REPLACE FUNCTION ris.get_showpatientrows(timestamp with time zone,timestamp with time zone,text[],text,text[])
RETURNS SETOF ris.recroomresult AS 
$$
DECLARE 
	fromdate alias for $1;
	todate alias for $2; 
  stat alias for $3;
  modno alias for $4;
  infostat alias for $5;
	outrecroom ris.recroomresult;
BEGIN
SET join_collapse_limit = 1;
	FOR outrecroom IN
with cte_order as(
select seqno,patnumber,(patient).mrn,(patient).name,(patient).age,(patient).sex,replace((patient).phone::text, '-'::text, ''::text)as phone,
(request).regdate,examdate,"condition",status,statusby,(request).jobtype,(request).modality,(request).examinationtype,(request).referalhos,
(request).referalUnit,(request).physician,
date_trunc('hour', age(now(),examdate::timestamp)) as beforeexamdate,
 date_trunc('hour', age(now(),examdate::timestamp)) as afterexamdate,
(remark).status as patstatus
 from ris.requests where deleted_at is null)
select o.seqno,o.patnumber,o.mrn,initcap(o.name) as name,o.age,o.sex,o.phone,o.regdate,o.examdate,
o.condition,o.status,o.statusby, u.full_name as statusbyname, o.jobtype,m.name as modality,initcap(e.name) as examinationtype,o.referalhos,
p.name as physician,d.name as referalUnit,o.beforeexamdate,o.afterexamdate,o.patstatus
from cte_order as o
INNER JOIN lookup.modality as m on o.modality = m.id
INNER JOIN lookup.examinationtypes as e on o.examinationtype = e.id
INNER JOIN lookup.physicians as p on o.physician = p.id
left JOIN membership.departments as d on d.id = o.referalUnit
left JOIN membership.users as u on u.user_id = o.statusby
where (date_ge(o.regdate::date,fromdate::date) and date_le(o.regdate::date,todate::date))
      AND (o.status::text LIKE ANY (stat))
		  AND ((lower(o.phone) like modno OR modno IS NULL )
          OR (lower(o.mrn) like modno OR modno IS NULL  )  
          OR (lower(o.name) like modno OR modno IS NULL  ))
ORDER BY o.patstatus desc, date_trunc('hour', age(now(),examdate::timestamp)) DESC
--o.patstatus desc ,
	LOOP
		RETURN NEXT outrecroom;
	END LOOP;
END;
$$ LANGUAGE PLPGSQL;


-- ris.get_additionalimagelogs(date, date, text[], text)
CREATE OR REPLACE FUNCTION ris.get_additionalimagelogs(timestamp with time zone,timestamp with time zone,text[],text)
RETURNS SETOF ris.additionalimagelogs AS 
$$
DECLARE 
	fromdate alias for $1;
	todate alias for $2; 
  stat alias for $3;
  term alias for $4;
  outlog ris.additionalimagelogs;
BEGIN
SET join_collapse_limit = 1;
	FOR outlog IN
with cte_additionalimagelogs as(
select *
 from ris.additionalimagelogs where examstatus = 'additional image') 
select r.*
from cte_additionalimagelogs as r 
where (date_ge(r.registerat::date,fromdate::date) and date_le(r.registerat::date,todate::date))
      AND (r.status::text LIKE ANY (stat))
			AND (r.search_field @@ to_tsquery(term) OR term IS NULL)
ORDER BY  r.registerat DESC, r.patnumber DESC, r.status DESC
	LOOP
		RETURN NEXT outlog;
	END LOOP;
END;
$$ LANGUAGE PLPGSQL;

--logbook
create or replace function ris.get_logbookrows(int,text[],varchar)
returns setof ris.logbookresult
as $$
DECLARE 
	modid alias for $1;
  region alias for $2;
  term alias for $3;
  
	outlogbook ris.logbookresult;
BEGIN
SET join_collapse_limit = 1;
	FOR outlogbook IN
with cte_order as(
select seqno,patnumber,(patient).mrn,(patient).name,(patient).age,(patient).sex,(patient).phone,
(exam).modalityno,(request).modality as modalityid,(request).modality,
(request).submodality,(request).examinationtype,
reporteddate,(report).conclussion,(report).addendum, search
from ris.requests
where deleted_at is null and status = 'reported')
select o.seqno,o.patnumber,o.mrn,initcap(o.name) as name,o.age,o.sex,o.phone,
o.modalityno,o.modalityid,m.name as modality,o.submodality,initcap(e.name) as examinationtype,
o.reporteddate,o.conclussion,o.addendum, o.search
from cte_order as o
LEFT JOIN lookup.modality as m on o.modality = m.id
INNER JOIN lookup.examinationtypes as e on o.examinationtype = e.id
where (o.modalityid = modid OR modid IS NULL)
			 AND (o.search @@ to_tsquery(term) OR term IS NULL )
			 AND(o.submodality::text LIKE ANY (region))
       
ORDER BY o.reporteddate desc
	LOOP
		RETURN NEXT outlogbook;
	END LOOP;
END;
$$ LANGUAGE PLPGSQL;


DROP FUNCTION if EXISTS ris.get_logbookrows(timestamp without time zone,timestamp without time zone,int4, int4, int,text[],varchar);
create or replace function ris.get_logbookrows(timestamp without time zone,timestamp without time zone,int4, int4, int,text[],varchar)
returns setof ris.logbookresult
as $$
DECLARE 
  fromdate alias for $1;
  todate alias for $2;
  inhowmany alias for $3;
  page alias for $4;
  modid alias for $5;
  region alias for $6;
  term alias for $7;
  
	outlogbook ris.logbookresult;
BEGIN
SET join_collapse_limit = 1;
	FOR outlogbook IN
with cte_order as(
select seqno,patnumber,(patient).mrn,(patient).name,(patient).age,(patient).sex,(patient).phone,
(exam).modalityno,(request).modality as modalityid,(request).modality,
(request).submodality,(request).examinationtype,
reporteddate,(report).reportcontent, search
from ris.requests
where deleted_at is null and status = 'reported' and (date_ge(reporteddate::date,fromdate::date) and date_le(reporteddate::date,todate::date)))
select o.seqno,o.patnumber,o.mrn,initcap(o.name) as name,o.age,o.sex,o.phone,
o.modalityno,o.modalityid,m.name as modality,o.submodality,initcap(e.name) as examinationtype,
o.reporteddate,o.reportcontent, o.search
from cte_order as o
LEFT JOIN lookup.modality as m on o.modality = m.id
INNER JOIN lookup.examinationtypes as e on o.examinationtype = e.id
where (o.modalityid = modid OR modid IS NULL)
			 AND (o.search @@ to_tsquery(term) OR term IS NULL )
			 AND(o.submodality::text LIKE ANY (region))
       
ORDER BY o.reporteddate desc
			limit inhowmany
			OFFSET page
	LOOP
		RETURN NEXT outlogbook;
	END LOOP;
END;
$$ LANGUAGE PLPGSQL;

--logbook
DROP FUNCTION if EXISTS ris.get_logbookrowscount(timestamp without time zone,timestamp without time zone,int,text[],varchar);
create or replace function ris.get_logbookrowscount(timestamp without time zone,timestamp without time zone,int,text[],varchar)
returns setof int
as $$
DECLARE
  fromdate alias for $1;
  todate alias for $2; 
  modid alias for $3;
  region alias for $4;
  term alias for $5;
  
  total int;
BEGIN
SET join_collapse_limit = 1;

with cte_order as(
select seqno,patnumber,(patient).mrn,(patient).name,(patient).age,(patient).sex,(patient).phone,
(exam).modalityno,(request).modality as modalityid,(request).modality,
(request).submodality,(request).examinationtype,
reporteddate,(report).reportcontent, search
from ris.requests
where deleted_at is null and status = 'reported' and (date_ge(reporteddate::date,fromdate::date) and date_le(reporteddate::date,todate::date)))
SELECT count(*) into total
from cte_order as o
LEFT JOIN lookup.modality as m on o.modality = m.id
INNER JOIN lookup.examinationtypes as e on o.examinationtype = e.id
where (o.modalityid = modid OR modid IS NULL)
			 AND (o.search @@ to_tsquery(term) OR term IS NULL )
			 AND(o.submodality::text LIKE ANY (region));
return query
		select total;
END;
$$ LANGUAGE PLPGSQL;


--get_assignementcountbyuser
CREATE OR REPLACE FUNCTION ris.get_assignementcountbyuser(date,date,integer)
    RETURNS SETOF ris.summary 
AS $$
DECLARE
  fromdate alias for $1;
  todate alias for $2; 
  uid alias for $3; 
  outsummary ris.summary;
BEGIN
SET join_collapse_limit = 1;
	FOR outsummary IN
	  with cte_order as(
		select r.status as status, r.assignedto,r.assigneddate,U.full_name AS Name
		from ris.requests as r 
		LEFT JOIN membership.users as u on u.user_id = ANY(r.assignedto)
		where (U.user_id = uid) and (deleted_at is null) AND (date_ge(r.assigneddate::date,fromdate::date) and date_le(r.assigneddate::date,todate::date))
		)
		select status, name, COUNT(*) 
		FROM cte_order 
		GROUP BY rollup(status, Name)
		having name is not null	
	LOOP
		RETURN NEXT outsummary;
	END LOOP;
END;
$$ LANGUAGE PLPGSQL;

--get_assignementcountbyuser
CREATE OR REPLACE FUNCTION ris.get_assignementcountbyuser(integer)
    RETURNS SETOF ris.summary 
AS $$
DECLARE
  uid alias for $1; 
  outsummary ris.summary;
BEGIN
SET join_collapse_limit = 1;
	FOR outsummary IN
	  with cte_order as(
		select r.status as status, r.assignedto,r.assigneddate,U.full_name AS Name
		from ris.requests as r 
		LEFT JOIN membership.users as u on u.user_id = ANY(r.assignedto)
		where (U.user_id = uid) and (deleted_at is null) 
		)
		select status, name, COUNT(*) 
		FROM cte_order 
		GROUP BY rollup(status, Name)
		having name is not null	
	LOOP
		RETURN NEXT outsummary;
	END LOOP;
END;
$$ LANGUAGE PLPGSQL;

--get_pastduedatecases
CREATE OR REPLACE FUNCTION ris.get_pastduedatecases(
	integer)
    RETURNS SETOF ris.summary 
AS $$
DECLARE
  uid alias for $1; 
  outsummary ris.summary;
BEGIN
SET join_collapse_limit = 1;
	FOR outsummary IN
	  with cte_order as(
			select r.status as status, r.assignedto,r.assigneddate,r.reportdate , date_part('DAY', now() - r.reportdate) as Days, U.full_name AS Name
			from ris.requests as r 
			LEFT JOIN membership.users as u on u.user_id = ANY(r.assignedto)
			where (U.user_id = uid) and (deleted_at is null) and (status <> 'reported')
		)
		select status, name, COUNT(*) 
		FROM cte_order 
		GROUP BY rollup(status, Name)
		having name is not null	
	LOOP
		RETURN NEXT outsummary;
	END LOOP;
END;
$$ LANGUAGE PLPGSQL;

--get_showpatientbystatusrows
CREATE OR REPLACE FUNCTION ris.get_showpatientbystatusrows(date,date,text[],text,text[])
    RETURNS SETOF ris.recroomresult 
 AS $$

DECLARE 
	fromdate alias for $1;
	todate alias for $2; 
  stat alias for $3;
  modno alias for $4;
  infostat alias for $5;
	outrecroom ris.recroomresult;
BEGIN
SET join_collapse_limit = 1;
	FOR outrecroom IN
with cte_order as(
select seqno,patnumber,(patient).mrn,(patient).name,(patient).age,(patient).sex,replace((patient).phone::text, '-'::text, ''::text)as phone,
(request).regdate,examdate,"condition",status,statusby,(request).jobtype,(request).modality,(request).examinationtype,(request).referalhos,
(request).referalUnit,(request).physician,
date_trunc('hour', age(now(),examdate::timestamp)) as beforeexamdate,
 date_trunc('hour', age(now(),examdate::timestamp)) as afterexamdate,
(remark).status as patstatus
 from ris.requests where deleted_at is null)
select o.seqno,o.patnumber,o.mrn,initcap(o.name) as name,o.age,o.sex,o.phone,o.regdate,o.examdate,
o.condition,o.status,o.statusby, u.full_name as statusbyname, o.jobtype,m.name as modality,initcap(e.name) as examinationtype,o.referalhos,
p.name as physician,d.name as referalUnit,o.beforeexamdate,o.afterexamdate,o.patstatus
from cte_order as o
INNER JOIN lookup.modality as m on o.modality = m.id
INNER JOIN lookup.examinationtypes as e on o.examinationtype = e.id
INNER JOIN lookup.physicians as p on o.physician = p.id
left JOIN membership.departments as d on d.id = o.referalUnit
left JOIN membership.users as u on u.user_id = o.statusby
where (date_ge(o.regdate::date,fromdate::date) and date_le(o.regdate::date,todate::date))
      AND (o.status::text LIKE ANY (stat))
			AND (o.patstatus::text LIKE ANY (infostat))
      AND ((lower(o.phone) like modno OR modno IS NULL )
          OR (lower(o.mrn) like modno OR modno IS NULL  )  
          OR (lower(o.name) like modno OR modno IS NULL  ))
ORDER BY  date_trunc('hour', age(now(),examdate::timestamp)) DESC
--o.patstatus desc ,
	LOOP
		RETURN NEXT outrecroom;
	END LOOP;
END;
$$ LANGUAGE PLPGSQL;

--get_showpatientrows
CREATE OR REPLACE FUNCTION ris.get_showpatientrows(
	date,
	date,
	text[],
	text,
	text[])
    RETURNS SETOF ris.recroomresult 
AS $$
DECLARE 
	fromdate alias for $1;
	todate alias for $2; 
  stat alias for $3;
  modno alias for $4;
  infostat alias for $5;
	outrecroom ris.recroomresult;
BEGIN
SET join_collapse_limit = 1;
	FOR outrecroom IN
with cte_order as(
select seqno,patnumber,(patient).mrn,(patient).name,(patient).age,(patient).sex,replace((patient).phone::text, '-'::text, ''::text)as phone,
(request).regdate,examdate,"condition",status,statusby,(request).jobtype,(request).modality,(request).examinationtype,(request).referalhos,
(request).referalUnit,(request).physician,
date_trunc('hour', age(now(),examdate::timestamp)) as beforeexamdate,
 date_trunc('hour', age(now(),examdate::timestamp)) as afterexamdate,
(remark).status as patstatus
 from ris.requests where deleted_at is null)
select o.seqno,o.patnumber,o.mrn,initcap(o.name) as name,o.age,o.sex,o.phone,o.regdate,o.examdate,
o.condition,o.status,o.statusby, u.full_name as statusbyname, o.jobtype,m.name as modality,initcap(e.name) as examinationtype,o.referalhos,
p.name as physician,d.name as referalUnit,o.beforeexamdate,o.afterexamdate,o.patstatus
from cte_order as o
INNER JOIN lookup.modality as m on o.modality = m.id
INNER JOIN lookup.examinationtypes as e on o.examinationtype = e.id
INNER JOIN lookup.physicians as p on o.physician = p.id
left JOIN membership.departments as d on d.id = o.referalUnit
left JOIN membership.users as u on u.user_id = o.statusby
where (date_ge(o.regdate::date,fromdate::date) and date_le(o.regdate::date,todate::date))
      AND (o.status::text LIKE ANY (stat))
		  AND ((lower(o.phone) like modno OR modno IS NULL )
          OR (lower(o.mrn) like modno OR modno IS NULL  )  
          OR (lower(o.name) like modno OR modno IS NULL  ))
ORDER BY o.patstatus desc, date_trunc('hour', age(now(),examdate::timestamp)) DESC
--o.patstatus desc ,
	LOOP
		RETURN NEXT outrecroom;
	END LOOP;
END;
$$ LANGUAGE PLPGSQL;




CREATE OR REPLACE FUNCTION ris.get_reportroomrowsbyjobtype(IN timestamp without time zone,IN timestamp without time zone,IN integer,IN text[],IN character varying,IN text[],IN text[])
    RETURNS SETOF ris.reportroomresult
    LANGUAGE 'plpgsql'

AS $BODY$
DECLARE 
	fromdate alias for $1;
	todate alias for $2;
  modid alias for $3;
  region alias for $4;
  modno alias for $5;
  stat alias for $6;
	jobtypes 	alias for $7;

	outreportroom ris.reportroomresult;
BEGIN
SET join_collapse_limit = 1;
	FOR outreportroom IN
with cte_order as(
select seqno,patnumber,"condition",status,statusby,(patient).mrn,(patient).name,(patient).age,(patient).sex,(patient).phone,
examdate,(exam).examendat,(exam).modalityno,(request).modality as modalityid,(request).modality,
(request).submodality,(request).examinationtype,(request).jobtype,(request).physician, (request).referalUnit,
(report).readingstartAt,(report).additionalimageAt,(report).showpatientAt,(report).consultAt,(report).pendingapprovalAt,
reporteddate,
date_trunc('hour', age(now(),(exam).examendat::timestamp)) as duration,(print).printcount,assigneddate,assignedto,assignedby
from ris.requests
where deleted_at is null and reporteddate is null)
select o.seqno,o.patnumber,o.condition,o.status,o.statusby, initcap(u.full_name) as statusbyname,o.mrn,initcap(o.name) as name,o.age,o.sex,o.phone,
o.examdate,o.examendat,o.modalityno,o.modalityid,m.name as modality,o.submodality,initcap(e.name) as examinationtype,o.jobtype,
p.name as physician,d.name as referalUnit,
o.readingstartAt,o.additionalimageAt,o.showpatientAt,o.consultAt,o.pendingapprovalAt,o.reporteddate,o.duration,o.printcount,o.assigneddate,
o.assignedto,array_to_string(array_agg(r.full_name ORDER BY r.user_role ASC),' / ') AS assignedtolable,o.assignedby
from cte_order as o
LEFT JOIN lookup.modality as m on o.modality = m.id
INNER JOIN lookup.examinationtypes as e on o.examinationtype = e.id
INNER JOIN lookup.physicians as p on o.physician = p.id
left JOIN membership.departments as d on d.id = o.referalUnit
left JOIN membership.users as u on u.user_id = o.statusby
LEFT JOIN membership.users as r on  r.user_id = any(o.assignedto)
group by o.seqno,o.patnumber,o.condition,o.status,o.statusby, u.full_name,o.mrn,o.name,o.age,o.sex,o.phone,
o.examdate,o.examendat,o.modalityno,o.modalityid,m.name,o.submodality,e.name,o.jobtype,p.name,d.name,
o.readingstartAt,o.additionalimageAt,o.showpatientAt,o.consultAt,o.pendingapprovalAt,o.reporteddate,o.duration,o.printcount,o.assignedto,o.assigneddate,o.assignedby
having (date_ge(o.examendat::date,fromdate::date) and date_le(o.examendat::date,todate::date))
       AND(o.modalityid = modid OR modid IS NULL)
			 AND ((lower(o.modalityno) like modno OR modno IS NULL )
          OR (lower(o.mrn) like modno OR modno IS NULL  )  
          OR (lower(o.name) like modno OR modno IS NULL  ))
			 AND(o.submodality::text LIKE ANY (region))
       AND (o.status::text LIKE ANY (stat))
       AND (o.jobtype::text LIKE ANY (jobtypes))
ORDER BY o.status ,o.condition asc 
	LOOP
		RETURN NEXT outreportroom;
	END LOOP;
END;
$BODY$;

CREATE OR REPLACE FUNCTION ris.get_reportroomrowsbyfil(IN date,IN date,IN integer,IN text[],IN character varying,IN text[],IN text[],IN smallint[])
    RETURNS SETOF ris.reportroomresult
    LANGUAGE 'plpgsql'

AS $BODY$
DECLARE 
	fromdate alias for $1;
	todate alias for $2;
  modid alias for $3;
  region alias for $4;
  modno alias for $5;
  jobtypes 	alias for $6;
  stat alias for $7;
	assignfor alias for $8;
	
	outreportroom ris.reportroomresult;
BEGIN
SET join_collapse_limit = 1;
	FOR outreportroom IN
with cte_order as(
select seqno,patnumber,"condition",status,statusby,(patient).mrn,(patient).name,(patient).age,(patient).sex,(patient).phone,
examdate,(exam).examendat,(exam).modalityno,(request).modality as modalityid,(request).modality,
(request).submodality,(request).examinationtype,(request).jobtype,(request).physician, (request).referalUnit,
(report).readingstartAt,(report).additionalimageAt,(report).showpatientAt,(report).consultAt,(report).pendingapprovalAt,
reporteddate,
date_trunc('hour', age(now(),(exam).examendat::timestamp)) as duration,(print).printcount,
assigneddate,assignedto,assignedby
from ris.requests
where deleted_at is null and reporteddate is null)
select o.seqno,o.patnumber,o.condition,o.status,o.statusby, initcap(u.full_name) as statusbyname,o.mrn,initcap(o.name) as name,o.age,o.sex,o.phone,
o.examdate,o.examendat,o.modalityno,o.modalityid,m.name as modality,o.submodality,initcap(e.name) as examinationtype,o.jobtype,
p.name as physician,d.name as referalUnit,
o.readingstartAt,o.additionalimageAt,o.showpatientAt,o.consultAt,o.pendingapprovalAt,o.reporteddate,o.duration,o.printcount,o.assigneddate,
o.assignedto,array_to_string(array_agg(r.full_name ORDER BY r.user_role ASC),' / ') AS assignedtolable,o.assignedby
from cte_order as o
LEFT JOIN lookup.modality as m on o.modality = m.id
INNER JOIN lookup.examinationtypes as e on o.examinationtype = e.id
INNER JOIN lookup.physicians as p on o.physician = p.id
left JOIN membership.departments as d on d.id = o.referalUnit
left JOIN membership.users as u on u.user_id = o.statusby
LEFT JOIN membership.users as r on  r.user_id = any(o.assignedto)
group by o.seqno,o.patnumber,o.condition,o.status,o.statusby, u.full_name,o.mrn,o.name,o.age,o.sex,o.phone,
o.examdate,o.examendat,o.modalityno,o.modalityid,m.name,o.submodality,e.name,o.jobtype,p.name,d.name,
o.readingstartAt,o.additionalimageAt,o.showpatientAt,o.consultAt,o.pendingapprovalAt,o.reporteddate,o.duration,o.printcount,
o.assignedto,o.assigneddate,o.assignedby
having (date_ge(o.examendat::date,fromdate::date) and date_le(o.examendat::date,todate::date))
       AND(o.modalityid = modid OR modid IS NULL)
			 AND(o.submodality::text LIKE ANY (region))
       AND ((lower(o.modalityno) like modno OR modno IS NULL )
          OR (lower(o.mrn) like modno OR modno IS NULL  )  
          OR (lower(o.name) like modno OR modno IS NULL  ))       
       AND (o.jobtype::text LIKE ANY (jobtypes))	
			 AND (o.status::text LIKE ANY (stat))	
       AND(o.assignedto @> (assignfor::smallint[]))
ORDER BY o.status ,o.condition asc 
	LOOP
		RETURN NEXT outreportroom;
	END LOOP;
END;
$BODY$;


