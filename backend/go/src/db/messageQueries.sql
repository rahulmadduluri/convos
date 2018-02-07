-- name: insertMessage
insert into messages (uuid, all_text, created_timestamp_server, sender_id, parent_id, conversation_id)
	select 
		:messageuuid,
		:messagetext,
		:messagetimestamp,
		(select id from users where users.uuid = :senderuuid), 
		(select id from messages where messages.uuid = :parentuuid),
		(select id from conversations where conversations.uuid = :conversationuuid)
;

-- name: getUsersForConversation
select 
	users.uuid as uuid,
	users.photo_uri as photouri
from users
join group_users
	on group_users.user_id = users.id
join conversations
	on conversations.group_id = group_users.group_id
where conversations.uuid = :conversationuuid
;

-- name: lastXMessages
select 	
	messages.uuid as uuid,			
	messages.all_text as alltext,		
	messages.created_timestamp_server as createdtimestampserver,	
	sender.uuid as senderuuid,		
	parent.uuid as parentuuid,
	sender.photo_uri as senderphotouri	
from messages 
join conversations
	on conversations.id = messages.conversation_id
join users sender 
	on sender.id = messages.sender_id
left join messages parent 
	on parent.id = messages.parent_id
where conversations.uuid = :conversationuuid 
and messages.created_timestamp_server < :latesttimestampserver
order by messages.created_timestamp_server desc limit :x
;