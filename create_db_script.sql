CREATE TABLE IF NOT EXISTS users (
	id 				int 		NOT NULL AUTO_INCREMENT,
	uuid			string		NOT NULL,
	name 			string 		NOT NULL,
	mobile_number	string		NOT NULL,
	photo_url 		string,
	date_created	timestamp	NOT NULL,
	UNIQUE KEY (mobile_number),
	UNIQUE KEY (uuid),
	PRIMARY KEY (id)
)

CREATE TABLE IF NOT EXISTS tags (
	id 				int 		NOT NULL AUTO_INCREMENT,
	uuid			string		NOT NULL,
	name 			string 		NOT NULL,
	is_thread 		boolean		NOT NULL,
	is_topic		boolean		NOT NULL,
	date_created	timestamp	NOT NULL,
	UNIQUE KEY (uuid),
	PRIMARY KEY (id)
)

CREATE TABLE IF NOT EXISTS messages (
	id  			int 		NOT NULL AUTO_INCREMENT,
	uuid			string		NOT NULL,
	is_thread 		boolean,	NOT NULL,
	thread_id		int
	is_text 		boolean		DEFAULT true,
	full_text		string,
	is_link			boolean,
	link 			string,
	date_created	timestamp	NOT NULL,
	sender_id		int 		NOT NULL,
	UNIQUE KEY (uuid),
	PRIMARY KEY (id),
	FOREIGN KEY	(sender_id) REFERENCES users.id
)

CREATE TABLE IF NOT EXISTS users_messages (
	user_id 	int,	NOT NULL,
	message_id	int,	NOT NULL,
	FOREIGN KEY (user_id) REFERENCES users.id,
	FOREIGN KEY (message_id) REFERENCES messages.id
)

CREATE TABLE IF NOT EXISTS tags_messages (
	tag_id 		int,	NOT NULL,
	message_id	int,	NOT NULL,
	FOREIGN KEY (tag_id) REFERENCES tags.id,
	FOREIGN KEY (message_id) REFERENCES messages.id
)