-- name: createTag
insert into tags (uuid, name, created_timestamp_server)
	select 
		:tag_uuid,
		:name,
		:created_timestamp_server
;

-- name: updateConversationTags
insert into conversations_tags (conversation_id, tag_id, created_timestamp_server)
	select 
		(select id from conversations where conversations.uuid = :conversation_uuid), 
		(select id from tags where tags.uuid = :tag_uuid),
		:created_timestamp_server
;
