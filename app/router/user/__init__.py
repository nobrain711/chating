####################################
# __init__.py for user router module
# 유저 관련 라우터들을 묶어주는 파일입니다.
# user관련 기능을 담당하는 서브 라우터들을 포함합니다.
####################################

# API Router 모듈 import 및 생성
from fastapi import APIRouter

api_router = APIRouter(prefix="/user", tags=["user"])

# 서브 라우터를 import
from app.router.user import signup, signin

# 서브 라우터 등록
api_router.include_router(signup.router)
api_router.include_router(signin.router)