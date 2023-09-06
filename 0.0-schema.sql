drop schema if exists membership;
create schema membership;

drop schema if exists core;
create schema core;

drop schema if exists lookup;
create schema lookup;


drop schema if exists ris;
create schema ris;

--------------

CREATE ROLE risuser WITH LOGIN password '[password here]';

GRANT "risuser" TO "postgres";

alter DATABASE "risdb" OWNER TO "risuser";

GRANT membership TO risuser;

GRANT USAGE ON SCHEMA membership TO risuser;
GRANT USAGE ON SCHEMA core TO risuser;
GRANT USAGE ON SCHEMA ris TO risuser;
GRANT USAGE ON SCHEMA lookup TO risuser;

--GRANT SELECT                         ON ALL TABLES IN SCHEMA membership TO read_only ;
--GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA membership TO read_write ;
GRANT ALL                            ON ALL TABLES IN SCHEMA membership TO risuser ;
GRANT ALL                            ON ALL TABLES IN SCHEMA core TO risuser ;
GRANT ALL                            ON ALL TABLES IN SCHEMA ris TO risuser ;
GRANT ALL                            ON ALL TABLES IN SCHEMA lookup TO risuser ;

