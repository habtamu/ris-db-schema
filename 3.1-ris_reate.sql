--index
create index idx_reportlog_btree_patnumber on ris.reportlog using btree (patnumber);

--ENUM
CREATE TYPE ris.status AS ENUM ('registered', 'request', 'start exam', 'ready for reading', 'reading', 'additional image', 'show patient', 'consult requested', 'pending approval', 'reported');
CREATE TYPE ris.submodalitytype AS ENUM ('', 'head & neck','chest & cardiovascular','body','musculoskeletal', 'spine');
CREATE TYPE ris.patienttype AS ENUM ('OPD', 'IPD', 'Emergency');
CREATE TYPE ris.paymenttype AS ENUM ('free', 'private wing', 'normal');
CREATE TYPE ris.conditions AS ENUM ('Critical','Emergency','Stable');
CREATE TYPE ris.mobilities AS ENUM ('walking','wheelchair','stretcher','ambulance');
CREATE TYPE ris.prevexamtype AS ENUM ('', 'CT', 'MRI','XRAY');
CREATE TYPE ris.appointmenttype AS ENUM ('procedure', 'report');
CREATE TYPE ris.infotype AS ENUM ('pending','success', 'failed');
CREATE TYPE ris.additionalimagestatus AS ENUM ('requested','send to exam', 'ready');
CREATE TYPE ris.templatetypes AS ENUM ('Default', 'Custom');

