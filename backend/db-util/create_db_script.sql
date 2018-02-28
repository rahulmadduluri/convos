DROP DATABASE IF EXISTS convos;
CREATE DATABASE convos;
USE convos;
CREATE TABLE IF NOT EXISTS users (
	id 							int 			NOT NULL AUTO_INCREMENT,
	uuid						varchar(36)		NOT NULL,
	name 						varchar(200)	NOT NULL,
	mobile_number				varchar(36)		NOT NULL,
	photo_uri 					varchar(200),
	created_timestamp_server	int				NOT NULL,
	UNIQUE KEY (uuid),
	UNIQUE KEY (mobile_number),
	PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS tags (
	id 							int 			NOT NULL AUTO_INCREMENT,
	uuid						varchar(36)		NOT NULL,
	name 						varchar(200)	NOT NULL,
	created_timestamp_server	int				NOT NULL,
	UNIQUE KEY (uuid),
	UNIQUE KEY (name),
	PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS groups (
	id  						int 			NOT NULL AUTO_INCREMENT,
	uuid						varchar(36)		NOT NULL,
	name						varchar(200)	NOT NULL,
	created_timestamp_server	int				NOT NULL,
	photo_uri 					varchar(200),
	UNIQUE KEY (uuid),
	PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS conversations (
	id  						int 			NOT NULL AUTO_INCREMENT,
	uuid						varchar(36)		NOT NULL,
	created_timestamp_server	int				NOT NULL,
	updated_timestamp_server	int 			NOT NULL,
	topic						varchar(200) 	NOT NULL,
	-- is_default: is the convo the group's default convo
	is_default					boolean			NOT NULL,
	group_id					int             NOT NULL,
	photo_uri					varchar(200),
	UNIQUE KEY (uuid),
	PRIMARY KEY (id),
	FOREIGN KEY (group_id) REFERENCES groups (id)
);

CREATE TABLE IF NOT EXISTS messages (
	id  						int 			NOT NULL AUTO_INCREMENT,
	uuid						varchar(36)		NOT NULL,
	all_text					varchar(1000),
	created_timestamp_server	int				NOT NULL,
	sender_id					int 			NOT NULL,
	parent_id					int,
	conversation_id 			int,
	UNIQUE KEY (uuid),
	PRIMARY KEY (id),
	FOREIGN KEY	(sender_id) REFERENCES users (id),
	FOREIGN KEY (parent_id) REFERENCES messages (id),
	FOREIGN KEY (conversation_id) REFERENCES conversations (id)
);

-- relationship specifying users in a group
CREATE TABLE IF NOT EXISTS members (
	group_id					int		NOT NULL,
	user_id 					int		NOT NULL,
	created_timestamp_server	int		NOT NULL,
	UNIQUE KEY (group_id, user_id),
	FOREIGN KEY (group_id) REFERENCES groups (id),
	FOREIGN KEY (user_id) REFERENCES users (id)
);

-- relationship mapping conversations to tags
CREATE TABLE IF NOT EXISTS conversations_tags (
	conversation_id	int			NOT NULL,
	tag_id 			int			NOT NULL,
	UNIQUE KEY (conversation_id, tag_id),
	FOREIGN KEY (conversation_id) REFERENCES conversations (id),
	FOREIGN KEY (tag_id) REFERENCES tags (id)
);

-- relationship between users and other users
CREATE TABLE IF NOT EXISTS people (
	user_id 					int 	NOT NULL,
	person_id 					int 	NOT NULL,
	created_timestamp_server	int		NOT NULL,
	UNIQUE KEY (user_id, person_id),
	FOREIGN KEY (user_id) REFERENCES users (id),
	FOREIGN KEY (person_id) REFERENCES users (id)
);

-- repeat names are because group creates a tag that shares the group name
-- users: 1. prafulla, 2. rahul, 3. reia
INSERT INTO users VALUES (NULL, 'uuid-1', 'Prafulla', '724309111', 'prafulla_prof', 1000), 
						 (NULL, 'uuid-2', 'Rahul', '724309222', 'rahul_prof', 1200),
						 (NULL, 'uuid-3', 'Reia', '724309228', 'reia_prof', 1400);
INSERT INTO people VALUES (1,2,500),(1,3,600),(2,1,500),(2,3,700),(3,1,600),(3,2,700);
-- groups: 1. prafulla, 2. rahul, 3. reia 4. 93 webster
INSERT INTO groups VALUES (NULL, 'uuid-1', 'Prafulla', 1000, 'prafulla_prof'),
						  (NULL, 'uuid-2', 'Rahul', 1200, 'rahul_prof'),
						  (NULL, 'uuid-3', 'Reia', 1400, 'reia_prof'),
						  (NULL, 'uuid-4', '93Webster', 1600, '93');
INSERT INTO conversations VALUES (NULL, 'uuid-1', 1000, 1000, "Prafulla", 1, 1, 'prafulla_prof'),
								 (NULL, 'uuid-2', 1200, 1200, "Rahul", 1, 2, 'rahul_prof'),
								 (NULL, 'uuid-3', 1400, 1400, "Reia", 1, 3, 'reia_prof'),
								 (NULL, 'uuid-4', 1000, 1000, "A", 0, 1, 'prafulla_prof'),
								 (NULL, 'uuid-5', 1200, 1200, "B", 0, 2, 'rahul_prof'),
								 (NULL, 'uuid-6', 1200, 1200, "C", 0, 2, 'rahul_prof'),
								 (NULL, 'uuid-7', 1200, 1200, "Scrub", 0, 3, 'reia_prof'),
								 (NULL, 'uuid-8', 1600, 1600, "93Webster", 1, 4, '93'),
								 (NULL, 'uuid-9', 1600, 1600, "Travel", 0, 4, 'plane');
INSERT INTO members VALUES (1,1,1000),(2,2,1200),(3,3,1400),(4,1,1480),(4,2,1490),(4,3,1500);
INSERT INTO messages VALUES (NULL, 'uuid-1', 'Hello World!', 1500, 1, NULL, 1),
							(NULL, 'uuid-2', 'Yo yo yo', 1505, 1, NULL, 1),
							(NULL, 'uuid-3', 'My name is jo', 1510, 1, 2, 1),
							(NULL, 'uuid-4', 'Huh-Watchu talking about?', 1520, 1, 2, 1);
