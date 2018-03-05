-- name: createTag
insert into tags (uuid, name, count, created_timestamp_server)
	select 
		:tag_uuid,
		:name,
		:count,
		:created_timestamp_server
;

-- name: updateTagCount
update tags
	set count = count + 1
	where name = :name
;

-- name: updateConversationTags
insert into conversations_tags (conversation_id, tag_id, created_timestamp_server)
	select 
		(select id from conversations where conversations.uuid = :conversation_uuid), 
		(select id from tags where tags.uuid = :tag_uuid or tags.name = :name),
		:created_timestamp_server
;
