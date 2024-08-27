INSERT INTO users(User_Name, Login, Email, Department) VALUES ('Касаткин Артем', 'Kasatkin','Kasatkin2002@gmail.com','Администрация') ON CONFLICT DO NOTHING;
INSERT INTO users(User_Name, Login, Email, Department) VALUES('Петрова София', 'Petrova','Pertrova1955@gmail.com','Бухгалтерия') ON CONFLICT DO NOTHING;
INSERT INTO users(User_Name, Login, Email, Department) VALUES('Дроздов Федр', 'Drozdov','Drozdov2002@gmail.com','Администрация') ON CONFLICT DO NOTHING;
INSERT INTO users(User_Name, Login, Email, Department) VALUES('Беркут Алексей', 'Berkut','Berkut1994@gmail.com','Поддержка пользователей') ON CONFLICT DO NOTHING;
INSERT INTO users(User_Name, Login, Email, Department) VALUES('Белова Вера', 'Belova','Belova1999@gmail.com','Производство') ON CONFLICT DO NOTHING;
INSERT INTO users(User_Name, Login, Email, Department) VALUES('Макенрой Алексей', 'Makenroi','Makenroi2005@gmail.com','Производство') ON CONFLICT DO NOTHING;

INSERT INTO projects(project_name, definition, data_begin, data_end) VALUES('РТК', null, '31-01-2022', null) ON CONFLICT DO NOTHING;
INSERT INTO projects(project_name, definition, data_begin, data_end) VALUES('СС-Коннект', null, '23-02-2022', '24-11-2023') ON CONFLICT DO NOTHING;
INSERT INTO projects(project_name, definition, data_begin, data_end) VALUES('Демо-Сибирь', null, '05-11-2022', '23-11-2023') ON CONFLICT DO NOTHING;
INSERT INTO projects(project_name, definition, data_begin, data_end) VALUES('МВД-Онлайн', null, '22-05-2022', '31-03-2023') ON CONFLICT DO NOTHING;
INSERT INTO projects(project_name, definition, data_begin, data_end) VALUES('Поддержка', null, '07-06-2022', null) ON CONFLICT DO NOTHING;

INSERT INTO tasks(title, priority, definition, status, evaluation, expenses, master_user, running_user, project_name) 
VALUES ('t1', 1, 'Bair', 'Новая', 20, 13, 'Belova', null, 'Демо-Сибирь'),
('t2', 2, 'Lampo4ka', 'Закрыта', 40, 40, 'Belova', null, 'Демо-Сибирь'),
('t3', 3, 'Blini', 'Закрыта', 15, 15, 'Kasatkin', null, 'МВД-Онлайн'),
('t4', 4, 'Oladia', 'Переоткрыта', 5, 1, 'Berkut', 'Drozdov', 'МВД-Онлайн'),
('t5', 5, 'Buuzi', 'Закрыта', 13, 13, 'Petrova', null, 'МВД-Онлайн'),
('t6', 6, 'Russia', 'Новая', 5, 4, 'Berkut', 'Berkut', 'Поддержка'),
('t7', 7, 'Baikal', 'Выполняется', 1, 0, 'Drozdov', 'Belova', 'Поддержка'),
('t8', 8, 'Armyanin', 'Выполняется', 10, 0, 'Makenroi', 'Kasatkin', 'Поддержка'),
('t9', 9, 'Kosmos', 'Закрыта', 16, 16, 'Kasatkin', null, 'РТК'),
('t10', 10, 'Choco-Pie', 'Выполняется', 9, 13, 'Petrova', 'Berkut', 'РТК') ON CONFLICT DO NOTHING;



