ALTER TABLE tasks
ADD CONSTRAINT create_ct
FOREIGN KEY (creator)
REFERENCES users(login);

ALTER TABLE users
ADD CONSTRAINT unique_login UNIQUE(login);