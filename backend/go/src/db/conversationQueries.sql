-- name: findConversationsForUserWithTitle
select 
	conversations.uuid as uuid,
	conversations.created_timestamp_server as created_timestamp_server,
	tags.name as title
from conversations
join (
	select conversation_id
	from group_conversations
	where group_id in (
		select group_id
		from group_users
		where user_id in (
			select id
			from users
			where users.uuid = ?
		)
	)
) as a
	on a.conversation_id = conversations.id
join tags
	on conversations.topic_tag_id = tags.id
where tags.name like ?
;