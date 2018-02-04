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
	is_topic					boolean			NOT NULL,
	created_timestamp_server	int				NOT NULL,
	UNIQUE KEY (uuid),
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
	topic_tag_id				int 			NOT NULL,
	is_default					boolean			NOT NULL,
	group_id					int             NOT NULL,
	photo_uri					varchar(200),
	UNIQUE KEY (uuid),
	PRIMARY KEY (id),
	FOREIGN KEY (topic_tag_id) REFERENCES tags (id),
	FOREIGN KEY (group_id) REFERENCES groups (id)
);

CREATE TABLE IF NOT EXISTS messages (
	id  			int 			NOT NULL AUTO_INCREMENT,
	uuid			varchar(36)		NOT NULL,
	all_text		varchar(1000),
	created_timestamp_server	int				NOT NULL,
	sender_id		int 			NOT NULL,
	parent_id		int,
	conversation_id int,
	UNIQUE KEY (uuid),
	PRIMARY KEY (id),
	FOREIGN KEY	(sender_id) REFERENCES users (id),
	FOREIGN KEY (parent_id) REFERENCES messages (id),
	FOREIGN KEY (conversation_id) REFERENCES conversations (id)
);

-- relationship specifying users in a group
CREATE TABLE IF NOT EXISTS group_users (
	user_id 		int			NOT NULL,
	group_id		int			NOT NULL,
	FOREIGN KEY (user_id) REFERENCES users (id),
	FOREIGN KEY (group_id) REFERENCES groups (id)
);

-- relationship mapping conversations to tags
CREATE TABLE IF NOT EXISTS conversations_tags (
	conversation_id	int			NOT NULL,
	tag_id 			int			NOT NULL,
	FOREIGN KEY (conversation_id) REFERENCES conversations (id),
	FOREIGN KEY (tag_id) REFERENCES tags (id)
);

INSERT INTO users VALUES (NULL, 'uuid-1', 'Prafulla', '724309111', 'prafulla_prof', 1000), 
						 (NULL, 'uuid-2', 'Rahul', '724309222', 'rahul_prof', 1200),
						 (NULL, 'uuid-3', 'Reia', '724309228', 'reia_prof', 1400);
INSERT INTO tags VALUES (NULL, 'uuid-1', 'shopping', 0, 1500);
INSERT INTO groups VALUES (NULL, 'uuid-1', 'Prafulla', 1000, 'prafulla_prof'),
						  (NULL, 'uuid-2', 'Rahul', 1200, 'rahul_prof'),
						  (NULL, 'uuid-3', 'Reia', 1400, 'reia_prof');
INSERT INTO conversations VALUES (NULL, 'uuid-1', 1000, 1000, 1, 1, 1, 'prafulla_prof'),
								 (NULL, 'uuid-2', 1200, 1200, 1, 1, 1, 'rahul_prof'),
								 (NULL, 'uuid-3', 1400, 1400, 1, 1, 1, 'reia_prof');
INSERT INTO messages VALUES (NULL, 'uuid-1', 'Hello World!', 1500, 1, NULL, 1);
INSERT INTO group_users VALUES (1,1),(2,2),(3,3);


