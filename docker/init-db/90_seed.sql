SET	search_path = app, public;

-- pgcrypto 확장 (비밀번호 해싱용)
CREATE	EXTENSION IF NOT EXISTS pgcrypto;

------------------------------------------------------------
-- 1) Users: 10명 (탈퇴 3명)
--    비밀번호는 'test1234'를 bcrypt로 해싱하여 저장
------------------------------------------------------------
INSERT INTO app.users (user_id, user_pw, user_name, user_status, created_at, updated_at)
VALUES
('neofox_77',    crypt('test1234', gen_salt('bf')), 'neofox_77',    0, NOW() - INTERVAL '10 days', NOW()),
('hanriver.dev', crypt('test1234', gen_salt('bf')), 'hanriver.dev', 0, NOW() - INTERVAL '9 days',  NOW()),
('luna_kim',     crypt('test1234', gen_salt('bf')), 'luna_kim',     0, NOW() - INTERVAL '8 days',  NOW()),
('datasage',     crypt('test1234', gen_salt('bf')), 'datasage',     0, NOW() - INTERVAL '8 days',  NOW()),
('pixel_ryu',    crypt('test1234', gen_salt('bf')), 'pixel_ryu',    0, NOW() - INTERVAL '7 days',  NOW()),
('yuna__park',   crypt('test1234', gen_salt('bf')), 'yuna__park',   0, NOW() - INTERVAL '7 days',  NOW()),
('coffee_cat',   crypt('test1234', gen_salt('bf')), 'coffee_cat',   1, NOW() - INTERVAL '6 days',  NOW()),
('cloudwalker',  crypt('test1234', gen_salt('bf')), 'cloudwalker',  1, NOW() - INTERVAL '6 days',  NOW()),
('jsninja',      crypt('test1234', gen_salt('bf')), 'jsninja',      1, NOW() - INTERVAL '5 days',  NOW()),
('midnight_owl', crypt('test1234', gen_salt('bf')), 'midnight_owl', 0, NOW() - INTERVAL '5 days',  NOW())
ON CONFLICT (user_id) DO NOTHING;

------------------------------------------------------------
-- 2) Rooms: DM 5개(0), Group 2개(1)
------------------------------------------------------------
INSERT INTO app.rooms (room_name, room_type, room_status, created_at, updated_at, last_message_at) VALUES
('DM: neofox_77 ↔ luna_kim',     0, 0, NOW() - INTERVAL '2 days', NOW(), NOW() - INTERVAL '2 days'),
('DM: hanriver.dev ↔ datasage',  0, 0, NOW() - INTERVAL '2 days', NOW(), NOW() - INTERVAL '2 days'),
('DM: pixel_ryu ↔ yuna__park',   0, 0, NOW() - INTERVAL '2 days', NOW(), NOW() - INTERVAL '2 days'),
('DM: coffee_cat ↔ cloudwalker', 0, 0, NOW() - INTERVAL '2 days', NOW(), NOW() - INTERVAL '2 days'),
('DM: jsninja ↔ midnight_owl',   0, 0, NOW() - INTERVAL '2 days', NOW(), NOW() - INTERVAL '2 days'),
('Group: dev-lounge',             1, 0, NOW() - INTERVAL '2 days', NOW(), NOW() - INTERVAL '2 days'),
('Group: game-night',             1, 0, NOW() - INTERVAL '2 days', NOW(), NOW() - INTERVAL '2 days')
ON CONFLICT DO NOTHING;

------------------------------------------------------------
-- 3) Users_Rooms: 멤버 매핑
------------------------------------------------------------
-- DM 1: neofox_77, luna_kim
INSERT INTO app.users_rooms (user_num, room_id)
VALUES
((SELECT user_num FROM app.users WHERE user_id='neofox_77'),  (SELECT id FROM app.rooms WHERE room_name='DM: neofox_77 ↔ luna_kim')),
((SELECT user_num FROM app.users WHERE user_id='luna_kim'),   (SELECT id FROM app.rooms WHERE room_name='DM: neofox_77 ↔ luna_kim'))
ON CONFLICT DO NOTHING;

