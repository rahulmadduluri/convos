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
