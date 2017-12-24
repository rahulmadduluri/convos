-- name: findConversationsForUserWithSearch
select 
	conversations.uuid as uuid,
	conversations.updated_timestamp_server as updatedtimestampserver,
	conversations.is_default as isdefault,
	groups.photo_url as groupphotourl,
	groups.name as groupname,
	groups.uuid as groupuuid,
	tags.name as topic,
	tags.uuid as topictaguuid
from (
	select group_id
	from group_users
	where user_id in (
		select user_id
		from users
		where users.uuid = :user_uuid
	)
) as this_user_groups
join groups
	on this_user_groups.group_id = groups.id
join conversations
	on conversations.group_id = this_user_groups.group_id
join tags
	on conversations.topic_tag_id = tags.id
where ((groups.name like :search_text and conversations.is_default = true)
	or tags.name like :search_text)
;
