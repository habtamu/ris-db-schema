
--Tip: PG stats
--to reset-
--select pg_stat_statements_reset();

select
(total_time / 1000 / 60) as total_minutes,
 (total_time/calls) as average_time,
 query
 from pg_stat_statements
 where query not like '%pgbench%' and query not like 'BEGIN;%' and query not like 'END;%' 
 order by 1 desc
 limit 100;

-- Tip: export data
Copy (
with cte_order as(
select seqno,patnumber,"condition",status,statusby,(patient).mrn,(patient).name,(patient).age,(patient).sex,(patient).phone,
examdate,(exam).examendat,(exam).modalityno,(request).modality as modalityid,(request).modality,
(request).submodality,(request).examinationtype,(request).jobtype,(request).physician, (request).referalUnit,
(report).readingstartAt,(report).additionalimageAt,(report).showpatientAt,(report).consultAt,(report).pendingapprovalAt,reporteddate,
 date_trunc('hour', age(reporteddate::timestamp,(exam).examendat::timestamp)) as duration,(print).printcount
from ris.requests
where deleted_at is null and status='reported')
select o.seqno,o.patnumber,o.condition,o.status,o.statusby, initcap(u.full_name) as statusbyname,o.mrn,initcap(o.name) as name,o.age,o.sex,o.phone,
o.examdate,o.examendat,o.modalityno,o.modalityid,m.name as modality,o.submodality,initcap(e.name) as examinationtype,o.jobtype,p.name as physician,d.name as referalUnit,
o.readingstartAt,o.additionalimageAt,o.showpatientAt,o.consultAt,o.pendingapprovalAt,o.reporteddate,o.duration,o.printcount
from cte_order as o
INNER JOIN lookup.modality as m on o.modality = m.id
INNER JOIN lookup.examinationtypes as e on o.examinationtype = e.id
INNER JOIN lookup.physicians as p on o.physician = p.id
left JOIN membership.departments as d on d.id = o.referalUnit
left JOIN membership.users as u on u.user_id = o.statusby
ORDER BY o.reporteddate asc 
) 
To 'w:\\reportedlogs.csv' With CSV DELIMITER ',';

-- Tips: Column order
SELECT a.attname, t.typname, t.typalign, t.typlen
  FROM pg_class c
  JOIN pg_attribute a ON (a.attrelid = c.oid)
  JOIN pg_type t ON (t.oid = a.atttypid)
 WHERE c.relname = 'user_order'
   AND a.attnum >= 0
 ORDER BY t.typlen DESC;

--Change FROM
CREATE TABLE user_order (
  is_shipped    BOOLEAN NOT NULL DEFAULT FALSE,
  user_id       BIGINT NOT NULL,
  order_total   NUMERIC NOT NULL,
  order_dt      TIMESTAMPTZ NOT NULL,
  order_type    SMALLINT NOT NULL,
  ship_dt       TIMESTAMPTZ,
  item_ct       INT NOT NULL,
  ship_cost     NUMERIC,
  receive_dt    TIMESTAMPTZ,
  tracking_cd   TEXT,
  id            BIGSERIAL PRIMARY KEY NOT NULL
);
--TO
DROP TABLE user_order;
 
CREATE TABLE user_order (
  id            BIGSERIAL PRIMARY KEY NOT NULL,
  user_id       BIGINT NOT NULL,
  order_dt      TIMESTAMPTZ NOT NULL,
  ship_dt       TIMESTAMPTZ,
  receive_dt    TIMESTAMPTZ,
  item_ct       INT NOT NULL,
  order_type    SMALLINT NOT NULL,
  is_shipped    BOOLEAN NOT NULL DEFAULT FALSE,
  order_total   NUMERIC NOT NULL,
  ship_cost     NUMERIC,
  tracking_cd   TEXT
);

-- Tip: utility for total usage
--See how much space your tables (and indexes!) are taking up

