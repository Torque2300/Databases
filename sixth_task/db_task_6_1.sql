create table _A(
	login varchar(255) primary key,
	balance int not null default 0
)


insert into _A values
('Bair', 10000),
('Holya', 5000);
select * from _A;


--6-1
begin;

select balance from _A where login = 'Holya' for update;

update _A set balance = 100 where login = 'Bair';

begin;

select balance from _A where login = 'Bair' for update;

update _A set balance = 100 where login = 'Holya';

rollback;
--6-1


--6-2
--transaction
CREATE OR REPLACE PROCEDURE update_balance(_money integer, sender varchar, receiver varchar)
LANGUAGE plpgsql
AS $$
<<function_block>>
DECLARE
old_sender_balance int;
new_sender_balance int;
old_receiver_balance int;
new_receiver_balance int;
BEGIN
	savepoint redo;
	IF (_money < 0 OR NOT EXISTS(SELECT 1 FROM _A WHERE login=sender) OR NOT EXISTS(SELECT 1 FROM _A WHERE login=receiver)) THEN
		EXIT function_block;
	END IF;
	
	begin
	old_sender_balance := (SELECT balance FROM _A WHERE login = sender);
	new_sender_balance := (old_sender_balance - _money);
	IF (new_sender_balance < 0) THEN
		EXIT function_block;
	END IF;
	
	UPDATE _A
	SET balance = new_sender_balance
	WHERE login = sender;
	if (new_sender_balance <> (old_sender_balance - _money)) THEN
		raise exception 'balance';
	end if;
	exception
	when raise_exception then
		exit function_block;
	end;
	
	begin
	old_receiver_balance := (SELECT balance FROM _A WHERE login = receiver);
	new_receiver_balance := old_receiver_balance + _money;
	UPDATE _A
	SET balance = new_receiver_balance
	WHERE login = receiver;
	if (new_receiver_balance <> (old_receiver_balance + _money)) THEN
		raise exception 'balance';
	end if;
	exception
	when raise_exception then
		exit function_block;
	end;
	COMMIT;
END;$$
SELECT * FROM _A;
CALL update_balance(1000, 'Bair', 'Holya');
UPDATE _A SET balance = 1000 WHERE login = 'Bair';
--transaction


--cycle
drop trigger if exists take_ruble on _A;
drop function if exists take();

CREATE OR REPLACE FUNCTION take() RETURNS TRIGGER AS
$$
    BEGIN
		new.balance = 100;
		return new;
    END;
$$
LANGUAGE 'plpgsql';

CREATE OR REPLACE TRIGGER take_ruble
BEFORE INSERT OR UPDATE ON _A 
	FOR EACH ROW EXECUTE FUNCTION take();
	
select * from _a;

insert into _A values('Bair', 1000),('a', 200), ('b', 400);
UPDATE _A SET balance = 1000 WHERE balance = 100;

select * from _a;
--cycle


--recursive
create table _recursive(
	num int
)
create or replace procedure recursive_insert(_num integer)
language plpgsql
as 
$$
<<function_block>>
begin
	if (_num > 100) then
		exit function_block;
	end if;
	insert into _recursive values(_num);
	call recursive_insert(_num+10);
end;
$$
select * from _recursive;
call recursive_insert(0);
delete from _recursive;
--recursive	
--6-2


--6-3
create table created_tasks(
	task_id int primary key,
	task_date date
);


insert into created_tasks values
(0, '2022-11-01'),
(1, '2022-11-01'),
(2, '2022-11-01'),
(3, '2022-11-02'),
(4, '2022-11-02'),
(5, '2022-11-03');
select * from created_tasks;


create or replace function find_date(_begin date, _end date)
returns table(_date date)
language plpgsql
as 
$$
declare
_date date;
_id int;
begin
	drop table if exists _dates;
	create temporary table _dates(
	_task_date date
	);
	select task_date, task_id into _date, _id from created_tasks where task_date = _begin limit 1;
	insert into _dates values(_date);
	while _date != _end loop
		_id := _id + 1;
		select task_date into _date from created_tasks where task_id = _id limit 1;
		insert into _dates values(_date);
	end loop;
	return query select * from _dates;
end;
$$


select * from find_date('2022-11-01', '2022-11-02');
--6-3


