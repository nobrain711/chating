################################
# signin.py for user router module
# 유저 로그인 관련 라우터입니다.
## 로그인 기능 구현
## 현재 단계에서는 in-memory store를 사용하여 간단한 로그인 기능만 구현
### 추후 예정 (Phase 별로 표기)
#### Phase 2 구현 시
##### - 입력값 정규식으로 검증 로직 추가
##### - 데이터 베이스 연동 시 in-memory store 부분 교체
##### - user_id 존재 여부 체크 로직 강화
####### * 현재는 단순히 in-memory store에서 존재 여부만 체크
####### * 추후 DB 연동 시 더 정교한 체크 로직 도입
##### - pw 검증 로직 강화
####### * 현재는 단순 해싱 함수 사용
####### * 추후 더 안전한 해싱 알고리즘 및 솔트 적용 (현재 알고리즘 교체 가능성 있음)
##### - SQL Injection 방어 로직 추가
##### - 세션 관리 또는 JWT 토큰 발급 기능 추가 (현재까지는 세션 or JWT 선택 미정) 
#### Phase 3 구현 시
##### - email 인증 로그인 기능 추가
## logic:
## 01 in-memory store에 user_id 존재 여부 체크
## 01-1 존재 하지 않을 시 401 에러 반환
## 02 비밀번호 해싱 후 비교
## 02-1 실패 시 401 에러 반환
## 03 성공 시 200 메시지 반환
################################

# 필요한 라이브러리 import
from fastapi import APIRouter, HTTPException

# 필요한 스키마 import
from app.schemas.user import UserLogin

# store와 해싱 함수 import
from app.core.security import VerifyPassword
from app.core.store import users

# 라우터 생성
router = APIRouter(prefix="/signin", tags=["user"])

# 로그인
@router.post("")
def signin(payload: UserLogin):
  """
    유저 로그인 엔드포인트

    input:
      - user (UserLogin): 로그인에 필요한 유저 정보 스키마
        * user_id (str): 유저 아이디
        * password (str): 유저 비밀번호 (해싱 전 값)
    
    output:
      - HTTPException: 로그인 성공 또는 실패 메시지 반환
        * 200 OK: 로그인 성공
        * 401 Unauthorized: 로그인 실패
    """
  # user_id 존재 여부 체크
  if payload.user_id not in users:
    raise HTTPException(status_code=401, detail="ID가 존재 하지 않습니다.")

  # 유저 정보 가져오기
  user = users[payload.user_id]
  
  # 비밀번호 검증
  if not VerifyPassword(payload.password, user["password"]):
    raise HTTPException(status_code=401, detail="비밀번호가 일치하지 않습니다.")
  
  # 로그인 성공 메시지 반환
  raise HTTPException(status_code=200, detail=f"로그인에 성공하였습니다. 환영합니다, {user['user_name']}!")
  