SELECT
   relname AS table_name,
   pg_size_pretty(pg_total_relation_size(relid)) AS total,
   pg_size_pretty(pg_relation_size(relid)) AS internal,
   pg_size_pretty(pg_table_size(relid) - pg_relation_size(relid)) AS external,
   pg_size_pretty(pg_indexes_size(relid)) AS indexes
    FROM pg_catalog.pg_statio_user_tables ORDER BY pg_total_relation_size(relid) DESC;


----------------------------------------------------------------

-- Tip: Enum
--- Alter Enum
ALTER TYPE ris.submodalitytype ADD VALUE 'breast' BEFORE 'body';
---
CREATE TYPE mood AS ENUM ('sad', 'ok', 'happy');
--To rename an enum value
ALTER TYPE mood RENAME VALUE 'happy' TO 'happy2';
--To add a new value to an enum type in a particular sort position
ALTER TYPE colors ADD VALUE 'orange' AFTER 'red';

CREATE TABLE person (
	name text,
	current_mood mood
);
INSERT INTO person VALUES ('Moe', 'happy');
SELECT * FROM person;

--To remove value ('val1') from enum ('enum_test') you can use:
DELETE FROM pg_enum
WHERE enumlabel = 'val1'
AND enumtypid = (
  SELECT oid FROM pg_type WHERE typname = 'enum_test'
);


----------------------------------------------------------------

with cte_order as(
select seqno,patnumber,status,examdate,
EXTRACT ( day from (now()::timestamp - examdate)::INTERVAL) as days
from ris.requests
where deleted_at is  null)
select o.seqno,o.patnumber,o.status, o.days
from cte_order as o
where o.status <> 'reported' and o.days > 60
order by o.examdate desc
----------------

--Tip: Array

select * 
from ris.requests
where status::text LIKE ANY (array['registered', 'request', 'start exam'])

select e.enumsortorder, e.enumlabel 
from pg_type t, pg_enum e 
where t.oid = e.enumtypid and t.typname='status' 
and e.enumsortorder::real = any (array[1, 2])

--to search array value
--select * from ris.requests where assignedto[1]  = ANY (array[4])

-- on  function call 
--c#
--select * from payment.get_paymentorders(@0,@1,@2,@3,@4::payment.orderstatus[]);

-- on function
create or replace function payment.get_paymentorders(date,date,text,SMALLINT,payment.orderstatus[])
returns setof payment.paymentorderresult
as $$
DECLARE
  fromdate alias for $1; 
	todate alias for $2;
  searchterm alias for $3;
  orderby alias for $4; 
  stat alias for $5; 
  outrow payment.paymentorderresult;
BEGIN
SET join_collapse_limit = 1;
	FOR outrow IN
SELECT o.id,o."registerat" as "date",o.patnumber,o.cardno,o.patientname,
o.sex,o.age,u.full_name as orderedby,o.discount,o.addition,o.creditamount,o.grandtotal as total,
c.full_name as cashier, s.name as salespoint,o.status,o.receiveat,o.remark
 from payment.orders as o
INNER JOIN membership.users as u on o.registerby = u.user_id
LEFT JOIN  membership.users as c on o.cashierid = u.user_id
LEFT JOIN membership.departments as s on o.salepointid = s.id
where (date_ge(o."registerat"::date,fromdate::date) and date_le(o."registerat"::date,todate::date))
			AND ((lower(o.cardno) like searchterm OR searchterm IS NULL )
          OR (lower(o.patientname) like searchterm OR searchterm IS NULL  ))
      AND (o.registerby = orderby OR orderby IS NULL)
      AND (o.status::payment.orderstatus = ANY (array[stat]))
ORDER BY o."registerat" DESC
	LOOP
		RETURN NEXT outrow;
	END LOOP;
END;
$$ LANGUAGE PLPGSQL;


--Tip: Audit logs
drop TABLE service_request;
CREATE TABLE service_request (
	customer_id INTEGER,
	description text,
	cre_user text DEFAULT CURRENT_USER,
	cre_timestamp timestamp DEFAULT CURRENT_TIMESTAMP
  --post_time time default now()
);

