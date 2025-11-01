####################################
# store.py for core store module
# 현 프로젝트에서 사용하는 in-memory 데이터 저장소
# 추후에 데이터베이스로 교체 예정
## 현재 저장 요소:
### conversations: 대화 기록 저장
### users: 유저 정보 저장
## 추후 수정 예정:
### 데이터베이스 연동 시 in-memory store 부분 교체
### 저장 구조 변경 가능성 있음
####################################

# 필요 라이브러리 import
from typing import List, Dict

# in-memory data store
'''
  대화 내용을 저장할 딕셔너리 구조의 변수
    대화 내용은 사용자 ID를 index로 하고 메시지 목록을 값을 가집니다.
    각 메시지는 딕셔너리 형태로 저장됩니다.
    예시:
      {"user1": [{"role": "user", "content": "Hello"}, {"role": "bot", "content": "Hi there!"}]}  
'''
conversations: Dict[str, List[Dict[str, str]]] = {}


# in-memory data store
'''
  유저 정보를 저장할 딕셔너리 구조의 변수
    유저 정보는 사용자의 user_id를 index로 하고 유저 정보를 값을 가집니다
    각 유저 정보는 문자열로 저장됩니다
     추후 데이터베이스 연동시 교체될 예정입니다.
     그에 따라 index 구조도 변경될 수 있습니다.
    예시: {"user1": {"user_name": "nobrain711", "user_id": "user1", "password": "hashed_password"}}
'''
users: Dict[str, Dict[str, str]] = {}