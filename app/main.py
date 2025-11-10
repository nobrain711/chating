####################################
# app/main.py
# FastAPI 애플리케이션 설정
## 기능은 routers 디렉토리에서 관리
## main.py에서는 FastAPI 인스턴스 생성 및 라우터 등록만 수행
## 현재 지원하는 라우터:
### 헬스체크, 채팅, 유저
####################################

# 필요한 라이브러리 import
from fastapi import FastAPI

# 라우터 import
from app.router.health import router as health_router # 헬스체크 라우터
from app.router.chat import router as chat_router # 채팅 라우터
from app.router.user import api_router as user_router # 유저 라우터

# FastAPI 애플리케이션 인스턴스 생성
app = FastAPI()

# 라우터 등록
app.include_router(health_router) # 헬스체크 라우터
app.include_router(chat_router) # 채팅 라우터
app.include_router(user_router) # 유저 라우터