-- DM 2: hanriver.dev, datasage
INSERT INTO app.users_rooms (user_num, room_id)
VALUES
((SELECT user_num FROM app.users WHERE user_id='hanriver.dev'), (SELECT id FROM app.rooms WHERE room_name='DM: hanriver.dev ↔ datasage')),
((SELECT user_num FROM app.users WHERE user_id='datasage'),     (SELECT id FROM app.rooms WHERE room_name='DM: hanriver.dev ↔ datasage'))
ON CONFLICT DO NOTHING;

-- DM 3: pixel_ryu, yuna__park
INSERT INTO app.users_rooms (user_num, room_id)
VALUES
((SELECT user_num FROM app.users WHERE user_id='pixel_ryu'),  (SELECT id FROM app.rooms WHERE room_name='DM: pixel_ryu ↔ yuna__park')),
((SELECT user_num FROM app.users WHERE user_id='yuna__park'), (SELECT id FROM app.rooms WHERE room_name='DM: pixel_ryu ↔ yuna__park'))
ON CONFLICT DO NOTHING;

-- DM 4: coffee_cat, cloudwalker (둘 다 탈퇴자)
INSERT INTO app.users_rooms (user_num, room_id)
VALUES
((SELECT user_num FROM app.users WHERE user_id='coffee_cat'),  (SELECT id FROM app.rooms WHERE room_name='DM: coffee_cat ↔ cloudwalker')),
((SELECT user_num FROM app.users WHERE user_id='cloudwalker'), (SELECT id FROM app.rooms WHERE room_name='DM: coffee_cat ↔ cloudwalker'))
ON CONFLICT DO NOTHING;

-- DM 5: jsninja(탈퇴), midnight_owl(활성)
INSERT INTO app.users_rooms (user_num, room_id)
VALUES
((SELECT user_num FROM app.users WHERE user_id='jsninja'),       (SELECT id FROM app.rooms WHERE room_name='DM: jsninja ↔ midnight_owl')),
((SELECT user_num FROM app.users WHERE user_id='midnight_owl'),  (SELECT id FROM app.rooms WHERE room_name='DM: jsninja ↔ midnight_owl'))
ON CONFLICT DO NOTHING;

-- Group: dev-lounge (6명)
INSERT INTO app.users_rooms (user_num, room_id)
SELECT user_num, (SELECT id FROM app.rooms WHERE room_name='Group: dev-lounge')
FROM app.users
WHERE user_id IN ('neofox_77','hanriver.dev','luna_kim','datasage','pixel_ryu','yuna__park')
ON CONFLICT DO NOTHING;

-- Group: game-night (4명: neofox + 두 탈퇴자 + midnight)
INSERT INTO app.users_rooms (user_num, room_id)
SELECT user_num, (SELECT id FROM app.rooms WHERE room_name='Group: game-night')
FROM app.users
WHERE user_id IN ('neofox_77','coffee_cat','cloudwalker','midnight_owl')
ON CONFLICT DO NOTHING;

------------------------------------------------------------
-- 4) Messages: 총 40개 (삭제 2개 = 5%)
--  각 INSERT는 sender_user를 명시적으로 지정 (중복삽입 방지)
------------------------------------------------------------

-- ========== DM: neofox_77 ↔ luna_kim (8개, 삭제 0) ==========
INSERT INTO app.messages (room_id, sender_user, content, message_status, created_at) VALUES
((SELECT id FROM app.rooms WHERE room_name='DM: neofox_77 ↔ luna_kim'), (SELECT user_num FROM app.users WHERE user_id='neofox_77'), '오늘 배포 일정 잡을까요?', 0, NOW() - INTERVAL '180 minute'),
((SELECT id FROM app.rooms WHERE room_name='DM: neofox_77 ↔ luna_kim'), (SELECT user_num FROM app.users WHERE user_id='luna_kim'),  '네, 오후 2시 생각 중이에요.', 0, NOW() - INTERVAL '176 minute'),
((SELECT id FROM app.rooms WHERE room_name='DM: neofox_77 ↔ luna_kim'), (SELECT user_num FROM app.users WHERE user_id='neofox_77'), '체크리스트 공유 부탁!', 0, NOW() - INTERVAL '172 minute'),
((SELECT id FROM app.rooms WHERE room_name='DM: neofox_77 ↔ luna_kim'), (SELECT user_num FROM app.users WHERE user_id='luna_kim'),  '노션에 올렸습니다.', 0, NOW() - INTERVAL '168 minute'),
((SELECT id FROM app.rooms WHERE room_name='DM: neofox_77 ↔ luna_kim'), (SELECT user_num FROM app.users WHERE user_id='neofox_77'), '감사! 바로 확인할게요.', 0, NOW() - INTERVAL '164 minute'),
((SELECT id FROM app.rooms WHERE room_name='DM: neofox_77 ↔ luna_kim'), (SELECT user_num FROM app.users WHERE user_id='luna_kim'),  '테스트 케이스도 추가했어요.', 0, NOW() - INTERVAL '160 minute'),
((SELECT id FROM app.rooms WHERE room_name='DM: neofox_77 ↔ luna_kim'), (SELECT user_num FROM app.users WHERE user_id='neofox_77'), '좋아요, 병합 전 최종 체크만.', 0, NOW() - INTERVAL '156 minute'),
((SELECT id FROM app.rooms WHERE room_name='DM: neofox_77 ↔ luna_kim'), (SELECT user_num FROM app.users WHERE user_id='luna_kim'),  '완료! 👍', 0, NOW() - INTERVAL '152 minute');

