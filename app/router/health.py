####################################
# app/routers/health.py
# 동작 확인용 헬스체크 라우터
## 현재 기능:
### 단순 서버 상태 확인용
## 추가 예정 기능:
### Database 연결 상태 확인
### 서버 부하 상태 확인
### 서버 응답 시간 측정
### 기타 모니터링 기능
### 추후 수정 예정:
#### 현재 단순 응답에서 JSON 형태로 상세 정보 제공 예정
##### 예: {"status": "healthy", "db_connection": "ok", "load": "normal"}
##### 상세 정보는 추후 모니터링 요구사항에 따라 변경될 수 있음
####################################

# 필요한 라이브러리 import
## --- fastapi ---
from fastapi import APIRouter, Depends, HTTPException
from fastapi.responses import JSONResponse

## --- SQL ---
from sqlalchemy import text
from sqlalchemy.orm import Session
from sqlalchemy.exc import OperationalError, TimeoutError, DBAPIError

# DB 세션 가져오기
from app.db.engin import get_sync_db

# APIRouter 인스턴스 생성
router = APIRouter(prefix="/health", tags=["health"])

@router.get("/")
def health_check(db: Session = Depends(get_sync_db)):
  '''
    health 엔드포인트
    애플리케이션의 상태를 확인합니다.
    
    반환값:
      dict: 
        "status": 현재 서버 상태
        "database": 현재 DB 연결 상태
  '''
  db_status = "ok"
  
  try:
    db.execute((text("SELECT 1")))
  
  except Exception:
    db_status = "not ok"
  
  return JSONResponse(
    status_code=200,
    content={
      "status": "healthy",
      "database":db_status
      })

@router.get("/db")
def db_health_check(db: Session = Depends(get_sync_db)):
  '''
    health/db 엔드 포인트
    fastapi와 postgresql 데이터베이스 연결 상태를 확인합니다.
    
    반환값:
      dict: 데이터베이스 연결 상태 메시지
        - status_code: 연결 상태
          * 200: 정상
          * 503: 서비스 이용 불가
          * 504: 게이트웨이 타임아웃
          * 520: 원인 불명 오류
        - message: 연결 상태 메시지
          * 정상: {테스트 시간}시점에 DB연결이 확인 되었습니다.
          * 오류: 에러 메시지
  '''
  try:
    # 현재 시간 조회
    now = db.execute(text("SELECT NOW();")).scalar()
    
    # 값 반환
    return JSONResponse(
      status_code=200,
      content={
        "status_code":200,
        "message": f"{now} 시점에 DB 연결이 확인 되었습니다."
      }
    )
  
  except DBAPIError as e:
    # 드라이버(DB API) 계층 오류
    raise HTTPException(status_code=500, detail=f"다음과 같은 이유로 데이터베이스에서 오류가 발생했습니다.|{e}")
    
  except OperationalError as e:
    # DB 접근 불가 (접속 거부, 인증 실패, 서버 다운 등)
    raise HTTPException(status_code=503, detail=f"다음과 같은 이유로 접근이 불가 합니다.|{e}")
  
  except TimeoutError as e:
    # Query Timeout
    raise HTTPException(status_code=504, detail=f"다음과 같은 이유로 Query가 작동이 안됩니다.|{e}")
  
  except Exception as e:
    # 그 외 알 수 없는 이유
    raise HTTPException(status_code=520, detail=f"다음과 같은 이유로 오류가 발생했습니다.|{e}")
  
