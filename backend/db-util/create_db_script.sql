DROP DATABASE IF EXISTS convos;
CREATE DATABASE convos;
USE convos;
CREATE TABLE IF NOT EXISTS users (
	id 							int 			NOT NULL AUTO_INCREMENT,
	uuid						varchar(36)		NOT NULL,
	name 					varchar(200)	NOT NULL,
	mobile_number				varchar(36)		NOT NULL,
	photo_url 					varchar(200),
	created_timestamp_server	int				NOT NULL,
	UNIQUE KEY (uuid),
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
	photo_url 					varchar(200),
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
	photo_url					varchar(200),
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

INSERT INTO users VALUES (NULL, 'uuid-1', 'Prafulla', '724309111', 'www.blah.com', 1000), 
						 (NULL, 'uuid-2', 'Rahul', '724309222', 'www.mandarin.com', 1200);
INSERT INTO tags VALUES (NULL, 'uuid-1', 'shopping', 0, 1500);
INSERT INTO groups VALUES (NULL, 'uuid-1', 'lundys', 1500, 'www.lundysalon.com');
INSERT INTO conversations VALUES (NULL, 'uuid-1', 1500, 1500, 1, 1, 1, 'www.convophoto.com');
INSERT INTO messages VALUES (NULL, 'uuid-1', 'Hello World!', 1500, 1, NULL, 1);
INSERT INTO group_users VALUES (1,1);
INSERT INTO group_users VALUES (2,1);


