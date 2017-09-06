select
combo_ids.user_id as user_id,
combo_ids.tag_id as tag_id,
users.name as user_name,
tags.name as tag_name
from (
    select
    users_tags.user_id as user_id,
    users_tags.tag_id as tag_id
    from (
        select 
        tag_id
        from users_tags
        where users_tags.user_id = 1
        ) as tag_ids
    join users_tags
    on users_tags.tag_id = tag_ids.tag_id
) as combo_ids
join users
on combo_ids.user_id = users.id
join tags
on combo_ids.tag_id = tags.id
where tags.is_topic = true