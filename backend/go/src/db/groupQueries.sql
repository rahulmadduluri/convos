-- name: findConversationsForGroup
select
	conversations.uuid as uuid,
	conversations.updated_timestamp_server as updatedtimestampserver,
	conversations.topic as topic,
	selected_group.uuid as groupuuid,
	conversations.photo_uri as photouri
from (
	select
		groups.id as group_id,
		groups.uuid as uuid 
	from groups
	where groups.uuid = :group_uuid
) as selected_group
join conversations
	on conversations.group_id = selected_group.group_id
order by conversations.updated_timestamp_server desc limit :max_conversations
;

-- name: findMembersForGroup
select
	users.uuid as uuid,
	users.name as name,
	users.handle as handle,
	users.photo_uri as photouri
from (
	select distinct 
		members.user_id as person_id,
		members.created_timestamp_server as created_timestamp_server
	from members
	where group_id in (
		select id
		from groups
		where groups.uuid = :group_uuid
	)
) as group_members
join users
	on group_members.person_id = users.id
where users.name like :search_text or users.handle like :search_text
order by group_members.created_timestamp_server desc limit :max_members
;

-- name: updateGroupName
update groups 
set name = :name
where groups.uuid = :group_uuid
;

-- name: updateGroupMembers
insert into members (group_id, user_id, created_timestamp_server)
	select 
		(select id from groups where groups.uuid = :group_uuid), 
		(select id from users where users.uuid = :member_uuid),
		:created_timestamp_server
;

-- name: createGroup
insert into groups (uuid, name, handle, created_timestamp_server, photo_uri)
	select
		:group_uuid,
		:name,
		:handle,
		:created_timestamp_server,
		:photo_uri
;