-- ========== DM: hanriver.dev ↔ datasage (6개, 삭제 0) ==========
INSERT INTO app.messages (room_id, sender_user, content, message_status, created_at) VALUES
((SELECT id FROM app.rooms WHERE room_name='DM: hanriver.dev ↔ datasage'), (SELECT user_num FROM app.users WHERE user_id='hanriver.dev'), '파이프라인 리팩토링 어떻게 보세요?', 0, NOW() - INTERVAL '150 minute'),
((SELECT id FROM app.rooms WHERE room_name='DM: hanriver.dev ↔ datasage'), (SELECT user_num FROM app.users WHERE user_id='datasage'),   '동의합니다. 주기를 단축하죠.', 0, NOW() - INTERVAL '146 minute'),
((SELECT id FROM app.rooms WHERE room_name='DM: hanriver.dev ↔ datasage'), (SELECT user_num FROM app.users WHERE user_id='hanriver.dev'), '모니터링 메트릭 추가해둘게요.', 0, NOW() - INTERVAL '142 minute'),
((SELECT id FROM app.rooms WHERE room_name='DM: hanriver.dev ↔ datasage'), (SELECT user_num FROM app.users WHERE user_id='datasage'),   '오케이, 대시보드랑 연결해요.', 0, NOW() - INTERVAL '138 minute'),
((SELECT id FROM app.rooms WHERE room_name='DM: hanriver.dev ↔ datasage'), (SELECT user_num FROM app.users WHERE user_id='hanriver.dev'), '금요일에 공유 드리겠습니다.', 0, NOW() - INTERVAL '134 minute'),
((SELECT id FROM app.rooms WHERE room_name='DM: hanriver.dev ↔ datasage'), (SELECT user_num FROM app.users WHERE user_id='datasage'),   '네, 감사합니다.', 0, NOW() - INTERVAL '130 minute');

-- ========== DM: pixel_ryu ↔ yuna__park (6개, 삭제 0) ==========
INSERT INTO app.messages (room_id, sender_user, content, message_status, created_at) VALUES
((SELECT id FROM app.rooms WHERE room_name='DM: pixel_ryu ↔ yuna__park'), (SELECT user_num FROM app.users WHERE user_id='pixel_ryu'),  'UI 시안 어제 버전 확인했어요.', 0, NOW() - INTERVAL '128 minute'),
((SELECT id FROM app.rooms WHERE room_name='DM: pixel_ryu ↔ yuna__park'), (SELECT user_num FROM app.users WHERE user_id='yuna__park'), '피드백 반영해서 색상 수정할게요.', 0, NOW() - INTERVAL '124 minute'),
((SELECT id FROM app.rooms WHERE room_name='DM: pixel_ryu ↔ yuna__park'), (SELECT user_num FROM app.users WHERE user_id='pixel_ryu'),  '다크모드도 넣어봐요.', 0, NOW() - INTERVAL '120 minute'),
((SELECT id FROM app.rooms WHERE room_name='DM: pixel_ryu ↔ yuna__park'), (SELECT user_num FROM app.users WHERE user_id='yuna__park'), '알겠어요, 토글로 제공하죠.', 0, NOW() - INTERVAL '116 minute'),
((SELECT id FROM app.rooms WHERE room_name='DM: pixel_ryu ↔ yuna__park'), (SELECT user_num FROM app.users WHERE user_id='pixel_ryu'),  '탭 전환 애니메이션도 가볍게.', 0, NOW() - INTERVAL '112 minute'),
((SELECT id FROM app.rooms WHERE room_name='DM: pixel_ryu ↔ yuna__park'), (SELECT user_num FROM app.users WHERE user_id='yuna__park'), '넵! 반영해서 다시 드릴게요.', 0, NOW() - INTERVAL '108 minute');

