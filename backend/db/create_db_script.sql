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
	upvotes			int 			DEFAULT 0,
	date_created	timestamp		NOT NULL,
	sender_id		int 			NOT NULL,
	parent_id		int,
	UNIQUE KEY (uuid),
	PRIMARY KEY (id),
	FOREIGN KEY	(sender_id) REFERENCES users (id),
	FOREIGN KEY (parent_id) REFERENCES messages (id)
);

CREATE TABLE IF NOT EXISTS conversations (
	id  			int 			NOT NULL AUTO_INCREMENT,
	uuid			varchar(36)		NOT NULL,
	photo_url 		varchar(200),
	date_created	timestamp		NOT NULL,
	topic_tag_id	int 			NOT NULL,
	UNIQUE KEY (uuid),
	PRIMARY KEY (id),
	FOREIGN KEY (topic_tag_id) REFERENCES tags (id)
);

CREATE TABLE IF NOT EXISTS users_conversations (
	user_id 		int			NOT NULL,
	conversation_id	int			NOT NULL,
	is_admin		boolean 	DEFAULT false,
	FOREIGN KEY (user_id) REFERENCES users (id),
	FOREIGN KEY (conversation_id) REFERENCES conversations (id)
);

CREATE TABLE IF NOT EXISTS conversations_tags (
	conversation_id	int			NOT NULL,
	tag_id 			int			NOT NULL,
	FOREIGN KEY (conversation_id) REFERENCES conversations (id),
	FOREIGN KEY (tag_id) REFERENCES tags (id)
);

CREATE TABLE IF NOT EXISTS conversations_messages (
	conversation_id 	int	NOT NULL,
	message_id			int	NOT NULL,
	FOREIGN KEY (conversation_id) REFERENCES conversations (id),
	FOREIGN KEY (message_id) REFERENCES messages (id)
);
