-- name: findPeopleForUser
select
	users.uuid as uuid,
	users.name as name,
	users.photo_uri as photouri
from (
	select distinct 
		people.person_id as person_id,
		people.created_timestamp_server as created_timestamp_server
	from people
	where user_id in (
		select id
		from users
		where users.uuid = :user_uuid
	)
) as user_people
join users
	on user_people.person_id = users.id
where users.name like :search_text
order by user_people.created_timestamp_server desc limit :max_people
;

-- name: findPeopleForGroup
select
	users.uuid as uuid,
	users.name as name,
	users.photo_uri as photouri
from (
	select distinct 
		group_users.user_id as person_id,
		people.created_timestamp_server as created_timestamp_server
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