####################################
# user.py for user schema module
# 유저 관련 데이터 스키마 정의 파일입니다.
# 비밀번호의 경우 core/security.py의 해싱 기능을 사용합니다.
## 현재 정의된 스키마:
### UserBase: 유저의 기본 정보 스키마
### UserCreate: 유저 생성 시 사용하는 스키마
### UserLogin: 유저 로그인 시 사용하는 스키마
## 추후 정의 예정된 스키마:
### UserLogout: 유저 로그아웃 시 사용하는 스키마
### UserUpdate: 유저 정보 업데이트 시 사용하는 스키마
## 추후 수정 예정:
### 유저 정보에 이메일, 프로필 사진 등 추가 정보 포함 예정
####################################

# 필요한 라이브러리 import
from pydantic import BaseModel, Field

# 기본 유저 스키마 정의
class UserBase(BaseModel):
  """
    유저의 기본 정보를 담는 스키마
    현 시점에서는 user_id와 user_name만 포함합니다.
    추후에 정보 추가 예정

    attributes:
      - user_id (str) not null: 유저 아이디
      - user_name (str) not null: 유저 이름
  """
  user_id: str = Field(..., min_length=3, max_length=50, description="유저 아이디")
  user_name: str = Field(..., min_length=2, max_length=100, description="유저 이름")
  
  
# 유저 생성 스키마 정의
class UserCreate(UserBase):
  """
    유저 생성 시 사용하는 스키마
    UsrerBase를 상속받아 user_id와 user_name을 포함하며,
    추가로 비밀번호 해싱 값을 포함합니다.
    
    input attributes:
      - password (str): 유저 비밀번호 해싱 값
  """
  password: str = Field(..., min_length=6, max_length=100, description="유저 비밀번호 해싱 값")
  
# 유저 로그인 스키마 정의
class UserLogin(BaseModel):
  """
    유저 로그인 시 사용하는 스키마
    BaseModel를 이용해서 user_id와 비밀번호 해싱 값을 포함합니다.
    password의 보안을 위해서 UserBase를 상속받지 않습니다.
    
    input attributes:
      - user_id (str): 유저 아이디
      - password (str): 유저 비밀번호 해싱 값
  """
  user_id: str = Field(..., min_length=3, max_length=50, description="유저 아이디")
  password: str = Field(..., min_length=6, max_length=100, description="유저 비밀번호 해싱 값")


# 유저 로그아웃 스키마 정의
## 현재는 미구현