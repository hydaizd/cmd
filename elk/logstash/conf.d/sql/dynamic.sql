SELECT
	s.id,
	s.movie_title,
	s.movie,
	s.content,
	s.picture,
	s.at_following,
	s.pick_topic,
	s.user_type,
	s.user_id,
	u.nickname user_name,
	s.created_at,
	COALESCE ( s.deleted_at, 0 ) deleted_at 
FROM
	`hyxk_app_post_status` s
	LEFT JOIN hyxk_app_user u ON s.user_id = u.id
WHERE s.user_type = 1
union
SELECT
	s.id,
	s.movie_title,
	s.movie,
	s.content,
	s.picture,
	s.at_following,
	s.pick_topic,
	s.user_type,
	s.user_id,
	i.name user_name,
	s.created_at,
	COALESCE ( s.deleted_at, 0 ) deleted_at 
FROM
	`hyxk_app_post_status` s
	LEFT JOIN hyxk_app_singer i ON s.user_id = i.id
WHERE s.user_type = 2