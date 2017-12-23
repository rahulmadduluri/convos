-- name: insertMessage
insert into messages
	select 
		:messageuuid,
		:messagetext,
		:messagetimestamp,
		(select sender_id from users where users.uuid = :senderuuid), 
		(select parent_id from messages where messages.uuid = :parentuuid)
;
insert into conversations_messages
	select 
		(select id from conversations where conversations.uuid = :conversationuuid),
		(select id from messages where messages.uuid = :messageuuid)
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