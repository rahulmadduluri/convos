CREATE TABLE IF NOT EXISTS users (
	id 							int 			NOT NULL AUTO_INCREMENT,
	uuid						varchar(36)		NOT NULL,
	username 					varchar(200)	NOT NULL,
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

CREATE TABLE IF NOT EXISTS messages (
	id  			int 			NOT NULL AUTO_INCREMENT,
	uuid			varchar(36)		NOT NULL,
	full_text		varchar(1000),
	created_timestamp_server	int				NOT NULL,
	sender_id		int 			NOT NULL,
	parent_id		int,
	UNIQUE KEY (uuid),
	PRIMARY KEY (id),
	FOREIGN KEY	(sender_id) REFERENCES users (id),
	FOREIGN KEY (parent_id) REFERENCES messages (id)
);

CREATE TABLE IF NOT EXISTS conversations (
	id  						int 			NOT NULL AUTO_INCREMENT,
	uuid						varchar(36)		NOT NULL,
	created_timestamp_server	int				NOT NULL,
	updated_timestamp_server	int 			NOT NULL,
	topic_tag_id				int 			NOT NULL,
	UNIQUE KEY (uuid),
	PRIMARY KEY (id),
	FOREIGN KEY (topic_tag_id) REFERENCES tags (id)
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

-- relationship specifying users in a group
CREATE TABLE IF NOT EXISTS group_users (
	user_id 		int			NOT NULL,
	group_id		int			NOT NULL,
	FOREIGN KEY (user_id) REFERENCES users (id),
	FOREIGN KEY (group_id) REFERENCES groups (id)
);

-- relationship specifying which conversations a group has had
CREATE TABLE IF NOT EXISTS group_conversations (
	group_id 		int			NOT NULL,
	conversation_id	int			NOT NULL,
	isDefault		boolean		DEFAULT 1,
	FOREIGN KEY (group_id) REFERENCES groups (id),
	FOREIGN KEY (conversation_id) REFERENCES conversations (id)
);

-- relationship mapping conversations to tags
CREATE TABLE IF NOT EXISTS conversations_tags (
	conversation_id	int			NOT NULL,
	tag_id 			int			NOT NULL,
	FOREIGN KEY (conversation_id) REFERENCES conversations (id),
	FOREIGN KEY (tag_id) REFERENCES tags (id)
);

-- relationship listing messages
CREATE TABLE IF NOT EXISTS conversations_messages (
	conversation_id 	int	NOT NULL,
	message_id			int	NOT NULL,
	FOREIGN KEY (conversation_id) REFERENCES conversations (id),
	FOREIGN KEY (message_id) REFERENCES messages (id)
);
