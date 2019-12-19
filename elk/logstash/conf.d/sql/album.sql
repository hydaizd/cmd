SELECT
	a.id,
	a.`name` album,
	a.avatar,
	s.`name` singer, 
	COALESCE(a.deleted_at,0) deleted_at
FROM
	`hyxk_app_album` a
	LEFT JOIN hyxk_app_singer s ON a.singer_id = s.id