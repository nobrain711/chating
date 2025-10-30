# app/main.py

# 필요한 라이브러리 임포트
from fastapi import FastAPI
from pydantic import BaseModel
from typing import Dict,List

# FastAPI 애플리케이션 인스턴스 생성
app = FastAPI()

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

# message_in 모델 정의
class message_in(BaseModel):
  '''
    사용자로부터 입력받는 메시지 모델
      session_id: str - 세션 ID
      message: str - 사용자 메시지 내용
  '''
  session_id: str
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
  
@app.post("/chat", response_model=message_out)
def chat(payload: message_in):
  '''
    /chat 엔드포인트
    사용자로부터 메시지를 받아 대화 기록에 추가하고, 봇의 응답을 생성하여 반환합니다.
    
    매개변수:
      payload (message_in): 사용자로부터 입력받은 메시지 모델
  '''
  # 기존 대화 기록 가져오기
  session_id = conversations.get(payload.session_id, [])
  
  # 초기 동작 확인용
  # 인사
  user_message = payload.message.strip().lower()
  
  # 봇 응답 생성 (간단한 에코 응답)
  ## 간단한 인사 응답 로직 추가
  if user_message in ["hi", "hello", "안녕", "안녕하세요"]: # 인사
    bot_reply = "안녕하세요! 무엇을 도와줄까요?"
  elif user_message in ["bye", "goodbye", "잘가", "안녕히 가세요"]: # 작별 인사
    bot_reply = "대화가 종료됩니다. 좋은 하루 되세요!"
  else: # 그 외에는 에코 응답
    bot_reply = f"당신이 말한 내용(echo): '{payload.message}'"
  
  # 대화 기록에 사용자 메시지와 봇 응답 추가
  session_id.append({"role": "user", "content": user_message}) # 사용자 메시지 추가
  session_id.append({"role": "bot", "content": bot_reply}) # 봇 응답 추가
  
  # 대화 기록 업데이트
  return message_out(
    session_id=payload.session_id,
    reply=bot_reply,
    history_length=len(session_id)
  )
