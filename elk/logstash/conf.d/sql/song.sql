SELECT
	o.id,
	o.lyric,
	o.mv,
	o.`name`,
	o.recommend,
	o.singer_id,
	i.`name` singer_name,
	o.sq_url,
	o.`status`,
	o.updated_at,
	o.url, 
	o.song_status,
	o.background,
	o.sole,
	o.album_id,
	m.`name` album_name,
	o.avatar,
	o.created_at,
	o.hot,
	o.hq_url,
	COALESCE(o.deleted_at,0) deleted_at
FROM
	hyxk_app_song o
	LEFT JOIN hyxk_app_singer i ON o.singer_id = i.id
	LEFT JOIN hyxk_app_album m ON o.album_id = m.id