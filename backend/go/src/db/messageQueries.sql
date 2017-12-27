-- name: insertMessage
insert into messages (uuid, full_text, created_timestamp_server, sender_id, parent_id)
	select 
		:messageuuid,
		:messagetext,
		:messagetimestamp,
		(select id from users where users.uuid = :senderuuid), 
		(select id from messages where messages.uuid = :parentuuid)
;
insert into conversations_messages (conversation_id, message_id)
	select 
		(select id from conversations where conversations.uuid = :conversationuuid),
		(select id from messages where messages.uuid = :messageuuid)
;
select 
	users.uuid as uuid
from users
join group_users
	on group_users.user_id = users.id
join conversations
	on conversations.group_id = group_users.group_id
;

-- name: lastXMessages
select 	
	messages.uuid as uuid,			
	messages.full_text as fulltext,		
	messages.created_timestamp_server as createdtimestampserver,	
	sender.uuid as senderuuid,		
	parent.uuid as parentuuid,
	sender.photo_url as senderphotourl	
from messages 
join conversations_messages
	on conversations_messages.message_id = messages.id
join conversations
	on conversations.id = messages.conversation_id
join users sender # added an alias to make it clear
	on sender.id = messages.sender_id
join messages parent # added an alias to make it clear
	on parent.id = messages.parent_id
where conversations.uuid = :conversationuuid
where messages.created_timestamp_server < :latestservertimestamp
order by messages.created_timestamp_server desc limit :x
;