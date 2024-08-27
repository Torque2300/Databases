--4-1
create table _A(
	user_id serial primary key,
	fio varchar(255) not null
);

create table _B(
	user_id serial primary key,
	fio varchar(255) not null
);

insert into _A(fio) values
('Batueva B.A'),
('Solodukhina E.R.'),
('Tsyrenov B.A'),
('Tumbochka E.Y');

select * from _A;
select * from _B;

select _A.fio 
	from _A 
	join _B 
	on _A.fio = _B.fio;

select _A.fio 
	from _A 
	left join _B 
	on _A.user_id = _B.user_id;
	
	
select _B.fio 
	from _A 
	right join _B 
	on _B.user_id = _A.user_id;

select _A.fio 
	from _A 
	left join _B 
	on _A.fio = _B.fio
	where _B.fio is null;
	
select _B.fio 
	from _B 
	left join _A 
	on _A.fio = _B.fio 
	where _A.fio is null;

select _A.fio, _B.fio 
	from _A 
	full outer join _B 
	on _A.user_id = _B.user_id
	
select _A.fio from _A 
union 
select _B.fio from _B;

select _A.fio, _B.fio 
	from _A 
	full outer join _B 
	on _A.fio = _B.fio 
	where ((_A.fio is null and _B.fio is not null) or (_A.fio is not null and _B.fio is null));

select *
from _A full outer join _B on _A.user_id = _B.user_id
where _A.user_id is null or _B.user_id is null;
--4-1

--4-2
select _out.id, _out.title, _out.master_user from tasks as _out
	where _out.priority = (select max(priority) from tasks as _int where _int.master_user = _out.master_user)
	order by id;

with _d as(
select
	master_user,
	id,
	max(priority) as mxp
from tasks
where master_user is not null
group by master_user, id
)
select 
	_d.id, 
	_d2.title as "Max_priority_task"
from _d 
join tasks _d2 on
	_d.master_user = _d2.master_user and 
	_d.mxp = _d2.priority
order by id;

select _out.id, _out.title
from tasks as _out 
	join tasks as _int 
on _out.master_user = _int.master_user
	group by _out.id, _int.master_user
	having max(_int.priority) = _out.priority;
--4-2

--4-3
with task_count as (
	select count(master_user) as task_num, master_user from tasks group by master_user
)
select task_num, master_user from task_count
where task_num in (1,2,3)
order by task_num;

with task_count as (
	select count(master_user) as task_num, master_user from tasks group by master_user
)
select task_num, master_user from task_count as t1
where exists 
(select task_num from task_count as t2 
 	where 
 	(t2.task_num = t1.task_num 
	 and (t2.task_num = 1 or t2.task_num = 2 or t2.task_num = 3)))
	 order by task_num;
	
with task_count as (
	select count(master_user) as task_num, master_user from tasks group by master_user
)
select t1.task_num, t1.master_user from task_count as t1 where t1.task_num = 1 or t1.task_num = 2
union
select t2.task_num, t2.master_user from task_count as t2 where t2.task_num = 3;

with task_count as (
	select count(master_user) as task_num, master_user from tasks group by master_user
)
select t1.task_num, t1.master_user from task_count as t1
join
task_count as t2
on t1.master_user = t2.master_user
where t1.task_num = 1 or t1.task_num = 2 or t2.task_num = 3;
--4-3


--4-4
insert into projects values('Туркменистан Постс', null, '11-05-2023', '11-08-2023');

select data_begin from projects where data_begin is not null
union
select data_end from projects where data_end is not null;
--4-4


--4-5
select p.project_name, t.title from tasks as t, projects as p order by t.title;

select p.project_name, t.title
from tasks as t
     cross join projects as p;
--4-5
