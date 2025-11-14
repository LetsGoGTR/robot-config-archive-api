#!/bin/bash

# 정적 빌드된 실행 파일을 깨끗한 우분투 환경에서 테스트하는 스크립트

set -e

echo "=== 정적 빌드 실행 파일 테스트 ==="

# 빌드가 되어 있는지 확인
if [ ! -f "build/workspace-controller" ]; then
    echo "오류: 빌드된 실행 파일이 없습니다. 먼저 ./build.sh를 실행하세요."
    exit 1
fi

echo "1. 실행 파일 확인..."
file build/workspace-controller
echo ""

echo "2. 의존성 확인..."
ldd build/workspace-controller 2>&1 || echo "정적 실행 파일 (의존성 없음)"
echo ""

echo "3. 깨끗한 우분투 컨테이너에서 테스트..."

# Docker가 설치되어 있는지 확인
if ! command -v docker &> /dev/null; then
    echo "경고: Docker가 설치되어 있지 않습니다."
    echo "다른 방법으로 테스트하려면:"
    echo "  1. Docker 설치: sudo apt-get install docker.io"
    echo "  2. 또는 다른 우분투 시스템으로 파일을 복사해서 테스트"
    exit 1
fi

# Docker 이미지 빌드
echo "Docker 이미지 빌드 중..."
docker build -f Dockerfile.test -t workspace-controller-test:latest .

# 네트워크 없이 실행 테스트
echo ""
echo "4. 네트워크 없이 실행 테스트..."
echo "   (실행 파일이 시작되면 Ctrl+C로 종료하세요)"
echo ""

# --network=none 옵션으로 네트워크 없이 실행
timeout 5 docker run --rm --network=none workspace-controller-test:latest 2>&1 || true

echo ""
echo "=== 테스트 완료 ==="
echo "실행 파일이 정상적으로 작동하면 정적 빌드가 성공한 것입니다."

