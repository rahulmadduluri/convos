-- name: findConversationsByUserId
select 
	uuid,
	photo_url,
	date_created,
	topic_tag_id
from conversations
join (    select conversation_id 
    from group_members
    where user_id = ?
) as convos_ids
    on conversations.id = convo_ids.conversation_id


-- name: findUsersByName
select *
from users
where username like ?
