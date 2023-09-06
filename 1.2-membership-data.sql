
-- INSERT
-- user groups (System Admin, Receptionist,Radiography Technologist,Radiology Resident,Radiologist,Team leader,Physician)
insert into membership.departments(name,isreferal) values('Ward',true),('ER',true),('ICU',true);
insert into membership.roles(id,name) values(1,'System Admin'),(2,'Receptionist'),(3,'Radiography Technologist'),(4,'Radiology Resident'),(5,'Radiologist'),(6,'Coordinator/Assigner'),(7,'Physician');

insert into membership.users(user_name, full_name, password,user_role,is_administrator) 
values ('admin', 'Administrator',md5('1'),1, true);

insert into membership.operations(operation_id,description) values(1,'[Security] Can maintain user permissions?');
insert into membership.operations(operation_id,description) values(2,'[Patient] Can edit patient demographic data?');

insert into membership.operations(operation_id,description) values(10,'[Exam] Can add new patient exam?');
insert into membership.operations(operation_id,description) values(11,'[Exam] Can update existing patient exam?');
insert into membership.operations(operation_id,description) values(12,'[Exam] Can remove existing patient exam?');
insert into membership.operations(operation_id,description) values(13,'[Exam] Can Preview patient details?');
insert into membership.operations(operation_id,description) values(14,'[Exam] Can Merge exam request to patient?');

insert into membership.operations(operation_id,description) values(20,'[Report] Can export to pdf or print radiology report ?');
insert into membership.operations(operation_id,description) values(21,'[Report] Can view radiology reports ?');
insert into membership.operations(operation_id,description) values(22,'[Report] Can generate radiology informatics report?');

insert into membership.operations(operation_id,description) values(30,'[Page] Can view appointment page?');
insert into membership.operations(operation_id,description) values(31,'[Page] Can view Re-Assign page?');
insert into membership.operations(operation_id,description) values(32,'[Page] Can view patient logs?');
INSERT INTO membership.operations(operation_id,description) values(33,'[Page] Can view archived exams?');

insert into membership.operations(operation_id,description) values(41,'[Form] Can re-asign exam?');
insert into membership.operations(operation_id,description) values(42,'[Form] Can re-edit final reported radiology report?');

insert into membership.operations(operation_id,description) values(43,'[Form] Can edit exam room report form?');

INSERT INTO membership.operations(operation_id,description) values(50, '[Template] Can remove existing report template?');

-- SELECT
select * from membership.users;

--ROLE
GRANT USAGE ON SCHEMA membership TO risuser;
GRANT SELECT, INSERT, UPDATE         ON ALL TABLES IN SCHEMA membership TO risuser ;
