-- 스키마 생성
CREATE SCHEMA IF NOT EXISTS app AUTHORIZATION master;
SET search_path = app, public;

-- app 스키마 우선 지정
ALTER ROLE  master  SET search_path = app, public;