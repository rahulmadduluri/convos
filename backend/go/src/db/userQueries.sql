-- name: findUsersByUsername
select *
from users
where 
	name like ?
;
