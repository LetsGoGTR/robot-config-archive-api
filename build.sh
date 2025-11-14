#!/bin/bash

# 정적 빌드 스크립트
# 인터넷이 없는 환경에서도 실행 가능한 단일 실행 파일을 생성합니다.

set -e

echo "=== robot-config-archive-api 정적 빌드 시작 ==="

# 빌드 디렉토리 생성
BUILD_DIR="build"
if [ -d "$BUILD_DIR" ]; then
    echo "기존 빌드 디렉토리 삭제 중..."
    rm -rf "$BUILD_DIR"
fi

mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# CMake 설정 (정적 빌드)
echo "CMake 설정 중..."
cmake .. -DCMAKE_BUILD_TYPE=Release

# 빌드 실행
echo "빌드 중..."
make -j$(nproc)

# 빌드 결과 확인
if [ -f "workspace-controller" ]; then
    echo ""
    echo "=== 빌드 성공! ==="
    echo "실행 파일: $(pwd)/workspace-controller"
    echo "파일 크기: $(du -h workspace-controller | cut -f1)"
    echo ""
    echo "의존성 확인:"
    ldd workspace-controller 2>/dev/null || echo "정적 빌드 완료 (의존성 없음)"
else
    echo "빌드 실패: workspace-controller 파일이 생성되지 않았습니다."
    exit 1
fi