-- ========== DM: coffee_cat ↔ cloudwalker (6개, 삭제 0) ==========
INSERT INTO app.messages (room_id, sender_user, content, message_status, created_at) VALUES
((SELECT id FROM app.rooms WHERE room_name='DM: coffee_cat ↔ cloudwalker'), (SELECT user_num FROM app.users WHERE user_id='coffee_cat'),  '잠시 이슈 정리 중입니다.', 0, NOW() - INTERVAL '106 minute'),
((SELECT id FROM app.rooms WHERE room_name='DM: coffee_cat ↔ cloudwalker'), (SELECT user_num FROM app.users WHERE user_id='cloudwalker'), '네, 공유 기다릴게요.', 0, NOW() - INTERVAL '102 minute'),
((SELECT id FROM app.rooms WHERE room_name='DM: coffee_cat ↔ cloudwalker'), (SELECT user_num FROM app.users WHERE user_id='coffee_cat'),  '로그 확인하니 경고만 남았네요.', 0, NOW() - INTERVAL '98 minute'),
((SELECT id FROM app.rooms WHERE room_name='DM: coffee_cat ↔ cloudwalker'), (SELECT user_num FROM app.users WHERE user_id='cloudwalker'), '좋아요. 배포는 내일로 미루죠.', 0, NOW() - INTERVAL '94 minute'),
((SELECT id FROM app.rooms WHERE room_name='DM: coffee_cat ↔ cloudwalker'), (SELECT user_num FROM app.users WHERE user_id='coffee_cat'),  '오케이, 일정 업데이트하겠습니다.', 0, NOW() - INTERVAL '90 minute'),
((SELECT id FROM app.rooms WHERE room_name='DM: coffee_cat ↔ cloudwalker'), (SELECT user_num FROM app.users WHERE user_id='cloudwalker'), '수고하셨습니다.', 0, NOW() - INTERVAL '86 minute');

-- ========== DM: jsninja ↔ midnight_owl (4개, 삭제 1) ==========
INSERT INTO app.messages (room_id, sender_user, content, message_status, created_at) VALUES
((SELECT id FROM app.rooms WHERE room_name='DM: jsninja ↔ midnight_owl'), (SELECT user_num FROM app.users WHERE user_id='jsninja'),       '오늘 코드리뷰 가능할까요?', 0, NOW() - INTERVAL '84 minute'),
((SELECT id FROM app.rooms WHERE room_name='DM: jsninja ↔ midnight_owl'), (SELECT user_num FROM app.users WHERE user_id='midnight_owl'), '네, 10시에 괜찮아요.', 0, NOW() - INTERVAL '80 minute'),
((SELECT id FROM app.rooms WHERE room_name='DM: jsninja ↔ midnight_owl'), (SELECT user_num FROM app.users WHERE user_id='jsninja'),       '좋아요. PR 링크 보냈어요.', 0, NOW() - INTERVAL '76 minute'),
((SELECT id FROM app.rooms WHERE room_name='DM: jsninja ↔ midnight_owl'), (SELECT user_num FROM app.users WHERE user_id='midnight_owl'), '이 메시지는 삭제되었습니다.', 1, NOW() - INTERVAL '72 minute'); -- 삭제 1/2

