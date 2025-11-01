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
from fastapi import APIRouter

# APIRouter 인스턴스 생성
router = APIRouter()

@router.get("/health")
def health_check():
  '''
    /health 엔드포인트
    애플리케이션의 상태를 확인합니다.
    
    반환값:
      dict: 상태 메시지
  '''
  return {"status": "healthy"}
