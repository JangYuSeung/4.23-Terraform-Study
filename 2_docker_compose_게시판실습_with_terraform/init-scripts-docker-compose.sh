#!/bin/bash
exec > >(tee /var/log/user-data.log | logger -t user-data) 2>&1
set -e

FLAG_FILE="/var/log/first-boot-done"

if [ -f "$FLAG_FILE" ]; then
    echo "이미 초기 설정이 완료되었습니다. 스크립트를 종료합니다."
    exit 0
fi

echo "[1/8] 패키지 업데이트 및 Docker 설치"
dnf update -y
dnf install -y docker

echo "[2/8] Docker Compose 플러그인 설치"
# Amazon Linux 2023 repo에 docker-compose-plugin 패키지가 없으므로 바이너리 직접 설치
mkdir -p /usr/local/lib/docker/cli-plugins
curl -fsSL "https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64" \
    -o /usr/local/lib/docker/cli-plugins/docker-compose
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
docker compose version

echo "[3/8] Docker 서비스 시작 및 활성화"
systemctl enable --now docker

echo "[4/8] 작업 디렉토리 생성"
mkdir -p /app

echo "[5/8] GitHub에서 docker-compose.yaml 다운로드"
curl -fsSL -o /app/docker-compose.yaml \
    https://raw.githubusercontent.com/JangYuSeung/docker-network/main/ex-board/docker-compose-gcp.yaml
echo "다운로드 완료: $(wc -l < /app/docker-compose.yaml) lines"

echo "[6/8] .env 파일 생성"
cat > /app/.env << 'EOF'
MYSQL_ROOT_PASSWORD=ian1234!
MYSQL_DATABASE=iandb
MYSQL_USER=ian
MYSQL_PASSWORD=ian1234!
MYSQL_TZ=Asia/Seoul
DB_HOST=mysql-primary-container
DB_USER=ian
DB_PASSWORD=ian1234!
DB_NAME=iandb
EOF

echo "[7/8] docker compose 실행"
docker compose -f /app/docker-compose.yaml --env-file /app/.env up -d

echo "[8/8] 완료 플래그 생성"
touch $FLAG_FILE
echo "초기 설정 완료"