--TYPE
create type ris.requestformresult AS(
   seqno smallint,
   PatNumber int,

   mrn text,
	 name text,
	 sex char(1),
   age text,
   phone text,

	 regdate timestamp,
	 status ris.status, 
   examdate timestamp,
	 condition ris.conditions,
   mobility ris.mobilities,
   pattype ris.patienttype,
   receiptno text,
   jobtype  ris.paymenttype,  
	 modality text,
	 submodality ris.submodalitytype,
   examinationtype text,
   
   referalhos text,
	 referalUnit text,
   physician text,
   phyphone text,
   clinicaldata text,
   scanimg text,
	 createdby text,
   prevexamno text,
	 prevexamtype ris.prevexamtype,
	 
   examstartat timestamp,
   examendat timestamp,
   modalityno text,
   contrast boolean ,
   dos text,
   isreaction boolean ,
   reaction text,
   note text,
   examBy text,

   readingstartat timestamp,
   readingBy text,
   pendingapprovalBy text,
   reportcontent text,
   additionalimageRem text,
   reporteddate timestamp,
   statusby text,
   duration text

);
create type ris.summary AS (
  status text,
  name text,
  count int
);
create type ris.registerresult AS(
   regdate timestamp,
   examdate timestamp,
	 condition text,
   status text,
   seqno smallint,
   PatNumber int,
   mrn text,
	 name text,
	 sex char(1),
   age text,
   phone text,
   region text,
   subcity  text,
   receiptno text,
   jobtype  text,  
	 modality text,
   examinationtype text,
   referalUnit text,
   physician text,
   createdby text,
   clinicaldata text,
   modalityno text
);
CREATE TYPE ris.recroomresult AS (
  seqno	smallint,
	patnumber int,
	mrn text,
	name text,
	age text,
  sex char(1),
  phone text,
  regdate timestamp without time zone,
	examdate timestamp without time zone,
  condition  text,
  status text,
  statusby  smallint,
  statusbyname text,
  jobtype text,
	modality  text,
  examinationtype text,
  referalhos SMALLINT,
	physician text,
  referalUnit text,
  beforeexamdate TEXT,
  afterexamdate TEXT,
  patstatus TEXT
);
CREATE TYPE ris.examroomresult AS (
  seqno	smallint,
	patnumber int,
	mrn text,
	name text,
	age text,
  sex char(1),
  phone text,
  regdate timestamp without time zone,
	examdate timestamp without time zone,
requestdur text,
  examstartat timestamp without time zone,
examstartatdur text,
  examendat timestamp without time zone,
examendatdur text,
  condition  text,
  status text,
  statusby  smallint,
  statusbyname text,
  jobtype text,
	modality  text,
  examinationtype text,
  referalhos text,
	physician text,
  referalUnit text
);
CREATE TYPE ris.reportroomresult AS (
  seqno	smallint,
  patnumber int,
  condition ris.conditions,
  status text,
  statusby  smallint,
  statusbyname text,
  -- patient info
  mrn text,
  name text,
  age text,
  sex char(1),
  phone text,
  -- exam info	
  examdate timestamp without time zone,
  examendat timestamp without time zone,
  modalityno text,
  modalityid  smallint,  
  modality  text,
  submodality ris.submodalitytype,
  examinationtype text,
  jobtype text,
  physician text,
  referalUnit text,
  --status
  readingstartAt timestamp without time zone,
  additionalimageAt timestamp without time zone,
  showpatientAt timestamp without time zone,
  consultAt timestamp without time zone,
  pendingapprovalAt timestamp without time zone,
  reporteddate timestamp without time zone,
	duration text,
	--PRINT info
	printcount smallint,  
	--status
  assigneddate timestamp without time zone,
  assignedto smallint[],
  assignedtolable text,
  assignedby smallint
 
);
CREATE TYPE ris.examresult AS (
  seqno	smallint,
	patnumber int,
	mrn text,
	name text,
	age text,
  sex char(1),
  phone text,
  region text,
  subcity  text,
  examdate timestamp without time zone,
  reportdate timestamp without time zone,
	condition  ris.conditions,
  status ris.status,
  regdate  timestamp without time zone,
  receiptno text,
  pattype ris.patienttype,
  mobility ris.mobilities,
  jobtype ris.paymenttype,
  modalityid smallint,
	modality  text,
  submodality ris.submodalitytype,
  examinationtypeid smallint,
  examinationtype text,
  referalhos text,
	referalUnit text,
  physician text,
  phyphone text,
  department text,
  clinicaldata text,
  prevexamno text,
  prevexamtype ris.prevexamtype,
  createdby text,
	cr numeric(13,2),
  bun numeric(13,2),
  scanimg text,
  examstartat timestamp without time zone,
  examendat timestamp without time zone,
  modalityno text,
  contrast boolean ,
  dos text,
  isreaction boolean ,
  reaction text,
  note text,
  examBy text
  
);
create type ris.patientappointmentresult AS(
   modality  text,
   examinationtype text,
   AppointedDate timestamp,
   Days SMALLINT,
   Reason text
);
create type ris.appointmentresult AS(
   PatNumber int,
   SeqNo smallint,
   modality  text,
   examinationtype text,
   MRN text,
   Name text,
   Age text ,
   Sex char(1),
   Phone text,
   Region text,
   Subcity  text,
   RegistrationDate timestamp,
   AppointedDate timestamp,
   Days SMALLINT,
   Reason text,
   createdby text
);
create type ris.examtemplogresult AS (
   PatNumber int,
   seqno smallint,
   Name text,
   CardNo text,
   Sex char(1),
   Age text,
   modality  text,
   examinationtype text,
   createdby smallint,
	 Status text
);
create type ris.additionalimagelogresults AS (
	 id	smallint ,
   stage	smallint ,
	 seqno	smallint ,
	 patnumber int ,
   examstatus ris.status,
   mrn	text,
	 patname text,
   sex char(1),
   age text,
   modality text,
   region text,
   examtype text,
   remark text,
   status ris.additionalimagestatus,
	 registerby text,
	 registerat timestamptz ,
   modalityno text,
   processed BOOLEAN ,
   info text
);