CREATE TABLE service_request_log (
           customer_id INTEGER,
           description text,
           mod_type char(1),
           mod_user text DEFAULT CURRENT_USER,
           mod_timestamp timestamp DEFAULT CURRENT_TIMESTAMP);

CREATE RULE service_request_update AS -- UPDATE rule
         ON UPDATE TO service_request
         DO
         INSERT INTO service_request_log (customer_id, description, mod_type)
         VALUES (old.customer_id, old.description, 'U');

CREATE RULE service_request_delete AS -- DELETE rule
         ON DELETE TO service_request
         DO
         INSERT INTO service_request_log (customer_id, description, mod_type)
         VALUES (old.customer_id, old.description, 'D');		   
	
insert INTO service_request(customer_id,description) values (1,'First customer');
update service_request set description='First customer updated' where customer_id = 1;
select * from service_request;
select * from service_request_log;

--Tip: functions
------------------------
CREATE FUNCTION clean_emp() RETURNS void AS $$
DELETE FROM emp
WHERE salary < 0;
$$ LANGUAGE SQL;
------
CREATE FUNCTION one() RETURNS integer AS $$
SELECT 1 AS result;
$$ LANGUAGE SQL;
select one();
--------
CREATE FUNCTION add_em(integer, integer) RETURNS integer AS $$
SELECT $1 + $2;
$$ LANGUAGE SQL;
SELECT add_em(1, 2) AS answer;

CREATE FUNCTION add_em(x integer, y integer) RETURNS integer AS $$
SELECT x + y;
$$ LANGUAGE SQL;
SELECT add_em(1, 2) AS answer;
---------

CREATE FUNCTION tf1 (accountno integer, debit numeric) RETURNS integer AS $$
UPDATE bank
SET balance = balance - debit
WHERE accountno = tf1.accountno;
SELECT 1;
$$ LANGUAGE SQL;

SELECT tf1(17, 100.0);
--------------

CREATE FUNCTION tf1 (accountno integer, debit numeric) RETURNS integer AS $$
UPDATE bank
SET balance = balance - debit
WHERE accountno = tf1.accountno;
SELECT balance FROM bank WHERE accountno = tf1.accountno;
$$ LANGUAGE SQL;

-- OR
CREATE FUNCTION tf1 (accountno integer, debit numeric) RETURNS integer AS $$
UPDATE bank
SET balance = balance - debit
WHERE accountno = tf1.accountno
RETURNING balance;
$$ LANGUAGE SQL;
------------------
-------
CREATE FUNCTION sum_n_product (x int, y int, OUT sum int, OUT product int) AS $$
SELECT x + y, x * y
$$ LANGUAGE SQL;
SELECT * FROM sum_n_product(11,42);
 -- OR
CREATE TYPE sum_prod AS (sum int, product int);
CREATE FUNCTION sum_n_product2 (int, int) RETURNS sum_prod AS $$
SELECT $1 + $2, $1 * $2
$$ LANGUAGE SQL;
SELECT * FROM sum_n_product2(11,42);
---

CREATE FUNCTION mleast(VARIADIC arr numeric[]) RETURNS numeric AS $$
SELECT min($1[i]) FROM generate_subscripts($1, 1) g(i);
$$ LANGUAGE SQL;
SELECT mleast(10, -1, 5, 4.4);
SELECT mleast(VARIADIC ARRAY[10, -1, 5, 4.4]);
----

CREATE FUNCTION foo(a int, b int DEFAULT 2, c int DEFAULT 3)
RETURNS int
LANGUAGE SQL
AS $$
SELECT $1 + $2 + $3;
$$;
SELECT foo(10, 20, 30);
SELECT foo(10, 20);
-----


CREATE TABLE foo (fooid int, foosubid int, fooname text);
	INSERT INTO foo VALUES (1, 1, 'Joe');
	INSERT INTO foo VALUES (1, 2, 'Ed');
	INSERT INTO foo VALUES (2, 1, 'Mary');

