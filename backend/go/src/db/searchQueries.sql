-- name: findConversationsForUserWithSearch
select
	conversations.uuid as uuid,
	conversations.topic as topic,
	conversations.updated_timestamp_server as updatedtimestampserver,
	conversations.photo_uri as photouri,
	groups.uuid as groupuuid
from (
	select distinct group_id
	from members
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
where (groups.name like :search_text or conversations.topic like :search_text)
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