drop table if exists membership.users_pk_counter;
drop table if exists membership.permissions;
drop table if exists membership.user_logins;
drop trigger if exists users_search_vector_refresh on membership.users;
drop table if exists membership.users;
drop table if exists membership.roles;
drop table if exists membership.departments;
drop table if exists membership.operations;
drop table if exists membership.signup_pk_counter CASCADE;
drop table if exists membership.signups CASCADE;
drop table if exists membership.notices CASCADE;

drop function if exists membership.user_pk_next();
drop function if exists membership.signup_pk_next() CASCADE;

-- CREATE TABLE
create table membership.departments(
	id smallserial primary key not null,
	name varchar(25) not null UNIQUE,
	isReferal boolean default false,
  isActive boolean default true
);
create table membership.roles(
	id smallint primary key not null,
	name varchar(25) not null
);
CREATE TABLE membership.users_pk_counter
(       
	user_pk int2
);
INSERT INTO membership.users_pk_counter VALUES (0);
CREATE RULE noins_user_pk AS ON INSERT TO membership.users_pk_counter
DO NOTHING;
CREATE RULE nodel_only_user_pk AS ON DELETE TO membership.users_pk_counter
DO NOTHING;

CREATE OR REPLACE FUNCTION membership.user_pk_next()
returns int2 AS
$$
  DECLARE
   next_pk int2;
	BEGIN
     UPDATE membership.users_pk_counter set user_pk = user_pk + 1;
     SELECT INTO next_pk user_pk from membership.users_pk_counter;
     RETURN next_pk;
  END;
$$ LANGUAGE 'plpgsql';

create table membership.users(
	user_id int2 primary key DEFAULT membership.user_pk_next(),
	user_name varchar(45) unique not null,
	full_name varchar(45),
	password varchar(32) not null,
  user_role SMALLINT not null references membership.roles(id) on delete cascade,
  unit_id SMALLINT references lookup.modality(id),
  is_active boolean default true,
	is_administrator boolean default false,
	search_field tsvector,
  current_signin_at timestamptz,
	last_signin_at  timestamptz,
	signin_count int,	
	created_at timestamptz not null default now()
);
create table membership.user_logins (
	id serial primary key not null,
  user_id int not null references membership.users(user_id) on delete cascade,
	current_signin_at timestamptz,
	last_signin_at  timestamptz,
  ip inet
);
create table membership.operations(
	operation_id SMALLINT primary key not null,
	description varchar(255) not null
);
create table membership.permissions(
	user_id SMALLINT not null references membership.users(user_id) on delete cascade,
	operation_id SMALLINT not null references membership.operations(operation_id) on delete cascade,
  is_permitted boolean DEFAULT false,
	primary key (user_id, operation_id)
);

CREATE TRIGGER users_search_vector_refresh
BEFORE INSERT OR UPDATE ON membership.users
FOR EACH ROW EXECUTE PROCEDURE
tsvector_update_trigger(search_field, 'pg_catalog.english',  user_name, full_name);

CREATE TABLE membership.signup_pk_counter
(       
	signup_pk int2
);
INSERT INTO membership.signup_pk_counter VALUES (0);
CREATE RULE noins_signup_pk AS ON INSERT TO membership.signup_pk_counter
DO NOTHING;
CREATE RULE nodel_only_signup_pk AS ON DELETE TO membership.signup_pk_counter
DO NOTHING;

CREATE OR REPLACE FUNCTION membership.signup_pk_next()
returns int2 AS
$$
  DECLARE
   next_pk int2;
	BEGIN
     UPDATE membership.signup_pk_counter set signup_pk = signup_pk + 1;
     SELECT INTO next_pk signup_pk from membership.signup_pk_counter;
     RETURN next_pk;
  END;
$$ LANGUAGE 'plpgsql';

create table membership.signups(
  id int2 primary key DEFAULT membership.signup_pk_next(),
	phone varchar(45) unique not null,
	full_name text,
  email text,
  password text,
  user_id int,
  isassigned boolean default false,
  emailsent boolean default false,
	created_at timestamptz not null default now()
);
ALTER TABLE membership.signup_pk_counter OWNER TO ris;
ALTER TABLE membership.signups OWNER TO ris;

CREATE TABLE membership.notices (
id serial NOT NULL,
info text COLLATE "default" NOT NULL,
CONSTRAINT notices_pkey PRIMARY KEY (id)
);
ALTER TABLE membership.notices OWNER TO ris;