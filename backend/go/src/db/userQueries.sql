-- name: findUsersByUsername
select *
from users
where 
	username like ?
;
