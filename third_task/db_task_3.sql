--3-1
create table a(
	_id serial primary key,
	_title varchar(255)
);


create table b(
	_id serial primary key,
	_title varchar(255),
	constraint aid foreign key(_id) references a(_id) on delete cascade 
);


alter table a
rename column _title to _data;


alter table b
rename column _title to _data;


insert into a(_id, _data) values(1, 'Death Grips Culture Shock');
insert into a(_id, _data) values(2, 'Chernikovskaya Hata Ti Ne veri slezam' );

insert into b(_id, _data) values(1, 'The Rolling Stones Paint it Black');

alter table b
alter column _data set not null; 

alter table a
alter column _data set not null;

alter table b
add unique (_data);

alter table a
add unique (_data);

--error--
update a
set _data = 'Husky'
where _id = 2;

update a
set _data = null
where _id = 1;

insert into a(_id, _data) values(3, null);
insert into a(_id, _data) values(null, 'Poema o Rodine');
insert into a(_id, _data) values(3, 'Panelka');
insert into b(_id, _data) values(3, 'Pinback Tripoli');
--error--

delete from b
where _id = 1;
insert into b(_id, _data) values(1, 'Pinback Crutch');

--error--
drop table a;
--error--

select * from a;
select * from b;

delete from a
where _id = 1;

select * from a;
select * from b;
--3-1


--3-2
create function CheckPostFunction(_post varchar)
	returns bit
	language plpgsql
	as
	$$	
	begin
    	return (
			with data as(
				select _post, convert(bit, case when _post = 'student' or _post = 'rector' then 1 else 0 end) as verify from _person)
			select verify from data 
		);
	end;
	$$;

create table university(
	university_name varchar(255) not null primary key
);

create table town_location(
	university_name varchar(255) not null primary key,
	town_name varchar(255) not null
);

create table course(
	course_id serial primary key,
	university varchar(255) not null,
	course_name varchar(255) not null,
	professor varchar(255) not null,
	constraint uc foreign key(university) references university(university_name)
);

create table post(
	post_id serial primary key,
	_post varchar(255) not null,
	constraint post_check check (_post = 'student' or _post = 'professor' or _post = 'serving staff')
);

create table users(
	user_id serial primary key,
	login varchar(255) not null unique,
	fio varchar(255) not null,
	university varchar(255) not null,
	constraint pc foreign key(user_id) references post(post_id),
	constraint uc foreign key(university) references university(university_name)
);

create table employee(
	user_id serial not null,
	post_id serial not null,
	constraint uc foreign key(user_id) references users(user_id),
	constraint pc foreign key(post_id) references post(post_id),
	primary  key(user_id, post_id)
);

create table rector(
	rector_id serial primary key,
	rector varchar(255) not null,
	university_id serial not null,
	university varchar(255) not null,
	constraint university_check foreign key(university) references university(university_name)
);

insert into university(university_name) values
('Novosibirsk State University'),
('Moscow State University'),
('Saint-Petersburg State University'),
('Novosibirsk State Technical University');

insert into town_location(university_name, town_name) values
('Novosibirsk State University', 'Novosibirsk'),
('Moscow State University', 'Moscow'),
('Saint-Petersburg State University', 'Saint-Petersburg'),
('Novosibirsk State Technical University', 'Novosibirsk');

insert into course(university, course_name, professor) values
('Novosibirsk State University', 'ORBD', 'Pirogov S.A'),
('Moscow State University', 'Mathematical Analysis', 'Batuev D.T');

insert into users(user_id, login, fio, university) values
(1, 'Tsyrenov', 'Tsyrenov B.A', 'Novosibirsk State University'),
(2, 'Batuev', 'Batuev D.T', 'Moscow State University'),
(3, 'R.', 'Anastasiya', 'Saint-Petersburg State University'),
(4, 'Pirogov', 'Pirogov S.A', 'Novosibirsk State University'),
(5, 'Romanov', 'Romanov W.A', 'Novosibirsk State University');

insert into post(_post) values
('student'),
('professor'),
('serving staff');

insert into employee(user_id, post_id) values
(1,1),
(2,2),
(3,2),
(4,1),
(5,1);
--3-2


--3-3
--select anomaly--
create table place_of_living(
	user_id serial primary key,
	fio varchar(255) not null,
	address varchar(255) not null unique
);

