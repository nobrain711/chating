####################################
# app/routers/chat.py
# chat 기능 정의
# 현재는 단순 에코 챗봇 기능 구현
## 현재 기능:
### chat 엔드포인트: 사용자 메시지 수신 및 응답 반환
## 추가 예정 기능:
### 1:1 채팅 기록 저장 및 불러오기
### 그룹 채팅 기록 저장 및 불러오기
### 추후 수정 예정:
#### 현재는 단순한 CURD 기능에서 WEBSOCKET 기반으로 변경 예정
#### in-memory 저장소에서 데이터베이스 연동으로 변경 예정
#### 챗봇 응답 고려 기능 개선 예정
#### * 추후에 다른 프로젝트에서 개발한 챗봇 모델 연동 예정
## 미정 사항:
### 챗봇의 구체적인 동작 방식 및 응답 생성 로직
### 기능별 파일 분리 여부
### redis 등 외부 캐시 서버 연동 여부
####################################

# 필요한 라이브러리 import
from fastapi import APIRouter

# 스키마 import
from app.schemas.chat import MessageIn, MessageOut

# core 모듈에서 대화 내용 저장소 import
from app.core.store import conversations

# APIRouter 인스턴스 생성
router = APIRouter(prefix="", tags=["chat"])

# Get /chat 엔드포인트 정의
@router.post("/chat", response_model=MessageOut)
def chat(payload: MessageIn):
  '''
    chat 엔드포인트
    사용자로부터 메시지를 받아 대화 기록에 추가하고, 봇의 응답을 생성하여 반환합니다.
    
    매개변수:
      payload (MessageIn): 사용자로부터 입력받은 메시지 모델
  '''
  # 기존 대화 기록 가져오기
  session = conversations.get(payload.session_id, [])
  
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
  session.append({"role": "user", "content": user_message}) # 사용자 메시지 추가
  session.append({"role": "bot", "content": bot_reply}) # 봇 응답 추가

  # 대화 기록 업데이트
  return MessageOut(
    session_id=payload.session_id,
    reply=bot_reply,
    history_length=len(session)
  )