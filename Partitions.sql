/**
Partitioning:

Partitioned table is a table that in logical memory is subdivided into smaller pieces called partitions,
where each partition has it's own segment.
Partitioning is done with a partitioning key - which consists of a column or columns which determine
the partition into which a row record will be stored. 

3 Types of Partitioning:
-List
-Range
-Intervals

Let's look at list partitions first:
**/

/* List partitions */
SELECT tablespace_name, bytes/1024/1024 USED_MB, max_bytes/1024/1024 MAX_MB
FROM user_ts_quotas;

CREATE TABLE p_try (
  id number,
  name varchar2(30),
  salary number,
  dept_id number
)
PARTITION BY LIST(dept_id)
(
 PARTITION p1 values (20,21,25),
 --PARTITION p1 VALUES (23,24,25), NOPE! has to be uniquely named
 PARTITION p2 VALUES(23,24,28),
 PARTITION unknown VALUES (DEFAULT)
);

INSERT INTO p_try
VALUES (1, 'Shari Tucker', 5000, 21 );

SELECT tablespace_name, bytes/1024/1024 USED_MB, max_bytes/1024/1024 MAX_MB
FROM user_ts_quotas;

INSERT INTO p_try
VALUES (2, 'Mavis Banks', 6000, 20 );


INSERT INTO p_try
VALUES (3, 'Tony Mendez', 20000, 25);


DROP TABLE p_try;
--this alone will not recover the extents allocated to the partitioned table
--you need to purge the table , i.e. remove from the DB recycle bin

PURGE TABLE p_try;


/* Range Partition */

--this where rows are assigned to partitions based ona ange of values

SELECT tablespace_name, bytes/1024/1024 USED_MB, max_bytes/1024/1024 MAX_MB
FROM user_ts_quotas;

CREATE TABLE p_try2 (
  id number,
  name varchar2(30),
  hired date,
  dept_id number
)
PARTITION BY RANGE (hired)
(
PARTITION p1 values less than (to_date('2019-12-15', 'YYYY-MM-DD'))
SEGMENT CREATION IMMEDIATE,
PARTITION p2 VALUES less than (to_date('2020-12-15', 'YYYY-MM-DD'))
SEGMENT CREATION IMMEDIATE 
);

SELECT tablespace_name, bytes/1024/1024 USED_MB, max_bytes/1024/1024 MAX_MB
FROM user_ts_quotas;

--16mb of space, with segment creation X 2

INSERT INTO p_try2 VALUES 
(1, 'Shaun Mori', '2020-11-13', 25);

select tablespace_name, bytes/1024/1024 USED_MB, max_bytes/1024/1024 MAX_MB
from user_ts_quotas;
--did not increase the space needed, still at 37mb

INSERT INTO p_try2 VALUES 
(2, 'Sharon Jones', '2019-11-02', 28);

select tablespace_name, bytes/1024/1024 USED_MB, max_bytes/1024/1024 MAX_MB
from user_ts_quotas;
--did not increase space, still at 37mb.


---let's run a little experiment, drop the table and purge, then recreate without segment creation immediate.


DROP TABLE p_try2;
PURGE TABLE p_try2;


select tablespace_name, bytes/1024/1024 USED_MB, max_bytes/1024/1024 MAX_MB
from user_ts_quotas;


CREATE TABLE p_try2 (
id number,
name varchar2(30),
hired date,
dept_id number
)
PARTITION BY RANGE (hired)
(PARTITION p1 values less than (to_date('2019-12-15', 'YYYY-MM-DD')),
PARTITION p2 VALUES less than (to_date('2020-12-15', 'YYYY-MM-DD'))
 );
 

INSERT INTO p_try2 VALUES 
(2, 'Sharon Jones', '2019-11-02', 28);

DROP TABLE p_try2;
purge table p_try2;

SELECT tablespace_name, bytes/1024/1024 USED_MB, max_bytes/1024/1024 MAX_MB
FROM user_ts_quotas;



-----------------
