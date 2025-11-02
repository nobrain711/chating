####################################
# engin.py for db module
# 데이터베이스 엔진 및 세션 관리를 위한 모듈
## 구현 기능:
### get_db_session: 데이터베이스 세션 생성 및 반환
## 추후 구현 기능:
### session_scope: 데이터베이스 세션 범위 관리
####################################

# 필요한 라이브러리 import
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

# DB URL
# 동기 드라이버(psycopg2)를 사용하도록 접속 문자열 수정
DATATBASE_URL = "postgresql+psycopg2://master:dev_password@db:5432/dev_db"

# DB Engin
## 동기 전용 엔지
engine = create_engine(
  url=DATATBASE_URL,  # DB 주소
  pool_pre_ping=True, # 자동으로 재연결
  future=True         # SQLAlchemy 2.X 스타일 적용
)

# DB Session factory
## 동기 전용 세션
SessionLocal = sessionmaker(
  bind=engine,
  autocommit=False,
  autoflush=False,
  future=True
)

def get_sync_db():
  """
    FastAPI 요청마다 독립적으로 동기 DB 세션을 제공
    
    Logic:
      - 요청이 들어온 Query를 정상적으로 수행되면 커밋
      - 요청이 들어온 Query를 비정상적으로 수행되면 이전으로 롤백
  """
  # 요청 처리를 위한 DB Session
  db = SessionLocal()
  
  try:
    # 트랜잭션: 요청 처리 성공 시 커밋 예외 발생 시 except 블록에서 롤백
    yield db
    db.commit()
    
  except Exception:
    db.rollback()
    raise
  
  finally:
    db.close()
    
  
  