CREATE TYPE ris.logbookresult AS (
  seqno	smallint,
  patnumber int,
  mrn text,
  name text,
  age text,
  sex char(1),
  phone text,
  -- exam info	
  modalityno text,
  modalityid smallint,
  modality  text,
  submodality ris.submodalitytype,
  examinationtype text,
  --status
  reporteddate timestamp without time zone,
	conclussion text,
  addendum text
);
CREATE TYPE ris.archivedresult AS (
  seqno	smallint,
  patnumber int,
  condition ris.conditions,
  status text,
  statusby  smallint,
  statusbyname text,
  -- patient info
  mrn text,
  name text,
  age text,
  sex char(1),
  phone text,
  -- exam info	
  examdate timestamp without time zone,
  examendat timestamp without time zone,
  modalityno text,
  modalityid  smallint,  
  modality  text,
  submodality ris.submodalitytype,
  examinationtype text,
  --status
  duration text
	
);
-- Complex  type
CREATE TYPE ris.print_info AS (
  printcount smallint,
  lastprintby text,
  lastprintat timestamp without time zone
);
CREATE TYPE ris.patient_info AS (
	  mrn text,
	  name text,
	  age varchar,
    sex char( 1),
    phone text,
    region smallint,
    subcity smallint,
    pattype ris.patienttype,
    mobility ris.mobilities
   
);
CREATE TYPE ris.request_form AS (
	regdate timestamp without time zone,
	modality  smallint,
  submodality ris.submodalitytype,
	examinationtype smallint,
  receiptno text,
  jobtype ris.paymenttype,
  referalhos smallint,
	referalUnit smallint,
  clinicaldata text, 
  physician smallint,  
  prevexamno text, 
  prevexamtype ris.prevexamtype, 
  createdby smallint,
  phyphone text,
  cr numeric(13,2),
  bun numeric(13,2),
  scanimg text
);
CREATE TYPE ris.examroom_form AS (
  examstartat timestamp without time zone,
  examendat timestamp without time zone,
  modalityno text,
  contrast boolean ,
  dos text,
  isreaction boolean ,
  reaction text,
  note text,
  examBy smallint --10
);
CREATE TYPE ris.report_form AS (
  readingstartAt timestamp without time zone,
	readingBy smallint,

	additionalimage boolean,
	additionalimageAt timestamp without time zone,
	repeat bool ,
	additionalimageRem varchar,
	additionalimageBy smallint,

	showpatient boolean,
	showpatientAt timestamp without time zone,
	showpatientRem text,
  showpatientBy smallint,

	consult boolean,
	consultAt timestamp without time zone,
	consultBy smallint,

	reportcontent text,
  scanimg text[],

	pendingapproval boolean,
	pendingapprovalAt timestamp without time zone,
	pendingapprovalBy smallint,

	reportedAt timestamp without time zone,
	reportedby smallint
  
);
CREATE TYPE ris.remark_info AS (
	  date timestamp without time zone,
	  status ris.infotype,
    remark text,
    remarkby text
);
CREATE TYPE ris.additionalimage_form AS(
--request by info	
	requestAt timestamp without time zone,
	requestBy smallint,
	repeat bool,
  prevImageBy smallint,
	reqremark text,
--Exam by info
	imageBy smallint,
  imageDate timestamp without time zone,
  newmodalityno text,
  resremark text  
);

--TABLE
create table ris.requests (
   examdate timestamp without time zone,
   reportdate timestamp without time zone,
   reporteddate timestamp without time zone,
	 status ris.status, -- RIS Status   
   statusby smallint,
   assignedto smallint[],
   assigneddate timestamp without time zone,
   assignedby smallint,
	 seqno	smallint not null,
	 patnumber int not null ,
   condition ris.conditions,
   patient ris.patient_info, -- patient Info
   request ris.request_form, -- Request Form\
   exam ris.examroom_form, -- Exam Room form
   report ris.report_form, --Report form
   print ris.print_info, -- Print form
   remark ris.remark_info, -- Reception Remark form
   additionalimage ris.additionalimage_form, --Additinal image form
   lastopenat timestamp without time zone DEFAULT now(),
   deleted_at timestamp without time zone,
   search tsvector
);
create table ris.appointments (
   PatNumber int,
   SeqNo smallint,
   modality  smallint,
   examinationtype smallint,
   MRN text,
   Name text,
   Age text ,
   Sex char(1),
   RegistrationDate timestamp without time zone NOT NULL default now(),
   AppointedDate timestamp without time zone NOT NULL,
   Days SMALLINT not null,
   Reason ris.appointmenttype,
   createdby smallint,
   deleted_at timestamp without time zone
	 
);
create table ris.examtemplog (
   PatNumber int not null ,
   seqno smallint,
	 Name text not null,
   CardNo text not null,
   Sex char(1) not null,
   Age text not null,
   modality  smallint,
   examinationtype smallint,
   Status ris.status NOT NULL DEFAULT 'registered'::ris.status,
   createdat timestamp without time zone NOT NULL default now(),
   createdby smallint,
   deleted_at timestamp without time zone
);
create table ris.supervisors (
   residentid	smallint not null,
	 supervisor smallint[] not null 
);
create table ris.radiologyprefer (
   userid	smallint not null,
	 part ris.submodalitytype[] not null 
);
create table ris.additionalimagelogs (
   id	smallint not null,
   stage	smallint not null,
	 seqno	smallint not null,
	 patnumber int not null ,
   examstatus ris.status not null DEFAULT 'additional image',
   mrn	text,
	 patname text,
   sex char(1),
   age text,
   modality text,
   region text,
   examtype text,
   remark text,
   status ris.additionalimagestatus,
	 registerby text,
	 registerat timestamptz not null default now(),
   modalityno text,
   processed BOOLEAN DEFAULT false,
   body jsonb,
   search_field tsvector
);
CREATE TRIGGER additionalimagelogs_search_vector_refresh
BEFORE INSERT OR UPDATE ON ris.additionalimagelogs
FOR EACH ROW EXECUTE PROCEDURE
tsvector_update_trigger(search_field, 'pg_catalog.english', modalityno,  mrn, patname, modality,region, examtype ,registerby);

