-- name: createTag
insert into tags (uuid, name, created_timestamp_server)
	select 
		:tag_uuid,
		:name,
		:created_timestamp_server
;