insert into place_of_living(fio,address) values 
('Zubenko Michail Petrovich', 'Russian Federation, Republic of Dagestan, Mahachkala, DDT str., 454, 12'),
('Poligraph Polugraphovich Sharickov', 'Russia, Moscow obl., Moscow, Splin str. 545,1971'),
('Bairovich B.B', 'Rossiya, Republic of Buryatia, Ulan-Ude, Str. KINO h. 1990');

select 
	split_part(fio, ' ', 1) as surname, 
	split_part(fio, ' ', 2) as name, 
	split_part(fio, ' ', 3) as patronymic,
	split_part(address, ',', 1) as country,
	split_part(address, ',', 2) as region,
	split_part(address, ',', 3) as town,
	split_part(address, ',', 4) as street,
	split_part(address, ',', 5) as house,
	split_part(address, ',', 6) as apartment
from place_of_living;
--select anomaly--

--insertion anomaly
create table example(
	emp_id int,
	salary int, 
	project_name varchar(50),
	primary key(emp_id, project_name)
)

insert into example(emp_id, salary, project_name) values
(1,300,'Cooking'),
(3,400, 'Teaching');

insert into example(emp_id, salary, project_name) values(2, 400, null);
--insertion anomaly

--deletion anomaly
--update anomaly
create table university_list(
	university varchar(255) primary key
);

create table manage_system(
	student_id serial primary key,
	student varchar(255) not null,
	record_book int not null unique,
	university varchar(255) not null,
	constraint uc foreign key(university) references university_list(university) on delete cascade
);

insert into university_list(university) values
('NSU'),
('MSU');

insert into manage_system(student_id, student, record_book, university) values
(1, 'Alex', 434, 'NSU'),
(2, 'Dima', 435, 'MSU');

delete from university_list where university = 'NSU';
select * from university_list;
select * from manage_system;

create table student(
	student_name VARCHAR(10),
	record_book int primary key
);

create table marks(
	record_book int not null,
	subject varchar(50) not null,
	constraint rc foreign key(record_book) references student(record_book)
)

insert into student values
('Lexa', 34),
('Bibi', 43),
('Vi', 32);
insert into student values
('Vi', 32);

insert into marks values
(34,'math'),
(43,'alg');

insert into marks values
(32, 'pe');



delete from student where record_book = 32;
update student set record_book = 432 where record_book = 32;
select * from student;
select * from marks;
--deletion anomaly
--update anomaly
--3-3


--3-4
--1nf
create table _user(
	fio varchar(255) primary key,	
	work_info varchar(255) not null,
	user_unfo varchar(255) not null,
	course varchar(255),
	literature varchar(255),
	auditorium int
);

create table user_1nf(
	fio varchar(255) primary key,
	post varchar(255) not null,
	university varchar(255) not null,
	sex varchar(255) not null,
	work_duties varchar(255) not null,
	hobby varchar(255),
	course varchar(255),
	literature varchar(255),
	auditorium int
);
--1nf

--2nf
create table user_2nf(
	fio varchar(255) primary key,
	post varchar(255) not null,
	sex varchar(255) not null,
	work_duties varchar(255) not null,
	course_id serial not null,
	hobby varchar(255),	
	constraint cc foreign key(course_id) references course_2nf(course_id)
);

create table course_2nf(
	course_id serial primary key,
	course varchar(255) not null,
	university varchar(255) not null,
	literature varchar(255),
	auditorium int
);
--2nf

--3nf
create table user_3nf(
	fio varchar(255) primary key,
	post varchar(255) not null,
	sex varchar(255) not null,
	course_id serial not null,
	hobby varchar(255),	
	constraint cc foreign key(course_id) references course_3nf(course_id),
	constraint pc foreign key(post) references post_3nf(post)
)

create table post_3nf(
	post varchar(255) primary key,
	work_duties varchar(255) not null
)

create table course_3nf(
	course_id serial primary key,
	course varchar(255) not null,
	university varchar(255) not null,
	literature varchar(255),
	auditorium int
);
--3nf

--4nf
create table user_4nf(
	fio varchar(255) primary key,
	sex varchar(255) not null,
	post varchar(255) not null,
	course_id serial not null,
	constraint cc foreign key(course_id) references course_4nf(course_id),
	constraint pc foreign key(post) references post_4nf(post)
)

create table user_hobby_4nf(
	fio varchar(255) not null,
	sex varchar(255) not null,
	hobby varchar(255)
)

create table post_4nf(
	post varchar(255) primary key,
	work_duties varchar(255) not null
)

create table course_4nf(
	course_id serial primary key,
	course varchar(255) not null,
	university varchar(255) not null,
	literature varchar(255),
	auditorium int
);
--4nf
--3-4