CREATE FUNCTION getfoo(int) RETURNS foo AS $$
SELECT * FROM foo WHERE fooid = $1;
$$ LANGUAGE SQL;
SELECT *, upper(fooname) FROM getfoo(1) AS t1;
----
CREATE FUNCTION getfoo2(int) RETURNS SETOF foo AS $$
SELECT * FROM foo WHERE fooid = $1;
$$ LANGUAGE SQL;

SELECT * FROM getfoo2(1) AS t1;
----------
CREATE TABLE tab (y int, z int);
INSERT INTO tab VALUES (1, 2), (3, 4), (5, 6), (7, 8);
CREATE FUNCTION sum_n_product_with_tab (x int, OUT sum int, OUT product int)
RETURNS SETOF record
AS $$
SELECT $1 + tab.y, $1 * tab.y FROM tab;
$$ LANGUAGE SQL;
SELECT * FROM sum_n_product_with_tab(10);
-----
CREATE FUNCTION sum_n_product_with_tab2 (x int)
RETURNS TABLE(sum int, product int) AS $$
SELECT $1 + tab.y, $1 * tab.y FROM tab;
$$ LANGUAGE SQL;

select * FROM sum_n_product_with_tab2(1);
-------
CREATE FUNCTION concat_values(text, VARIADIC anyarray) RETURNS text AS $$
SELECT array_to_string($2, $1);
$$ LANGUAGE SQL;
SELECT concat_values('|', 1, 4, 2);
------
CREATE FUNCTION anyleast (VARIADIC anyarray) RETURNS anyelement AS $$
SELECT min($1[i] COLLATE "en_US") FROM generate_subscripts($1, 1) g(i);
$$ LANGUAGE SQL;
SELECT anyleast('abc'::text, 'ABC');
---

CREATE FUNCTION test(int) RETURNS int
AS $$
select $1 as result;
$  LANGUAGE C;
CREATE FUNCTION test(int, int) RETURNS intAS $$
select $1 + $2 as result;
$$ LANGUAGE C;
----
CREATE TABLE invoice (
invoice_no integer PRIMARY KEY,
seller_no integer, -- ID of salesperson
invoice_date date, -- date of sale
invoice_amt numeric(13,2) -- amount of sale
);

CREATE MATERIALIZED VIEW sales_summary AS
SELECT
seller_no,invoice_date,sum(invoice_amt)::numeric(13,2) as sales_amt
FROM invoice
WHERE invoice_date < CURRENT_DATE
GROUP BY seller_no, invoice_date
ORDER BY seller_no,invoice_date;

CREATE UNIQUE INDEX sales_summary_seller ON sales_summary (seller_no, invoice_date);

REFRESH MATERIALIZED VIEW sales_summary;
------------------------

CREATE TABLE shoelace_log (
sl_name text, -- shoelace changed
sl_avail integer, -- new available value
log_who text, -- who did it
log_when timestamp -- when
);
CREATE RULE log_shoelace AS ON UPDATE TO shoelace_data
WHERE NEW.sl_avail <> OLD.sl_avail
DO INSERT INTO shoelace_log VALUES (
NEW.sl_name,
NEW.sl_avail,
current_user,
current_timestamp
);

UPDATE shoelace_data SET sl_avail = 6 WHERE sl_name = ’sl7’;
--------

SELECT depname, empno, salary,
rank() OVER (PARTITION BY depname ORDER BY salary DESC)
FROM empsalary;
----------

CREATE FUNCTION dept(text) RETURNS dept
AS $$ SELECT * FROM dept WHERE name = $1 $$
LANGUAGE SQL;
----

CREATE FUNCTION concat_lower_or_upper(a text, b text, uppercase boolean DEFAULT false)
RETURNS text
AS
$$
SELECT CASE
WHEN $3 THEN UPPER($1 || ' ' || $2)
ELSE LOWER($1 || ' ' || $2)
END;
$$
LANGUAGE SQL IMMUTABLE STRICT;

