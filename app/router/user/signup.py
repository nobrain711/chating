################################
# signup.py for user router module
# 회원가입 관련 라우터입니다.
## 회원가입 기능 구현
## 현재 단계에서는 in-memory store를 사용하여 간단한 회원가입 기능만 구현
### 추후 일정 (Phase 별로 표기)
#### Phase 2 구현 시
##### - 데이터 베이스 연동 시 in-memory store 부분 교체
##### - user_id 중복 체크 로직 강화 
###### * 현재는 단순히 in-memory store에서 존재 여부만 체크
###### * 추후 DB 연동 시 더 정교한 중복 체크 로직 도입
##### - 비밀번호 해싱 로직 강화
###### * 현재는 단순 해싱 함수 사용
###### * 추후 더 안전한 해싱 알고리즘 및 솔트 적용 (현재 알고리즘 교체 가능성 있음)
#####  - SQL Injection 방어 로직 추가
#### Phase 3 구현 시
##### - 이메일 인증 기능 추가
##### - 회원가입 완료 후 환영 이메일 발송 기능 추가
## logic:
## 01 in-memory store에 user_id 중복 체크
## 01-1 중복 시 401 에러 반환
## 02 비밀번호 해싱
## 03 in-memory store에 유저 정보 저장
## 04 성공 메시지 반환
################################

# 필요한 라이브러리 import
from fastapi import APIRouter, HTTPException

from app import router

# 필요한 스카마 import
from ...schemas.user import UserCreate

# 필요한 스토어 import
from ...core.store import users

# 필요한 시큐리티 기능 import
from ...core.security import HashPassword

# 라우터 생성
router = APIRouter()

# 회원가입
@router.post("/signup")
def signup(payload: UserCreate):
  """
    회원가입 엔드포인트

    input:
      - user (UserCreate): 회원가입에 필요한 유저 정보 스키마
        * user_id (str): 유저 아이디
        * user_name (str): 유저 이름
        * password (str): 유저 비밀번호 (해싱 전 값)  
  
    output:
      - UserBase: 생성된 유저의 기본 정보 스키마 반환      
  """
  # user_id 중복 체크
  if payload.user_id in users:
    raise HTTPException(status_code=401, detail="User ID가 이미 존재합니다.")
  
  # 비밀번호 해싱
  hashed_password = HashPassword(payload.password)
  
  # 유저 정보 저장 (in-memory store 사용)
  users[payload.user_id] = {
    "user_name": payload.user_name,
    "user_id": payload.user_id,
    "password": hashed_password 
  }

  raise HTTPException(status_code=200, detail=f"{payload.user_name}님의 회원가입이 성공적으로 완료되었습니다. ID: {payload.user_id}")