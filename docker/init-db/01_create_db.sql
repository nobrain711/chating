-- container 최초 초기화(initdb) 시 자동으로 실행
-- template0 기반으로 ko_KR.UTF-8 로캘을 명시해 dev_db생성

DO $$
BEGIN
  IF NOT EXISTS (
SELECT
	1
FROM
	pg_database
WHERE
	datname = 'dev_db') THEN
    EXECUTE $q$
      CREATE DATABASE dev_db
      WITH ENCODING 'UTF8'
            LC_COLLATE 'ko_KR.UTF-8'
            LC_CTYPE 'ko_KR.UTF-8'
            TEMPLATE template0
            OWNER master
    $q$;
END IF;

END$$;

-- 가독성 기본값
ALTER DATABASE  dev_db  SET client_encoding = 'UTF-8';
ALTER DATABASE  dev_db  SET timezone='Asia/Seoul';