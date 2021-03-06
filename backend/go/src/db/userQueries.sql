-- name: getUser
select
	users.uuid as uuid,
	users.name as name,
	users.handle as handle,
	users.photo_uri as photouri
from users
where users.uuid = :user_uuid

-- name: createUser
insert into users (uuid, name, handle, mobile_number, created_timestamp_server, photo_uri)
	select
		:user_uuid,
		:name,
		:handle,
		:mobile_number,
		:created_timestamp_server,
		:photo_uri
;

-- name: findContactsForUser
select
	users.uuid as uuid,
	users.name as name,
	users.handle as handle,
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
where users.name like :search_text or users.handle like :search_text
order by user_contacts.created_timestamp_server desc limit :max_contacts
;

-- name: findUsers
select
	users.uuid as uuid,
	users.name as name,
	users.handle as handle,
	users.photo_uri as photouri
from users
where users.name like :search_text or users.handle like :search_text
limit :max_users

-- name: updateContacts
insert into contacts (user_id, contact_id, created_timestamp_server)
	select 
		(select id from users where users.uuid = :user_uuid), 
		(select id from users where users.uuid = :contact_uuid),
		:created_timestamp_server
;

-- name: updateUserName
update users
set name = :name
where users.uuid = :user_uuid
;

-- name: updateUserHandle
update users
set handle = :handle
where users.uuid = :user_uuid
;
