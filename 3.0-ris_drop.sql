-- DROP
--VIEW
drop view if exists ris.reportlog ;

--Table
drop table if exists ris.additionalimagelogs CASCADE;
drop table if exists ris.supervisors CASCADE;
drop table if exists ris.radiologyprefer CASCADE;
drop table if exists ris.appointments CASCADE;
drop table if exists ris.examtemplog CASCADE;
drop table if exists ris.requests CASCADE;
drop table if exists ris.audit CASCADE;
drop table if exists ris.showpatientlogs CASCADE;
drop table if exists ris.template_pk_counter;
drop table if exists ris.templates;
--complex type
drop type if exists ris.patient_info CASCADE;
drop type if exists ris.request_form CASCADE;
drop type if exists ris.examroom_form CASCADE;
drop type if exists ris.report_form CASCADE;
--enums
drop type if exists ris.examresult CASCADE;
drop type if exists ris.prevexamtype CASCADE;
drop type if exists ris.conditions CASCADE;
drop type if exists ris.mobilities CASCADE;
drop type if exists ris.patienttype CASCADE;
drop type if exists ris.paymenttype CASCADE; 
drop type if exists ris.hospitalinfo CASCADE;
drop type if exists ris.status CASCADE;
drop type if exists ris.submodalitytype CASCADE;

--TYPE
drop type if exists ris.infotype CASCADE;
drop type if exists ris.requestformresult CASCADE;
drop type if exists ris.summary CASCADE;
drop type if exists ris.appointmenttype CASCADE;
drop type if exists ris.patientappointmentresult CASCADE;
drop type if exists ris.appointmentresult CASCADE;
drop type if exists ris.registerresult CASCADE; 
drop type if exists ris.recroomresult CASCADE;
drop type if exists ris.examroomresult CASCADE;
drop type if exists ris.reportroomresult CASCADE;
drop type if exists ris.examresult CASCADE;
drop type if exists ris.examtemplogresult CASCADE;
drop type if exists ris.archivedresult CASCADE;
drop type if exists ris.logbookresult CASCADE;
drop type if exists ris.additionalimagelogresults CASCADE;
drop type if exists ris.additionalimagestatus  CASCADE;
drop type if exists ris.print_info CASCADE;
drop type if exists ris.remark_info CASCADE;
drop type if exists ris.additionalimage_form CASCADE;
drop type if exists ris.showpatientlogs CASCADE;
drop type if exists ris.templatetypes CASCADE;

--FUNCTION
drop FUNCTION if exists ris.audit_trigger();
drop function if exists ris.get_additionalimagelogs(date, date, text[],text);
drop function if exists ris.get_additionalimagelogs(text[],text);
drop function if exists ris.get_register_orders(int);
drop function if exists ris.get_receptionrows(date,date,text[]);
drop function if exists ris.get_receptionrows(date,date,text[],text);
drop function if exists ris.get_receptionrows(date,date,text[],text,text);
drop function if exists ris.get_receptionrows(date,date,text[],text[],text);
drop function if exists ris.get_examroomrowsforadmin(date,date,text[]);
drop function if exists ris.get_examroomrows(date,date,int,text[]);
drop function if exists ris.get_assignroomrows(date,date,text[],boolean);
drop function if exists ris.get_reportroomrows(date,date,int,text[],varchar,text[]);
drop function if exists ris.get_reportroomrows(date,date,int,text[],varchar,text[],smallint[]);
drop function if exists ris.get_reportroomrows(date,date,int,ris.submodalitytype,varchar,text[]);-- todo remove this
drop function if exists ris.get_reportroomrows(date,date,int,text[],varchar,text[]);
drop function if exists ris.get_reportedlogs(date,date,int,text[],varchar,varchar,text[]);
drop function if exists ris.get_examrequestbypatientnoseqno(int,int);
drop function if exists ris.get_examrequestexist(int,int,int,date);
drop function if exists ris.get_appointments(date,ris.appointmenttype,int);
drop function if exists ris.get_patientappointments(int);
drop function if exists ris.get_examtemplog(varchar,ris.status,date,date);
drop function if exists ris.get_examtemplogcount(varchar,ris.status,date,date);
drop function if exists ris.get_total_appointed(date);
drop function if exists ris.get_total_appointed(date,integer);
drop function if exists ris.get_assignementcount();
drop function if exists ris.get_assignementcount(date,date, int);
drop function if exists ris.template_pk_next() CASCADE;
DROP FUNCTION if exists ris.get_assignementcountbyuser(date, date, integer) CASCADE;
DROP FUNCTION if exists ris.get_assignementcountbyuser(integer) CASCADE;
DROP FUNCTION if exists ris.get_pastduedatecases(integer) CASCADE;
DROP FUNCTION if exists ris.get_showpatientrows(date, date, text[], text, text[]) CASCADE;
DROP FUNCTION if exists ris.get_showpatientbystatusrows(date, date, text[], text, text[]) CASCADE;

--index
drop index if EXISTS ris.idx_reportlog_btree_patnumber;

--SCHEMA
drop schema if exists ris;
create schema ris;