select * from concat_lower_or_upper('abc','def', true);
SELECT concat_lower_or_upper(a => 'Hello', b => 'World');

-------

CREATE TABLE products (
product_no integer,
name text,
price numeric CHECK (price > 0),
discounted_price numeric CHECK (discounted_price > 0),
CHECK (price > discounted_price)
);

--------
CREATE TABLE products (
product_no integer PRIMARY KEY,
name text,
price numeric
);
CREATE TABLE orders (
order_id integer PRIMARY KEY,
shipping_address text,
...
);
CREATE TABLE order_items (
product_no integer REFERENCES products ON DELETE RESTRICT,
order_id integer REFERENCES orders ON DELETE CASCADE,
quantity integer,
PRIMARY KEY (product_no, order_id)
);
-------

WITH moved_rows AS (
DELETE FROM products
WHERE
"date" >= ’2010-10-01’ AND
"date" < ’2010-11-01’
RETURNING *
)
INSERT INTO products_log
SELECT * FROM moved_rows;
--------


DROP FUNCTION ts_plus_num(TIMESTAMP, INTEGER) CASCADE;
DROP FUNCTION ts_plus_num(TIMESTAMPTZ, INTEGER) CASCADE;

CREATE OR REPLACE FUNCTION ts_plus_num(tzMod TIMESTAMP, nDays INTEGER)
RETURNS TIMESTAMP AS
$$
  SELECT tzMod + (nDays || ' days')::INTERVAL;;
$$ LANGUAGE SQL STABLE;
 
CREATE OPERATOR + (
  PROCEDURE = ts_plus_num,
  LEFTARG = TIMESTAMP,
  RIGHTARG = INTEGER
);

CREATE OR REPLACE FUNCTION ts_plus_num(tzMod TIMESTAMPTZ, nDays INTEGER)
RETURNS TIMESTAMPTZ AS
$$
  SELECT tzMod + (nDays || ' days')::INTERVAL;;
$$ LANGUAGE SQL STABLE;
 
CREATE OPERATOR + (
  PROCEDURE = ts_plus_num,
  LEFTARG = TIMESTAMPTZ,
  RIGHTARG = INTEGER
);

SELECT CURRENT_DATE::TIMESTAMP + 1;

SELECT CURRENT_DATE::TIMESTAMPTZ + 1;

-----------------------------
--returning a single record using SQL function
CREATE OR REPLACE FUNCTION fn_sqltestout(param_subject text, pos integer) 
    RETURNS TABLE(subject_scramble text, subject_char text)
   AS
$$
    SELECT  substring($1, 1,CAST(random()*length($1) As integer)) , 
      substring($1, 1,1) As subject_char;
    $$
  LANGUAGE 'sql' VOLATILE;
-- example use
SELECT  (fn_sqltestout('This is a test subject')).subject_scramble;
SELECT subject_scramble, subject_char FROM fn_sqltestout('This is a test subject');

--Same function but written in plpgsql
--PLPGSQL example -- return one record
CREATE OR REPLACE FUNCTION fn_plpgsqltestout(param_subject text)
  RETURNS TABLE(subject_scramble text, subject_char text)
   AS
$$
BEGIN
    subject_scramble := substring($1, 1,CAST(random()*length($1) As integer));
    subject_char := substring($1, 1,1);
    RETURN NEXT;
END;
    $$
  LANGUAGE 'plpgsql' VOLATILE;

-- example use
SELECT  (fn_sqltestout('This is a test subject')).subject_scramble;
SELECT subject_scramble, subject_char FROM fn_sqltestout('This is a test subject');
-- test data to use --
CREATE TABLE testtable(id integer PRIMARY KEY, test text);
INSERT INTO testtable(id,test)
VALUES (1, 'Potato'), (2, 'Potato'), (3, 'Cheese'), (4, 'Cheese Dog');

