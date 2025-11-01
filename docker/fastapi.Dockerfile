FROM python:3.12-slim

# 작업 디렉토리 설정
WORKDIR /app

# 의존성 설치
# requirements.txt 파일을 컨테이너에 복사
COPY requirements.txt .

# container OS UPDATE & 의존성 패키지 설치 & chache 및 불필요한 파일 삭제
RUN apt-get update && apt-get install -y --no-install-recommends build-essential \
    && pip install --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 애플리케이션 코드 복사
COPY app ./app

# 포트 노출
EXPOSE 8000