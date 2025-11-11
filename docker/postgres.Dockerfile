# docker image 지정
# postgres 16.10 버전의 가벼운 버전
FROM postgres:16.10-bookworm

# 한국어 로캘 생성
RUN apt-get update && apt-get install -y --no-install-recommends locales tzdata \
  && sed -i 's/# ko_KR.UTF-8 UTF-8/ko_KR.UTF-8 UTF-8/' /etc/locale.gen \
  && locale-gen \
  && rm -rf /var/lib/apt/lists/*

# 컨테이너 기본 환경
ENV LANG=ko_KR.UTF-8 \
    LANGUAGE=ko_KR:ko:en \
    LC_ALL=ko_KR.UTF-8 \
    TZ=Asia/Seoul