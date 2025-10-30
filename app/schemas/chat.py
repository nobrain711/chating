# schemas/chat.py
# 채팅 관련 스키마 정의

# 필요한 라이브러리 import
from pydantic import BaseModel, Field
from typing import Optional

# message_in 모델 정의
class message_in(BaseModel):
  '''
    사용자로부터 입력받는 메시지 모델
      session_id: str - 세션 ID (선택적)
      message: str - 사용자 메시지 내용
  '''
  session_id: Optional[str] = Field(default=None)
  message: str
  
# message_out 모델 정의
class message_out(BaseModel):
  '''
    봇이 응답하는 메시지 모델
    session_id: str - 세션 ID
    reply: str - 봇의 응답 메시지
    history_length: int - 대화 기록의 길이
  '''
  session_id: str
  reply: str
  history_length: int