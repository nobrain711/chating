-- Users 회원정보 테이블
CREATE TABLE IF NOT EXISTS app.users (
    user_num     BIGSERIAL   PRIMARY KEY,
    user_id      VARCHAR(30)	NOT NULL UNIQUE,
    user_pw      TEXT       	NOT NULL,
    user_name    VARCHAR(30)	NOT NULL UNIQUE,
    user_status  SMALLINT   	NOT NULL DEFAULT 0 CHECK (user_status IN (0, 1)), -- 0 active / 1 deleted
    created_at   TIMESTAMPTZ	NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMPTZ	NOT NULL DEFAULT NOW()
);

-- Rooms 채팅방 정보 테이블
CREATE TABLE IF NOT EXISTS app.rooms (
    id              BIGSERIAL  PRIMARY KEY,
    room_name       VARCHAR(50),
    room_type       SMALLINT    	NOT NULL            CHECK (room_type 	IN (0, 1, 2)), -- 0 dm / 1 group / 2 chatbot
    room_status     SMALLINT    	NOT NULL DEFAULT 0  CHECK (room_status	IN (0, 1)), -- 0 active / 1 deleted
    created_at      TIMESTAMPTZ	NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ	NOT NULL DEFAULT NOW(),
    last_message_at TIMESTAMPTZ	NOT NULL DEFAULT NOW()
);

-- Messages 메시지 정보 테이블
CREATE TABLE IF NOT EXISTS app.messages (
    message_id     BIGSERIAL 	PRIMARY KEY,
    room_id        BIGINT    	NOT NULL REFERENCES app.rooms(id)       ON DELETE CASCADE,
    sender_user    BIGINT    	NOT NULL REFERENCES app.users(user_num) ON DELETE CASCADE,
    content        TEXT      	NOT NULL,
	message_status SMALLINT     	NOT NULL DEFAULT 0 CHECK (message_status IN (0, 1)), -- 0 active / 1 deleted
    created_at     TIMESTAMPTZ	NOT NULL DEFAULT NOW()
);

-- users ↔ rooms 조인 테이블
CREATE TABLE IF NOT EXISTS app.users_rooms (
    user_num 	BIGINT 		NOT NULL	REFERENCES app.users(user_num) ON DELETE CASCADE,
    room_id  	BIGINT 		NOT NULL	REFERENCES app.rooms(id)       ON DELETE CASCADE,
    in_room		SMALLINT		NOT	NULL	DEFAULT	0	CHECK	(in_room	 IN	(0,1)), -- 0 not in the room / 1 in the room 
    last_seen_at	TIMESTAMPTZ,
    PRIMARY KEY (user_num, room_id)
);