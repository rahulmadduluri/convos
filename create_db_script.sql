CREATE TABLE IF NOT EXISTS users (
	id 				int 			NOT NULL AUTO_INCREMENT,
	uuid			varchar(36)		NOT NULL,
	name 			varchar(200)	NOT NULL,
	mobile_number	varchar(36)		NOT NULL,
	photo_url 		varchar(200),
	date_created	timestamp		NOT NULL,
	UNIQUE KEY (uuid),
	PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS tags (
	id 				int 			NOT NULL AUTO_INCREMENT,
	uuid			varchar(36)		NOT NULL,
	name 			varchar(200)	NOT NULL,
	is_thread 		boolean			NOT NULL,
	is_topic		boolean			NOT NULL,
	date_created	timestamp		NOT NULL,
	UNIQUE KEY (uuid),
	PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS messages (
	id  			int 			NOT NULL AUTO_INCREMENT,
	uuid			varchar(36)		NOT NULL,
	is_text 		boolean			DEFAULT true,
	full_text		varchar(1000),
	is_link			boolean			DEFAULT false,
	link 			varchar(200),
	date_created	timestamp		NOT NULL,
	sender_id		int 			NOT NULL,
	UNIQUE KEY (uuid),
	PRIMARY KEY (id),
	FOREIGN KEY	(sender_id) REFERENCES users (id)
);

CREATE TABLE IF NOT EXISTS users_messages (
	user_id 	int	NOT NULL,
	message_id	int	NOT NULL,
	FOREIGN KEY (user_id) REFERENCES users (id),
	FOREIGN KEY (message_id) REFERENCES messages (id)
);

CREATE TABLE IF NOT EXISTS users_tags (
	user_id 	int	NOT NULL,
	tag_id		int	NOT NULL,
	FOREIGN KEY (user_id) REFERENCES users (id),
	FOREIGN KEY (tag_id) REFERENCES tags (id)
);

CREATE TABLE IF NOT EXISTS tags_messages (
	tag_id 		int	NOT NULL,
	message_id	int	NOT NULL,
	FOREIGN KEY (tag_id) REFERENCES tags (id),
	FOREIGN KEY (message_id) REFERENCES messages (id)
);