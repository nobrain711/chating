# app/routers/health.py
# 동작 확인용 헬스체크 라우터

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
