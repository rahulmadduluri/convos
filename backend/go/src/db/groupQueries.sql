-- name: findPeopleForGroup
select
	users.uuid as uuid,
	users.name as name,
	users.photo_uri as photouri
from (
	select distinct 
		group_users.user_id as person_id,
		group_users.created_timestamp_server as created_timestamp_server
	from group_users
	where group_id in (
		select id
		from groups
		where groups.uuid = :group_uuid
	)
) as user_people
join users
	on user_people.person_id = users.id
where users.name like :search_text
order by user_people.created_timestamp_server desc limit :max_people
;

-- name: updateGroupName
update groups 
set name = :name
where groups.uuid = :group_uuid
;

-- name: updateGroupMembers
insert into group_users (group_id, user_id, created_timestamp_server)
	select 
		(select id from groups where groups.uuid = :group_uuid), 
		(select id from users where users.uuid = :member_uuid),
		:created_timestamp_server
;