-- ========== Group: dev-lounge (6개, 삭제 0) ==========
INSERT INTO app.messages (room_id, sender_user, content, message_status, created_at) VALUES
((SELECT id FROM app.rooms WHERE room_name='Group: dev-lounge'), (SELECT user_num FROM app.users WHERE user_id='neofox_77'),   '금주 스탠드업은 수/금 10시로 확정합니다.', 0, NOW() - INTERVAL '70 minute'),
((SELECT id FROM app.rooms WHERE room_name='Group: dev-lounge'), (SELECT user_num FROM app.users WHERE user_id='hanriver.dev'),'회의록은 노션에 올려둘게요.', 0, NOW() - INTERVAL '66 minute'),
((SELECT id FROM app.rooms WHERE room_name='Group: dev-lounge'), (SELECT user_num FROM app.users WHERE user_id='luna_kim'),    '배포 전 체크리스트 확인 바랍니다.', 0, NOW() - INTERVAL '62 minute'),
((SELECT id FROM app.rooms WHERE room_name='Group: dev-lounge'), (SELECT user_num FROM app.users WHERE user_id='datasage'),    '지표는 Grafana 대시보드에 추가했습니다.', 0, NOW() - INTERVAL '58 minute'),
((SELECT id FROM app.rooms WHERE room_name='Group: dev-lounge'), (SELECT user_num FROM app.users WHERE user_id='pixel_ryu'),   'UI 변경점은 슬랙에도 공유할게요.', 0, NOW() - INTERVAL '54 minute'),
((SELECT id FROM app.rooms WHERE room_name='Group: dev-lounge'), (SELECT user_num FROM app.users WHERE user_id='yuna__park'),  '감사합니다. 모두 확인 부탁드립니다.', 0, NOW() - INTERVAL '50 minute');

-- ========== Group: game-night (10개, 삭제 1) ==========
INSERT INTO app.messages (room_id, sender_user, content, message_status, created_at) VALUES
((SELECT id FROM app.rooms WHERE room_name='Group: game-night'), (SELECT user_num FROM app.users WHERE user_id='neofox_77'),     '오늘 밤 11시에 디스코드 접속 어떠세요?', 0, NOW() - INTERVAL '48 minute'),
((SELECT id FROM app.rooms WHERE room_name='Group: game-night'), (SELECT user_num FROM app.users WHERE user_id='coffee_cat'),    '좋아요. 장비도 점검해둘게요.', 0, NOW() - INTERVAL '46 minute'),
((SELECT id FROM app.rooms WHERE room_name='Group: game-night'), (SELECT user_num FROM app.users WHERE user_id='cloudwalker'),   '음성 채널은 #game-night 사용합시다.', 0, NOW() - INTERVAL '44 minute'),
((SELECT id FROM app.rooms WHERE room_name='Group: game-night'), (SELECT user_num FROM app.users WHERE user_id='midnight_owl'),  '맵은 클래식으로 갈까요?', 0, NOW() - INTERVAL '42 minute'),
((SELECT id FROM app.rooms WHERE room_name='Group: game-night'), (SELECT user_num FROM app.users WHERE user_id='neofox_77'),     '네, 클래식이면 모두 익숙하니까요.', 0, NOW() - INTERVAL '40 minute'),
((SELECT id FROM app.rooms WHERE room_name='Group: game-night'), (SELECT user_num FROM app.users WHERE user_id='coffee_cat'),    '헤드셋 마이크 테스트 완료!', 0, NOW() - INTERVAL '38 minute'),
((SELECT id FROM app.rooms WHERE room_name='Group: game-night'), (SELECT user_num FROM app.users WHERE user_id='cloudwalker'),   '초대 링크는 슬랙에 올렸어요.', 0, NOW() - INTERVAL '36 minute'),
((SELECT id FROM app.rooms WHERE room_name='Group: game-night'), (SELECT user_num FROM app.users WHERE user_id='midnight_owl'),  '오케이, 11시에 뵈어요.', 0, NOW() - INTERVAL '34 minute'),
((SELECT id FROM app.rooms WHERE room_name='Group: game-night'), (SELECT user_num FROM app.users WHERE user_id='neofox_77'),     '이 메시지는 운영자에 의해 삭제되었습니다.', 1, NOW() - INTERVAL '32 minute'), -- 삭제 2/2 (총 40 중 2개 = 5%)
((SELECT id FROM app.rooms WHERE room_name='Group: game-night'), (SELECT user_num FROM app.users WHERE user_id='coffee_cat'),    '확인했습니다. 그럼 준비 완료!', 0, NOW() - INTERVAL '30 minute');

------------------------------------------------------------
-- 5) 각 방의 last_message_at 갱신
------------------------------------------------------------
UPDATE app.rooms r
SET last_message_at = sub.max_created
FROM (
  SELECT room_id, MAX(created_at) AS max_created
  FROM app.messages
  GROUP BY room_id
) sub
WHERE r.id = sub.room_id;