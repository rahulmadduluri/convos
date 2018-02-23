-- name: createConversation
insert into conversations (uuid, created_timestamp_server, updated_timestamp_server, topic_tag_id, is_default, group_id, photo_uri)
	select 
		:conversation_uuid,
		:created_timestamp_server,
		:created_timestamp_server,
		(select id from tags where tags.uuid = :tag_uuid), 
		:is_default,
		(select id from groups where groups.uuid = :group_uuid), 
		:photo_uri
;
