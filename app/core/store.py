# store.py for app/core
# 채팅 기록을 저장하고 불러오는 기능을 담당합니다.

# 필요 라이브러리 import
from typing import List, Dict

# in-memory data store
'''
  대화 내용을 저장할 딕셔너리 구조의 변수
    conversations: Dict[str, List[Dict[str, str]]] = {}
    대화 내용은 사용자 ID를 index로 하고 메시지 목록을 값을 가집니다.
    각 메시지는 딕셔너리 형태로 저장됩니다.
    예시:
      {"user1": [{"role": "user", "content": "Hello"}, {"role": "bot", "content": "Hi there!"}]}  
'''
conversations: Dict[str, List[Dict[str, str]]] = {}