--SQL function returning multiple records
CREATE OR REPLACE FUNCTION fn_sqltestmulti(param_subject varchar) 
    RETURNS TABLE(test_id integer, test_stuff text)
   AS
$$
    SELECT id, test
        FROM testtable WHERE test LIKE $1;
$$
  LANGUAGE 'sql' VOLATILE;
  
 -- example use
SELECT (fn_sqltestmulti('Cheese%')).test_stuff;
SELECT test_stuff FROM fn_sqltestmulti('Cheese%');

-- plpgsql function returning multiple records
-- note RETURN QUERY was introduced in 8.3
-- variant 1
CREATE OR REPLACE FUNCTION fn_plpgsqltestmulti(param_subject varchar) 
    RETURNS TABLE(test_id integer, test_stuff text)
   AS
$$
BEGIN
    RETURN QUERY SELECT id, test
        FROM testtable WHERE test LIKE param_subject;
END;
$$
  LANGUAGE 'plpgsql' VOLATILE;
  
-- variant 2 use this if you need to do something additional
-- or conditionally return values or more dynamic stuff
-- RETURN QUERY is generally more succinct and faster
CREATE OR REPLACE FUNCTION fn_plpgsqltestmulti(param_subject varchar) 
    RETURNS TABLE(test_id integer, test_stuff text)
   AS
$$
DECLARE 
    var_r record;
BEGIN
     FOR var_r IN(SELECT id, test 
                FROM test WHERE test LIKE param_subject)  LOOP
            test_id := var_r.id ; test_stuff := var_r.test;
            RETURN NEXT;
     END LOOP;
END;
$$
  LANGUAGE 'plpgsql' VOLATILE;
-- example use
-- This is legal in PostgreSQL 8.4+ 
-- (prior versions plpgsql could not be called this way)
SELECT (fn_plpgsqltestmulti('Cheese%')).test_stuff;


SELECT test_stuff FROM fn_plpgsqltestmulti('Cheese%');

CREATE OR REPLACE FUNCTION testspeed_table(it numeric(20))
 RETURNS TABLE(newit numeric(20), itprod numeric(20))
 AS
 $$
  SELECT j::numeric(20), $1*j::numeric(20) As itprod
    FROM generate_series(1,$1::bigint) As j;
 
 $$
 LANGUAGE 'sql' VOLATILE;
 
CREATE OR REPLACE FUNCTION testspeed_out(it numeric(20), 
  OUT newit numeric(20), OUT itprod numeric(20) )
 RETURNS setof record
 AS
 $$
  SELECT j::numeric(20), $1*j::numeric(20) As itprod
    FROM generate_series(1,$1::bigint) As j;
 
 $$
 LANGUAGE 'sql' VOLATILE;
-----------------------------------------------------

--Tip: date
select date::date,
       extract('year' from date) as year,
       extract('day' from
               (date + interval '2 month - 1 day')
              ) = 29
       as leap
  from generate_series(date '2000-01-01',
                       date '2010-01-01',
                       interval '1 year')
       as t(date);

https://www.periscopedata.com/blog/range-join-gives-you-accurate-histories
select generate_series(
  now() - interval '12 months',
  now(),
  '1 day'
) d

----
select d, count(charts.id)
from generate_series(
  current_date - interval '12 months',
  current_date,
  '1 day'
) d
left join charts on charts.created_at <= d
group by 1
----

select d, count(charts.id)
from generate_series(
  current_date - interval '12 months',
  current_date,
  '1 day'
) d
left join charts on charts.created_at <= d
where charts.deleted_at is null
group by 1
---
select d, count(charts.id)
from generate_series(
  current_date - interval '12 months', 
  current_date, 
  '1 day'
) d
left join charts on charts.created_at <= d and (
  charts.deleted_at is null or
  charts.deleted_at > d
)
group by 1


---------

--count the daily events for the last 10 days
select
  date(created_at) dt,
  count(1) ct
