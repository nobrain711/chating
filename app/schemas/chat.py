####################################
# schemas/chat.py
# 채팅 관련 스키마 정의
## 현재 정의된 스키마:
### MessageIn: 사용자로부터 입력받는 메시지 스키마
### MessageOut: 봇이 응답하는 메시지 스키마
## 추후 정의 예정된 스키마:
### 1:1 채팅 기록 관련 스키마
### 그룹 채팅 관련 스키마
## 추후 수정 예정:
### MeessageIn: timestamp 필드 추가 예정
### MessageOut: 미정
####################################

# 필요한 라이브러리 import
from pydantic import BaseModel, Field
from typing import Optional

# MessageIn 모델 정의
class MessageIn(BaseModel):
  '''
    사용자로부터 입력받는 메시지 모델
      session_id: str - 세션 ID (선택적)
      message: str - 사용자 메시지 내용
  '''
  session_id: Optional[str] = Field(default=None)
  message: str
  
# MssageOut 모델 정의
class MessageOut(BaseModel):
  '''
    봇이 응답하는 메시지 모델
    session_id: str - 세션 ID
    reply: str - 봇의 응답 메시지
    history_length: int - 대화 기록의 길이
  '''
  session_id: str
  reply: str
  history_length: int