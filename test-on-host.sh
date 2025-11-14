#!/bin/bash

# 다른 호스트(깨끗한 우분투)에서 테스트하기 위한 스크립트
# 이 스크립트는 테스트할 시스템에서 실행합니다.

set -e

echo "=== 정적 빌드 실행 파일 호스트 테스트 ==="

# 실행 파일이 있는지 확인
if [ ! -f "workspace-controller" ]; then
    echo "오류: workspace-controller 파일이 없습니다."
    echo "빌드된 파일을 이 시스템으로 복사하세요."
    exit 1
fi

echo "1. 시스템 정보 확인..."
echo "OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
echo "Kernel: $(uname -r)"
echo ""

echo "2. 실행 파일 확인..."
file workspace-controller
echo ""

echo "3. 의존성 확인..."
if ldd workspace-controller 2>&1 | grep -q "not a dynamic executable"; then
    echo "✓ 정적 실행 파일입니다 (의존성 없음)"
elif ldd workspace-controller 2>&1 | grep -q "statically linked"; then
    echo "✓ 정적으로 링크되었습니다"
else
    echo "경고: 일부 동적 의존성이 있을 수 있습니다."
    ldd workspace-controller
fi
echo ""

echo "4. 실행 파일 크기..."
ls -lh workspace-controller
echo ""

echo "5. 실행 권한 확인..."
chmod +x workspace-controller
echo ""

echo "6. 실행 테스트 (5초 후 자동 종료)..."
timeout 5 ./workspace-controller 2>&1 || true

echo ""
echo "=== 테스트 완료 ==="
echo "실행 파일이 정상적으로 작동하면 정적 빌드가 성공한 것입니다."