from events
group by 1 order by 1 desc
limit 10


--using lag
select
  date(created_at) dt,
  count(1) ct,
  lag(count(1), 1) over (order by dt) as ct_yesterday
from events
group by 1 order by 1 desc
limit 10

------
select 
  date_trunc('day', created_at),
  count(1)
from beta_signups
where created_at >= '2014-10-01' 
group by 1


-----------------   
--Tip: Index
SELECT i.relname as indname,
       i.relowner as indowner,
       idx.indrelid::regclass,
       am.amname as indam,
       idx.indkey,
       ARRAY(
       SELECT pg_get_indexdef(idx.indexrelid, k + 1, true)
       FROM generate_subscripts(idx.indkey, 1) as k
       ORDER BY k
       ) as indkey_names,
       idx.indexprs IS NOT NULL as indexprs,
       idx.indpred IS NOT NULL as indpred
FROM   pg_index as idx
JOIN   pg_class as i
ON     i.oid = idx.indexrelid
JOIN   pg_am as am
ON     i.relam = am.oid;
----

---Tip: Trigger

-- a table of users
CREATE TABLE users (
  username text NOT NULL PRIMARY KEY
);

-- an audit log
CREATE TABLE audit_log (
  at          timestamptz NOT NULL DEFAULT now(),
  description text NOT NULL
);

-- the actual function that is executed per insert
CREATE FUNCTION on_user_added() RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'INSERT') THEN
    -- add an entry into the audit log
    INSERT INTO audit_log (description)
        VALUES ('new user created, username is ' || NEW.username);
    -- send a notification
    PERFORM pg_notify('usercreated', NEW.username);
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- set the function as an insert trigger
CREATE TRIGGER on_user_added AFTER INSERT ON users
  FOR EACH ROW EXECUTE PROCEDURE on_user_added();

----------

--Tip: Logs
CREATE UNLOGGED TABLE upd (
   id  integer NOT NULL,
   val text    NOT NULL
) WITH (autovacuum_enabled = off);

CREATE UNLOGGED TABLE log (
   id       integer     NOT NULL,
   log_time timestamptz NOT NULL
            DEFAULT current_timestamp,
   new_val  text        NOT NULL
) WITH (autovacuum_enabled = off);

--logging with a rule
CREATE RULE upd_rule AS ON UPDATE TO upd
   DO ALSO INSERT INTO log (id, new_val)
           VALUES (NEW.id, NEW.val);

--logging with a statement level trigger

CREATE FUNCTION upd_stmt_trig() RETURNS trigger
   LANGUAGE plpgsql AS
$$BEGIN
   INSERT INTO log (id, new_val)
   SELECT id, val FROM newrows;

   RETURN NEW;
END;$$;

CREATE TRIGGER upd_row_trig AFTER UPDATE ON upd
   REFERENCING NEW TABLE AS newrows FOR EACH STATEMENT
   EXECUTE PROCEDURE upd_stmt_trig();

INSERT INTO upd (id, val)
   SELECT i, 'text number ' || i
   FROM generate_series(1, 10) i;

select * from upd;
select * from log;
----------------------------------------

--Tip: CTE

with individual_performance as (
  select 
    date('month', plan_start) m, 
    users.name salesperson,
    sum(purchase_price) revenue
  from payment_plans join users 
    on users.id = payment_plans.sales_owner_id
  group by 1, 2
)
select 
  m, 
  salesperson, 
  revenue 
from individual_performance

-- CTE 

--recursive
--snipps 1
with recursive incrementer(prev_val) as (
  select 1 -- anchor member
  union all
  select -- recursive member
    incrementer.prev_val + 1
  from incrementer
  where prev_val < 10 -- termination condition
)
select * from incrementer

--snipps 2
with recursive cruncher(inc, double, square) as (
  select 1, 2.0, 3.0 -- anchor member
  union all
  select -- recursive member
    cruncher.inc + 1,
    cruncher.double * 2,
    cruncher.square ^ 2
  from cruncher
  where inc < 10
)
select * from cruncher