--6-4
create table file_structure(
	file_type varchar(255) not null,
	child_name varchar(255) not null,
	parent_name varchar(255) not null default '\',
	constraint file_type_check check 
	(file_type = 'File' or file_type = 'Directory'),
	primary key(child_name, parent_name)
)


insert into file_structure values
('Directory', '\', '..'),
('Directory', 'Qt_tasks', '\'),
('Directory', 'Earth', 'Qt_tasks'),
('File', 'Earth.cpp', 'Earth'),
('File', 'Earth.h', 'Earth'),
('Directory', 'DB', '\'),
('Directory', '6_task', 'DB'),
('File', '6.sql', '6_task'),
('Directory', 'Signal_Processing', '\'),
('File', 'lab6.ipynb', 'Signal_Processing');
select * from file_structure;
delete from file_structure;


--вставить файл
create or replace procedure insert_file(folder_name varchar, file_name varchar, _type varchar)
language plpgsql
as 
$$
<<function_block>>
declare
res int;
begin
	res := (select count(1) from file_structure where parent_name = folder_name);
	if (folder_name = '\') then
		res := 1;
	end if;
	if (res = 1 and (_type = 'Directory' or _type = 'File')) then		
		insert into file_structure values(_type, file_name, folder_name);		
	end if;
end;
$$
call insert_file('\', 'Koko', 'File')
select * from file_structure;


--удалить узел
create or replace procedure delete_file(folder_name varchar, file_name varchar, _type varchar)
language plpgsql
as 
$$
declare
_child_name varchar(255);
_parent_name varchar(255);
_iter varchar;
begin
	_iter := (select file_type from file_structure where child_name = file_name and file_type = _type);
	if (_type = 'File' or _type = 'Directory') then
		delete from file_structure where parent_name = folder_name
		and child_name = file_name
		and file_type = _type;
	end if;
	if (_type = 'Directory') then
		_parent_name := file_name; --'Dar'
		while _iter != 'File' loop
			_child_name := (select child_name from file_structure where parent_name = _parent_name);
			delete from file_structure where parent_name = _parent_name			
			and file_type = _iter; --'delete'						
			_parent_name := _child_name;
			_iter := (select file_type from file_structure where parent_name = _parent_name);
		end loop;
		delete from file_structure where parent_name = _parent_name			
		and file_type = 'File';
	end if;
end;
$$


select * from file_structure;
insert into file_structure values('Directory', 'Dar', '\');
insert into file_structure values('Directory', 'Ima', 'Dar');
insert into file_structure values('Directory', 'Bat', 'Ima');
insert into file_structure values('File', 'Ueva', 'Bat');
call delete_file('\', 'Dar', 'Directory');
select * from file_structure;
delete from file_structure;

--перемещение номенклатуры или папки
create or replace procedure replace_file(folder_name varchar, file_name varchar, replace_folder_name varchar, _type varchar)
language plpgsql
as 
$$
<<function_block>>
begin
	if ((select count(1) from file_structure where parent_name = folder_name) >= 1 and
		(select count(1) from file_structure where parent_name = replace_folder_name) >= 1
		and (_type = 'Directory' or _type = 'File')) then		
		update file_structure set parent_name = replace_folder_name 
			where child_name = file_name
			and parent_name = folder_name
			and file_type = _type;		
	end if;
end;
$$


select * from file_structure;
insert into file_structure values('Directory', 'Anna', '\');
call replace_file('\', 'Anna', 'Earth', 'Directory');
select * from file_structure;


--путь до корня
create or replace function find_root(file_name varchar)
returns text
language plpgsql
as 
$$
<<function_block>>
declare
_result text;
_iter text;
begin
	select parent_name, child_name into _iter, _result from file_structure where child_name = file_name;
	-- result - 6.sql    _iter - 6_task
	while _iter != '..' loop
		if (_iter = '\') then
			_result := _iter || _result;
		end if;
		if (_iter != '\') then
			_result := _iter || '\' || _result;
		end if;
-- 		_iter := (select child_name from file_structure where parent_name = _iter);
		_iter := (select parent_name from file_structure where child_name = _iter);
	end loop;
	_result := '..' || _result;
	return _result;
end;
$$


select * from file_structure;
select child_name from file_structure where child_name = '6.sql';
select * from find_root('6.sql');
--6-4


--6-5
drop trigger if exists logger_trigger on tasks;
drop function if exists logger_function();


create table log_table(
	operation char(6),
	operation_time timestamp,
	task_title text,
	task_priority int,
	task_definition text,
	task_status text,
	task_evaluation real,
	task_expenses real,
	task_master_user varchar(50),
	task_running_user varchar(50),
	task_project_name varchar(50),
	task_id int
)


create or replace function logger_function() 
returns trigger
language plpgsql
as
$$
<<function_block>>
declare
operation char(6);
task_title text;
begin
	if TG_OP = 'INSERT' then
		operation := 'insert';
		insert into log_table values
		(operation, now(), new.title, new.priority, new.definition, new.status, new.evaluation,
		 new.expenses, new.master_user, new.running_user, new.project_name, new.id);
	end if;
	if TG_OP = 'UPDATE' then
		operation := 'update';
		insert into log_table values
		(operation, now(), new.title, new.priority, new.definition, new.status, new.evaluation,
		 new.expenses, new.master_user, new.running_user, new.project_name, new.id);
	end if;
	if TG_OP = 'DELETE' then
		operation := 'delete';
		insert into log_table values
		(operation, now(), old.title, old.priority, old.definition, old.status, old.evaluation,
		 old.expenses, old.master_user, old.running_user, old.project_name, old.id);
	end if;
	return new;
end;
$$


CREATE OR REPLACE TRIGGER logger_trigger
AFTER INSERT OR UPDATE OR DELETE ON tasks
FOR EACH ROW EXECUTE FUNCTION logger_function();


select * from log_table;
select * from tasks;

insert into tasks values('first task', 10, null, 'Новая', 12, 6, 'Drozdov', 'Kasatkin', 'МВД-Онлайн', 1);
select * from log_table;

update tasks set master_user = 'Makenroi' where running_user = 'Kasatkin';
select * from log_table;

delete from tasks where master_user = 'Makenroi';
select * from log_table;


delete from tasks;
delete from log_table;


--6-5-a
delete from tasks;
delete from log_table;

select * from tasks;
select * from log_table;

insert into tasks values('first task', 10, null, 'Новая', 12, 6, 'Drozdov', 'Kasatkin', 'МВД-Онлайн', 1);
update tasks set master_user = 'Kasatkin' where running_user = 'Kasatkin';


create or replace function task_change_history(title text)
returns table
(   _operation char(6),
	_operation_time timestamp,
	_task_title text,
	_task_priority int,
	_task_definition text,
	_task_status text,
	_task_evaluation real,
	_task_expenses real,
	_task_master_user varchar(50),
	_task_running_user varchar(50),
	_task_project_name varchar(50),
	_task_id int)
language plpgsql
as 
$$
<<function_block>>
begin
	return query
	select * from log_table where task_title = title;
end;
$$


select * from task_change_history('first task');
--6-5-a


--6-5-b
delete from tasks;
delete from log_table;

select * from tasks;
select * from log_table;


create or replace procedure task_rollback_changes(_title text)
language plpgsql
as 
$$
begin
	if ((select operation from log_table 
		 where operation_time
		 = 
		 	(select max(operation_time) from log_table 
			 where operation_time not in (select max(operation_time) from log_table)))
		 = 'delete') then
			with cte_max_time as (
			select * from log_table
			where operation_time = (select max(operation_time) from log_table) and task_title = _title)
			insert into tasks
				select cte_max_time.task_title,
				cte_max_time.task_priority,
				cte_max_time.task_definition,
				cte_max_time.task_status,
				cte_max_time.task_evaluation,
				cte_max_time.task_expenses,
				cte_max_time.task_master_user,
				cte_max_time.task_running_user,
				cte_max_time.task_project_name,
				cte_max_time.task_id 
			from cte_max_time;
	 else
			with cte_max_time as (
			select * from log_table 
			where operation_time = 
			(select max(operation_time) from log_table where operation_time not in (select max(operation_time) from log_table)))
			update tasks set
				title = cte_max_time.task_title,
				priority = cte_max_time.task_priority,
				definition = cte_max_time.task_definition,
				status = cte_max_time.task_status,
				evaluation = cte_max_time.task_evaluation,
				expenses = cte_max_time.task_expenses,
				master_user = cte_max_time.task_master_user,
				running_user = cte_max_time.task_running_user,
				project_name = cte_max_time.task_project_name,
				id = cte_max_time.task_id
				from cte_max_time
			where _title = cte_max_time.task_title;
	 end if;
end;
$$


insert into tasks values('first task', 10, null, 'Новая', 12, 6, 'Drozdov', 'Kasatkin', 'МВД-Онлайн', 1);
update tasks set master_user = 'Kasatkin' where running_user = 'Kasatkin';
select * from tasks;
update tasks set master_user = 'Petrova' where running_user = 'Kasatkin';
select * from tasks;
call task_rollback_changes('first task')
select * from tasks;
--6-5-b


--6-5-c
--удаление задач
delete from tasks;
delete from log_table

select * from tasks;
select * from log_table;

insert into tasks values('first task', 10, null, 'Новая', 12, 6, 'Drozdov', 'Kasatkin', 'МВД-Онлайн', 1);


create or replace procedure task_delete_task(_title text)
language plpgsql
as 
$$
begin
	delete from tasks where title = _title;
end;
$$


select * from tasks;
call task_delete_task('first task')
select * from tasks;


--просмотр истории удаленных задач
delete from tasks;
delete from log_table

select * from tasks;
select * from log_table;

insert into tasks values('first task', 10, null, 'Новая', 12, 6, 'Drozdov', 'Kasatkin', 'МВД-Онлайн', 1);
insert into tasks values('second task', 9, null, 'Новая', 15, 7, 'Makenroi', 'Petrova', 'МВД-Онлайн', 2);
delete from tasks;


create or replace function task_operation_history(task_operation text)
returns table
(   _operation char(6),
	_operation_time timestamp,
	_task_title text,
	_task_priority int,
	_task_definition text,
	_task_status text,
	_task_evaluation real,
	_task_expenses real,
	_task_master_user varchar(50),
	_task_running_user varchar(50),
	_task_project_name varchar(50),
	_task_id int)
language plpgsql
as 
$$
<<function_block>>
begin
	return query
	select * from log_table where operation = task_operation;
end;
$$


select * from task_operation_history('delete');


--восстановление всех удаленных задач
create or replace procedure delete_rollback_changes()
language plpgsql
as 
$$
<<function_block>>
declare
count_of_rows int;
delete_cursor cursor for
select distinct 
task_title,
task_priority,
task_definition,
task_status,
task_evaluation,
task_expenses,
task_master_user,
task_running_user,
task_project_name,
task_id
from log_table
where operation = 'delete'
and operation_time = (select max(operation_time) from log_table);
_task_title text;
_task_priority int;
_task_definition text;
_task_status text;
_task_evaluation real;
_task_expenses real;
_task_master_user varchar(50);
_task_running_user varchar(50);
_task_project_name varchar(50);
_task_id int;
begin
	count_of_rows := (select count(*) from log_table where operation = 'delete');
	open delete_cursor;
	loop
    	fetch delete_cursor into 
		_task_title,
		_task_priority,
		_task_definition,
		_task_status,
		_task_evaluation,
		_task_expenses,
		_task_master_user,
		_task_running_user,
		_task_project_name,
		_task_id;
      	exit when not found;
		insert into tasks values(_task_title,
		_task_priority,
		_task_definition,
		_task_status,
		_task_evaluation,
		_task_expenses,
		_task_master_user,
		_task_running_user,
		_task_project_name,
		_task_id);
   	end loop;		
end;
$$


insert into tasks values('first task', 10, null, 'Новая', 12, 6, 'Drozdov', 'Kasatkin', 'МВД-Онлайн', 1);
insert into tasks values('second task', 9, null, 'Новая', 15, 7, 'Makenroi', 'Petrova', 'МВД-Онлайн', 2);
insert into tasks values('second task', 8, null, 'Закрыта', 17, 76, 'Berkut', 'Petrova', 'Поддержка', 3);


delete from tasks;
delete from log_table;

select * from tasks;
select * from log_table;


call delete_rollback_changes();
--6-5-c
--6-5