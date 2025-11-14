#!/bin/bash

# 정적 빌드를 위한 의존성 라이브러리 설치 스크립트

set -e

echo "=== 정적 빌드를 위한 의존성 라이브러리 설치 ==="

# 필요한 개발 패키지 설치
PACKAGES=(
    "build-essential"
    "cmake"
    "pkg-config"
    "libarchive-dev"
    "zlib1g-dev"
    "libbz2-dev"
    "liblzma-dev"
    "libzstd-dev"
    "liblz4-dev"
    "nettle-dev"
    "libxml2-dev"
    "libacl1-dev"
    "libicu-dev"
)

echo "다음 패키지들을 설치합니다:"
for pkg in "${PACKAGES[@]}"; do
    echo "  - $pkg"
done

echo ""
read -p "계속하시겠습니까? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "취소되었습니다."
    exit 1
fi

sudo apt-get update
sudo apt-get install -y "${PACKAGES[@]}"

echo ""
echo "=== 설치 완료 ==="
echo "이제 ./build.sh를 실행하여 정적 빌드를 수행할 수 있습니다."

