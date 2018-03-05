-- name: findContactsForUser
select
	users.uuid as uuid,
	users.name as name,
	users.photo_uri as photouri
from (
	select distinct 
		contacts.person_id as person_id,
		contacts.created_timestamp_server as created_timestamp_server
	from contacts
	where user_id in (
		select id
		from users
		where users.uuid = :user_uuid
	)
) as user_contacts
join users
	on user_contacts.person_id = users.id
where users.name like :search_text
order by user_contacts.created_timestamp_server desc limit :max_contacts
;
