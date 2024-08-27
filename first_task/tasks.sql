-- ALTER TABLE users
-- ADD CONSTRAINT unique_login UNIQUE(login);
-- ALTER TABLE tasks
-- ADD FOREIGN KEY (customer_id) REFERENCES customers (id);
-- INSERT INTO tasks(title, priority, definition, status, evaluation, expenses, master_user, running_user, project_name) 
-- VALUES ('t1', 1, 'Bair', 'Новая', 20, 13, 'Belova', null, 'Демо-Сибирь'),
-- ('t2', 2, 'Lampo4ka', 'Закрыта', 40, 40, 'Belova', null, 'Демо-Сибирь'),
-- ('t3', 3, 'Blini', 'Закрыта', 15, 15, 'Kasatkin', null, 'МВД-Онлайн'),
-- ('t4', 4, 'Oladia', 'Переоткрыта', 5, 1, 'Berkut', 'Drozdov', 'МВД-Онлайн'),
-- ('t5', 5, 'Buuzi', 'Закрыта', 13, 13, 'Petrova', null, 'МВД-Онлайн'),
-- ('t6', 6, 'Russia', 'Новая', 5, 4, 'Berkut', 'Berkut', 'Поддержка'),
-- ('t7', 7, 'Baikal', 'Выполняется', 1, 0, 'Drozdov', 'Belova', 'Поддержка'),
-- ('t8', 8, 'Armyanin', 'Выполняется', 10, 0, 'Makenroi', 'Kasatkin', 'Поддержка'),
-- ('t9', 9, 'Kosmos', 'Закрыта', 16, 16, 'Kasatkin', null, 'РТК'),
-- ('t10', 10, 'Choco-Pie', 'Выполняется', 9, 13, 'Petrova', 'Berkut', 'РТК');
-- -- 3a) Вывести все данные о задачах
-- SELECT * FROM tasks; -- or SELECT title, priority, ... from tasks

-- -- 3b) Вывести все пары сотрудник-отдел, в котором он работает
-- SELECT user_name, department FROM users;

-- -- 3c) Вывести все логины и email пользователей
-- SELECT login,email FROM users;

-- -- 3d) вывести все задачи, у которых приоритет больше 5;
-- SELECT * FROM tasks WHERE priority > 5;

-- 3e) вывести всех пользователей, на которых имеются назначенные задачи
-- SELECT DISTINCT user_name FROM users INNER JOIN tasks ON users.login = tasks.running_user; 

-- -- 3f) вывести все идентификаторы пользователей из таблицы задачи без повторений
-- SELECT master_user FROM tasks WHERE master_user IS NOT NULL UNION 
-- SELECT running_user FROM tasks WHERE running_user IS NOT NULL;

-- 3k) вывести все задачи, которые заведены не Петровым и при этом назначены на Макенроя, Касаткина и Беркута.
-- SELECT * FROM tasks WHERE master_user != 'Petrova' and (running_user = 'Berkut' or running_user = 'Kasatkin'
-- or running_user = 'Makenroi');
-- SELECT * FROM tasks WHERE master_user != 'Petrova' and running_user in ('Berkut', 'Kasatkin', 'Makenroi')

-- 1-4) Напишите запрос, который выведет все задачи, созданные 	на Касаткина 7-го июня 2022, 1-го, 3-го Января 2016 года
-- SELECT tasks.title, tasks.priority, tasks.definition, tasks.status, tasks.evaluation, tasks.expenses,
-- tasks.master_user, tasks.running_user, tasks.project_name
-- FROM tasks INNER JOIN projects ON tasks.project_name = projects.project_name 
-- WHERE running_user = 'Kasatkin' and data_begin in ('2022-06-07', '2016-01-01', '2016-03-01');

-- 1-5)Напишите запрос, который выведет все задачи, назначенные на Петрова, инициированные из отделов 
-- Администрация, Бухгалтерия и Производство.
-- SELECT tasks.* from tasks INNER JOIN users ON master_user = login WHERE department IN
-- ('Администрация', 'Бухгалтерия', 'Производство') and running_user = 'Petrova' 

-- 1-6) Как с помощью NULL можно обыграть следующую ситуацию:
-- a)задача создана, но не назначена на исполнение;
-- b)у каждой созданной задачи должен быть автор(пользователь, кто завел задачу).

-- 1-6-1)заведите несколько задач без исполнителя - DONE;
-- 1-6-2)выведите все задачи без исполнителя;
-- SELECT * from tasks WHERE running_user IS NULL;
-- UPDATE tasks
-- SET running_user = 'Petrova'
-- WHERE title in ('t2');

-- 1-7) Напишите запрос, который дублирует таблицу Задачи в таблицу Задачи2. Как можно сохранить нумерацию индексов?
-- CREATE TABLE tasks_2 AS
--  SELECT * FROM tasks;

-- 1-8) Напишите запрос к таблице Пользователь, который выводит результат удовлетворяющий следующим требованиям:
-- a) имя и фамилия исполнителя не заканчиваются буквой а
-- б) login начинается с буквы П и содержит р
-- SELECT user_name FROM users WHERE user_name NOT LIKE '%а';
-- SELECT user_name FROM users WHERE user_name LIKE 'П%р%';






