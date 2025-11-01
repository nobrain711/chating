####################################
# security.py for core security module
# 애플리케이션의 보안 관련 기능들을 정의하는 파일입니다.
# 현재 시점에서는 유저의 비밀번호 해싱 및 검증 기능을 포함합니다.
## 현재 정의된 기능:
### HashPassword: 비밀번호 해싱 함수
### VerifyPassword: 비밀번호 검증 함수
## 추후 추가 예정된 기능:
### 비밀번호 재설정
## 미정 사항 (JWT or Session중에 결정되면 추가 예정):
### jwt 토큰 생성 및 검증 기능 추가 여부
### session 관리 기능 추가 여부
####################################

# 필요한 라이브러리 import
from passlib.context import CryptContext

# 비밀번호 해싱을 위한 CryptContext 설정
## bcrypt 알고리즘 사용
## deprecated 옵션은 이전 알고리즘 사용을 방지
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def HashPassword(password: str) -> str:
    """
      주어진 비밀번호를 해싱하여 반환합니다.

      input:
        - password (str): 해싱할 비밀번호
      
      logic:
        - CryptContext의 hash 메서드를 사용하여 비밀번호 해싱
        
      output:
        - str: 해싱된 비밀번호
    """
    return pwd_context.hash(password)

def VerifyPassword(plain_password: str, hashed_password: str) -> bool:
    """
      주어진 평문 비밀번호와 해싱된 비밀번호를 비교하여 일치 여부를 반환합니다.

      input:
        - plain_password (str): 평문 비밀번호
        - hashed_password (str): 해싱된 비밀번호
      
      logic:
        - CryptContext의 verify 메서드를 사용하여 비밀번호 검증
        
      output:
        - bool: 비밀번호 일치 여부
    """
    return pwd_context.verify(plain_password, hashed_password)