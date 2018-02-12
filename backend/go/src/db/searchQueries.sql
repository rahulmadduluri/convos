-- name: findConversationsForUserWithSearch
select
	conversations.uuid as uuid,
	conversations.updated_timestamp_server as updatedtimestampserver,
	conversations.is_default as isdefault,
	conversations.photo_uri as photouri,
	groups.uuid as groupuuid,
	tags.name as topic,
	tags.uuid as topictaguuid
from (
	select distinct group_id
	from group_users
	where user_id in (
		select id
		from users
		where users.uuid = :user_uuid
	)
) as user_group_ids
join groups
	on user_group_ids.group_id = groups.id
join conversations
	on conversations.group_id = user_group_ids.group_id
join tags
	on conversations.topic_tag_id = tags.id
where (groups.name like :search_text or tags.name like :search_text)
;

-- name: findGroupsWithUUIDs
select
	groups.uuid as uuid,
	groups.name as name,
	groups.created_timestamp_server as createdtimestampserver,
	groups.photo_uri as photouri
from groups
where groups.uuid in (?)
;