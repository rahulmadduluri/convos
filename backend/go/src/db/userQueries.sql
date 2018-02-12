-- name: findPeople
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
			and users.name like :search_text
	)
) as user_people
join users
	on user_people.person_id = users.id
order by user_people.created_timestamp_server desc limit :max_people
;