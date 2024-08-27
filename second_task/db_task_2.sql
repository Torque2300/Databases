--2-1
with max_priorities as(
 select tasks.running_user, tasks.priority,
 		row_number() over (partition by tasks.running_user
                           		order by tasks.priority desc
                             ) as _desc
 from tasks
  )
select 
	max_priorities.running_user, 
	max_priorities.priority
from max_priorities
	where 
		_desc <= 3
	order by running_user;
--2-1


--2-2
select
 	distinct count(title), 
	extract (month from projects.data_begin) as month,
	extract(year from projects.data_begin) as year, 
	login 
from users
	join tasks on users.login = tasks.master_user 
	join projects on tasks.project_name = projects.project_name
group by projects.data_begin, login 
order by login;
--2-2


--2-3
select 
	running_user,
	(sum(evaluation - expenses) + sum(abs(evaluation - expenses)))/2 as "-", 
	(sum(expenses - evaluation) + sum(abs(expenses - evaluation)))/2 as "+" 
from  tasks
	where running_user is not null
	group by running_user
	order by running_user;
						
select * from tasks
where running_user is not null
order by running_user;

with spent_hours as(
select 
	running_user,
	(sum(evaluation - expenses) + sum(abs(evaluation - expenses)))/2 as "-", 
	(sum(expenses - evaluation) + sum(abs(expenses - evaluation)))/2 as "+"
from tasks
group by running_user
)
select running_user, 
	"-",
    "+"
from spent_hours
where running_user is not null
order by running_user;
--2-3


--2-4
select distinct on (master_user, running_user) master_user, running_user 
from tasks where running_user is not null and master_user is not null
order by master_user;

select distinct 
    case when master_user > running_user then master_user else running_user end as _m,
    case when master_user > running_user then running_user else master_user end as _r
from tasks
	where
		master_user is not null and
		running_user is not null
		order by _m;
--2-4


--2-5
select distinct login, length(login) 
from users 
where length(login) = (select max(length(login)) from users)
group by login;
--2-5


--2-6
-- create table testing(
-- 	_name char[50],
-- 	_surname varchar(50)
-- ) ;
-- ALTER TABLE testing
-- ALTER COLUMN _name SET DATA TYPE char(50);
-- insert into testing values ('Чокопай Константиныч', 'Чокопай Константиныч');
-- insert into testinf values ('Чокопай Константиныч', 'Чокопай Константиныч')
select pg_column_size(_name) as n, pg_column_size(_surname) as s from testing;
--2-6


--2-7
with _d as(
select
	running_user,
	max(priority) as mxp,
	min(priority) as mnp
from tasks
where running_user is not null
group by running_user
)
select 
	_d.running_user, 
	_d2.title as "Max_priority_task", 
	_d.mxp,
	_d3.title as "Min_priority_task",
	_d.mnp
from _d 
join tasks _d2 on
	_d.running_user = _d2.running_user and 
	_d.mxp = _d2.priority
join tasks _d3 on
	_d.running_user = _d3.running_user and
	_d.mnp = _d3.priority;
--2-7


--2-8
select running_user, sum(evaluation)
from tasks, (select avg(evaluation) from tasks) as mean
where tasks.evaluation >= mean.avg and running_user is not null
group by running_user;
--2-8


select * from tasks order by master_user;
--2.9.a
create view task_counter as
select running_user,
       count
	   (case
        	when expenses <= evaluation and status = 'Закрыта'
				then 1
                	else null
           end) as completed,
       count
	   (case
        	when expenses > evaluation
				then 1
                	else null
            end) as delayed
from tasks
where running_user is not null
group by running_user
order by running_user;

select *
from task_counter;
--2.9.a


--2.9.b
create view task_statistics as
select 
	running_user, 
	count(case 
		  	when status = 'Закрыта' 
		  		then 1 
		  	else 
		  		null 
		  	end) as Closed,
	count(case 
		  	when status = 'Переоткрыта' 
		  		then 1 
		  	else 
		  		null 
		  	end) as Opened,
	count(case 
		  when status = 'Выполняется' 
		  		then 1 
		  else 
		  		null
		  	end) as Executing
from tasks
	where running_user is not null
	group by running_user
	order by running_user;

select * from task_statistics;
--2.9.b


--2.9.c
create view wasted_time as 
select 
	running_user,
	sum(expenses) as time_gone,
	(sum(evaluation - expenses) + sum(abs(evaluation - expenses)))/2 as underwork,
	(sum(expenses - evaluation) + sum(abs(expenses - evaluation)))/2 as overwork
from tasks
	group by running_user
	order by running_user;

select * from wasted_time;
--2.9.c


--2.9.d
create view task_def as
select
	running_user,
	definition,
	tasks.title
from
	tasks
group by running_user, definition,tasks.title
order by running_user;

select * from task_def;
--2.9.d


--2.10

--usual query
select distinct 
	login 
from 
	users,
	tasks 
where 
	login = master_user;


select distinct 
	login 
from 
	users 
join 
	tasks on login = master_user
where
	master_user = (select master_user from tasks where expenses = 13 limit 1);

select distinct 
	login,
	title,
	tasks.definition
	from (select login from users where login not in ('Petrova')) as not_petrova
		join tasks on 
			login = master_user
	where title 
	in (select 
			title 
		 from 
			tasks 
		 join projects on 
			projects.project_name = tasks.project_name
		 where (data_begin between '2022-01-01' and '2023-01-01'));
--2-10
