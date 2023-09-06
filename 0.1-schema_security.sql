CREATE ROLE risuser WITH LOGIN password '[password here]';
alter DATABASE risdb OWNER TO postgres;

--ACCESS SCHEMA
REVOKE USAGE ON SCHEMA membership FROM risuser;
REVOKE USAGE ON SCHEMA core FROM risuser;
REVOKE USAGE ON SCHEMA ris FROM risuser;
REVOKE USAGE ON SCHEMA lookup FROM risuser;

REVOKE SELECT, INSERT, UPDATE         ON ALL TABLES IN SCHEMA membership FROM risuser ;
REVOKE SELECT, INSERT, UPDATE         ON ALL TABLES IN SCHEMA core FROM risuser ;
REVOKE SELECT, INSERT, UPDATE         ON ALL TABLES IN SCHEMA ris FROM risuser ;
REVOKE SELECT, INSERT, UPDATE         ON ALL TABLES IN SCHEMA lookup FROM risuser ;


GRANT USAGE ON SCHEMA membership TO ris;
GRANT USAGE ON SCHEMA core TO ris;
GRANT USAGE ON SCHEMA ris TO ris;
GRANT USAGE ON SCHEMA lookup TO ris;

--ACCESS TABLES
GRANT SELECT, INSERT, UPDATE         ON ALL TABLES IN SCHEMA membership TO ris ;
GRANT SELECT, INSERT, UPDATE         ON ALL TABLES IN SCHEMA core TO ris ;
GRANT SELECT, INSERT, UPDATE         ON ALL TABLES IN SCHEMA ris TO ris ;
GRANT SELECT, INSERT, UPDATE         ON ALL TABLES IN SCHEMA lookup TO ris ;

GRANT SELECT, INSERT, UPDATE, DELETE  ON ris.appointments TO ris ;
GRANT SELECT, INSERT, UPDATE, DELETE  ON ris.examtemplog TO ris ;
GRANT SELECT, INSERT, UPDATE, DELETE  ON core.patientnames TO ris ;

GRANT SELECT, INSERT, UPDATE         ON ALL TABLES IN SCHEMA membership TO risuser ;
GRANT SELECT, INSERT, UPDATE         ON ALL TABLES IN SCHEMA core TO risuser ;
GRANT SELECT, INSERT, UPDATE         ON ALL TABLES IN SCHEMA ris TO risuser ;
GRANT SELECT, INSERT, UPDATE         ON ALL TABLES IN SCHEMA lookup TO risuser ;

CREATE USER backadm SUPERUSER  password '[password here]';
ALTER USER backadm set default_transaction_read_only = on;