ALTER TABLE projects
ALTER COLUMN project_name TYPE varchar(100);

ALTER TABLE users
ALTER COLUMN login TYPE varchar(100);

ALTER TABLE users
ADD CONSTRAINT unique_login UNIQUE(login);
ALTER TABLE tasks
ADD FOREIGN KEY (customer_id) REFERENCES customers (id);
ALTER TABLE tasks
ADD COLUMN project_name varchar(50),
ADD CONSTRAINT project_constraint FOREIGN KEY (project_name)
REFERENCES projects (project_name);

ALTER TABLE tasks  
ADD COLUMN master_user varchar(50), ADD COLUMN running_user varchar(50);

ALTER TABLE tasks
ADD CONSTRAINT user_constraint FOREIGN KEY (master_user)
REFERENCES users (login);

