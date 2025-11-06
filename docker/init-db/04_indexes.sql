-- extension pg_trgm
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Users Table
CREATE INDEX IF NOT EXISTS idx_user_name
ON app.users (user_name);

CREATE INDEX IF NOT EXISTS idx_user_status_updated_at
ON app.users (user_status, updated_at);

-- Rooms Table
CREATE INDEX IF NOT EXISTS idx_room_status_updated_at
ON app.rooms (room_status, updated_at);

-- 최근 메시지 정렬/목록용
CREATE INDEX IF NOT EXISTS idx_rooms_last_message_at_desc
ON app.rooms (room_status, last_message_at DESC);

-- Messages Table
-- 메시지 발신자
CREATE INDEX IF NOT EXISTS idx_sender_user_room_id
ON app.messages (sender_user, room_id);

-- 방별 최신 메시지
CREATE INDEX IF NOT EXISTS idx_room_id_created_at
ON app.messages (room_id, created_at DESC);

-- 발신자 기준 최근 메시지
CREATE INDEX IF NOT EXISTS idx_sender_user_created_at
ON app.messages (sender_user, created_at);

-- 메시지 내용 검색 (활성화 된 메시지만)
CREATE INDEX IF NOT EXISTS idx_message_content_trgm_active
	ON app.messages
 USING GIN (content gin_trgm_ops)
 WHERE message_status = 0;

-- 메시지 내용 검색 (삭제 포함)
CREATE INDEX IF NOT EXISTS idx_message_content_trgm_all
	ON app.messages
 USING GIN (content gin_trgm_ops);

-- 체팅방 채팅 불러오기
CREATE INDEX IF NOT EXISTS idx_messages_room_created_id_desc
	ON	app.messages (room_id, created_at DESC, message_id DESC);

-- 채팅방 채팅 불러오기 asc
CREATE INDEX IF NOT EXISTS idx_messages_room_created_id_asc
	ON	app.messages (room_id, created_at, message_id);

-- Users_Rooms Table
CREATE INDEX IF NOT EXISTS idx_room_id_user_num
ON	app.users_rooms (room_id, user_num);