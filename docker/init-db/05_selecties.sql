-- Users info 
EXPLAIN (ANALYZE, BUFFERS)
SELECT	u.user_num,
		u.user_id,
		u.user_name,
		u.created_at
FROM		app.users u
WHERE	u.user_id = 'jsninja';

-- user login or find password
EXPLAIN (ANALYZE, BUFFERS)
SELECT u.user_pw
FROM app.users u
WHERE user_id = 'neofox_77'
  AND user_status = 0;

-- user list for status active or delected
EXPLAIN (ANALYZE, BUFFERS)
SELECT 	u.user_num,
		u.user_id,
		u.user_status,
		u.updated_at
FROM 	app.users u
WHERE	u.user_status = :user_status;

-- messages
-- message key search for all room
EXPLAIN (ANALYZE, BUFFERS)
SELECT 	m.message_id,
		m.room_id,
		m.sender_user,
		m.content,
		m.created_at
FROM 	app.messages m
WHERE	m.message_status = 0
  AND	m.content ILIKE '%' || :q || '%'
ORDER BY	m.created_at DESC
LIMIT :limit;

-- message key search for room
EXPLAIN (ANALYZE, BUFFERS)
SELECT 	m.room_id,
		m.message_id,
		m.sender_user,
		m.content,
		m.created_at
FROM 	app.messages m
WHERE	m.message_status = 0
  AND	m.room_id = :room_id
  AND	m.content ILIKE '%' || :q || '%'
ORDER BY	m.created_at DESC
LIMIT :limit;	

-- rooms (삭제 제외)
-- room list
EXPLAIN (ANALYZE, BUFFERS)
SELECT 	r.id,
		r.room_name,
		r.room_type,
		r.last_message_at
FROM 	app.rooms r
JOIN		app.users_rooms ur ON r.id = ur.room_id
WHERE	room_status = 0
  AND 	ur.user_num = :user_num;

-- room join user
EXPLAIN (ANALYZE, BUFFERS)
SELECT	t.room_id,
  		t.room_name,
		JSON_AGG(
			JSON_BUILD_OBJECT(	'user_num',	t.user_num, 
		    					 	'user_id', 	t.user_id, 
		    						'user_name',	t.user_name)
	    ORDER BY t.user_id) AS user_list
FROM (
	SELECT	ur.room_id,
			ur.user_num,
			u.user_id,
			u.user_name,
			r.room_name
	FROM		app.users_rooms ur 
	JOIN		app.users u ON u.user_num	= ur.user_num
	JOIN		app.rooms r ON r.id 		 	= ur.room_id
	WHERE	u.user_num = :user_num
	  AND 	ur.room_id = :room_id
) AS t
GROUP BY t.room_id, t.room_name;

-- room messages show (특정 사용자 기준, 방별 메시지)
EXPLAIN (ANALYZE, BUFFERS)
SELECT	m.message_id,
		m.sender_user,
		u.user_name,
		m.content,
		m.message_status
FROM		app.messages m
JOIN		app.users u
  ON		u.user_num		=	m.sender_user
WHERE 	m.room_id		=	:id
  AND EXISTS(
  	SELECT	1
  	FROM		app.users_rooms ur
  	WHERE	ur.room_id	=	m.room_id
  	  AND	ur.user_num	=	:user_num)
  AND((:message_last_id IS NULL)
   OR	(m.message_id) > (:message_last_id))
ORDER BY	m.created_at	ASC,	
		m.message_id	ASC
LIMIT	50;

-- message list for room last send
EXPLAIN (ANALYZE, BUFFERS)
SELECT	r.id AS room_id,
		r.room_name,
		r.room_type,
		r.last_message_at,
		lm.message_id,
		lm.sender_user,
		lm.content,
		lm.message_status,
		lm.created_at AS last_message_any_at
FROM		(
	SELECT	id,
			room_name,
			room_type,
			last_message_at
	FROM		app.rooms
	WHERE	room_status	=	0
	ORDER	BY	last_message_at DESC NULLS LAST
) AS r
LEFT JOIN LATERAL(
	SELECT	m.message_id,
			m.sender_user,
			m.content,
			m.message_status,
			m.created_at
	FROM		app.messages	m
	WHERE	m.room_id	=	r.id
	ORDER	BY	m.created_at	DESC,
				m.message_id	DESC
	LIMIT	1
) lm ON	TRUE;