create table ris.showpatientlogs (
   seqno	smallint not null,
	 patnumber int not null ,
   remark text,
   registerby text,
	 registerat timestamptz not null default now()
);
ALTER TABLE ris.showpatientlogs
  OWNER TO risuser;
CREATE TABLE ris.audit (
	event_time timestamp NOT NULL,
	user_name varchar NOT NULL,
	operation text NOT NULL,
	table_name text NOT NULL,
	old_row jsonb,
	new_row jsonb
);
ALTER TABLE ris.audit
  OWNER TO risuser;

CREATE OR REPLACE FUNCTION ris.audit_trigger()
RETURNS TRIGGER AS $$
BEGIN
IF (TG_OP = 'INSERT') THEN
INSERT INTO ris.audit
VALUES (CURRENT_TIMESTAMP, CURRENT_USER,TG_OP,
TG_TABLE_NAME, null , row_to_json(NEW));
RETURN NEW;
ELSIF (TG_OP = 'UPDATE') THEN
INSERT INTO ris.audit
VALUES (CURRENT_TIMESTAMP, CURRENT_USER,TG_OP,
TG_TABLE_NAME, row_to_json(OLD), row_to_json(NEW));
RETURN NEW;
END IF;
RETURN NULL;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER ris_audit_trigger
AFTER UPDATE OR INSERT OR DELETE
ON ris.requests
FOR EACH ROW
EXECUTE PROCEDURE ris.audit_trigger();


CREATE TABLE ris.template_pk_counter
(       
	template_pk int
);
INSERT INTO ris.template_pk_counter VALUES (0);
CREATE RULE noins_template_pk AS ON INSERT TO ris.template_pk_counter
DO NOTHING;
CREATE RULE nodel_only_template_pk AS ON DELETE TO ris.template_pk_counter
DO NOTHING;

CREATE OR REPLACE FUNCTION ris.template_pk_next()
returns int AS
$$
  DECLARE
   next_pk int;
	BEGIN
     UPDATE ris.template_pk_counter set template_pk = template_pk + 1;
     SELECT INTO next_pk template_pk from ris.template_pk_counter;
     RETURN next_pk;
  END;
$$ LANGUAGE 'plpgsql';

create table ris.templates (
   id int DEFAULT ris.template_pk_next(),
   name text,
	 modality  smallint,
   submodality ris.submodalitytype,
   content text, 
   templatetype ris.templatetypes,
   createdby text
);
CREATE RULE nodel_templates AS ON DELETE TO ris.templates
DO NOTHING;  

--VIEW

DROP MATERIALIZED VIEW if EXISTS ris.reportlog;
create MATERIALIZED view ris.reportlog 
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

ALTER MATERIALIZED view ris.reportlog OWNER TO ris;

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

ALTER view ris.reportlog OWNER TO risuser;

--index
create index idx_log_new_row_on_audit ON ris.audit USING GIN (new_row jsonb_path_ops);
create index idx_search_requests on ris.requests using GIST (search);

--ROLE
GRANT USAGE ON SCHEMA ris TO risuser;
GRANT SELECT, INSERT, UPDATE         ON ALL TABLES IN SCHEMA ris TO risuser ;
GRANT SELECT, INSERT, UPDATE, DELETE  ON ris.appointments TO risuser ;
GRANT SELECT, INSERT, UPDATE, DELETE  ON ris.examtemplog TO risuser ;