--snipps 3
create table places as (
  select
    'Seattle' as name, 47.6097 as lat, 122.3331 as lon
    union all select 'San Francisco', 37.7833, 122.4167
    union all select 'Austin', 30.2500, 97.7500
    union all select 'New York', 40.7127, 74.0059
    union all select 'Boston', 42.3601, 71.0589
    union all select 'Chicago', 41.8369, 87.6847
    union all select 'Los Angeles', 34.0500, 118.2500
    union all select 'Denver', 39.7392, 104.9903
);
select * from places;

create or replace function lat_lon_distance( lat1 float, lon1 float, lat2 float, lon2 float) 
returns float as $$
declare
  x float = 69.1 * (lat2 - lat1);
  y float = 69.1 * (lon2 - lon1) * cos(lat1 / 57.3);
begin
  return sqrt(x * x + y * y);
end
$$ language plpgsql

select * from lat_lon_distance(47.6097,	122.3331,37.7833,	122.4167) -- Seattle to San Francisco

with recursive travel(places_chain, last_lat, last_lon, total_distance, num_places) as (
  select -- anchor member
    name, lat, lon, 0::float, 1
    from places
    where name = 'San Francisco'
  union all
  select -- recursive member
    -- add to the current places_chain
    travel.places_chain || ' -> ' || places.name,
    places.lat,
    places.lon,
    -- add to the current total_distance
    travel.total_distance + 
      lat_lon_distance(last_lat, last_lon, places.lat, places.lon),
    travel.num_places + 1
  from
    places, travel
  where
    position(places.name in travel.places_chain) = 0
)
select * from travel where num_places = 3

---------

with naughty_users as (
  select * from users where banned = 1
)
select * from naughty_users;

with deletions as (
  delete from users where expired is true
  returning *
)
insert into deleted_even_user_archive
select * from deletions where userid % 2 = 0;

---------------Doing this as a single query avoids the transaction issue completely. 

with userdata as (
  insert into users (name, email) values (?,?)
  returning userid
), addressdata as (
  insert into addresses (userid, address, city, state, zip)
  select userid,?,?,?,?
  from userdata
  returning addressid 
), historydata as (
  insert into user_history (userid, addressid, action)
  select userid, addressid,?
  from userdata, addressdata 
  returning historyid
)
select userid, addressid, historyid 
from userdata, addressdata, historydata;
---------------avoiding complicated transaction code,avoiding complicated error handling code.reduced query overhead,
--minimization of locks duration (because the transaction runs faster, see below)




WITH
monthly_revenue as (
    SELECT
    date_trunc(‘month’,datetime)::date as month,
    sum(amount) as revenue
    FROM orders
    GROUP BY 1
)
,prev_month_revenue as (
    SELECT *,
    lag(revenue) over (order by month) as prev_month_revenue
    FROM monthly_revenue
)
SELECT *,
round(100.0*(revenue-prev_month_revenue)/prev_month_revenue,1) as revenue_growth
FROM prev_month_revenue
ORDER BY 1

WITH
monthly_revenue as (
    SELECT
    date_trunc(‘month’,datetime)::date as month,
    state,
    sum(amount) as revenue
    FROM orders
    GROUP BY 1,2
)
,prev_month_revenue as (
    SELECT *,
    lag(revenue) over (partition by state order by month) as prev_month_revenue
    FROM monthly_revenue
)
SELECT *,
round(100.0*(revenue-prev_month_revenue)/prev_month_revenue,1) as revenue_growth
FROM prev_month_revenue
ORDER BY 2,1

WITH
monthly_revenue as (
    SELECT
    date_trunc(‘month’,datetime)::date as month,
    sum(amount) as revenue
    FROM orders
    GROUP BY 1
)
SELECT *,
sum(revenue) over (order by month rows between unbounded preceding and current row) as running_total
FROM monthly_revenue
ORDER BY 1
-------------
