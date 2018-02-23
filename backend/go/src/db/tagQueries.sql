-- name: createTag
insert into tags (uuid, name, is_topic, created_timestamp_server)
	select 
		:tag_uuid,
		:name,
		:is_topic,
		:created_timestamp_server
;
