# 정적 빌드 테스트 가이드

깨끗한 우분투 환경에서 정적 빌드된 실행 파일을 테스트하는 방법입니다.

## 방법 1: Docker를 사용한 테스트 (권장)

### 준비
```bash
# Docker 설치 (없는 경우)
sudo apt-get install docker.io
sudo usermod -aG docker $USER  # 재로그인 필요
```

### 테스트 실행
```bash
cd /home/ssafy/robot-config-archive-api

# 정적 빌드 먼저 수행
./build.sh

# 깨끗한 우분투 환경에서 테스트
chmod +x test-static.sh
./test-static.sh
```

이 방법은 네트워크 없이도 실행 파일이 작동하는지 확인할 수 있습니다.

## 방법 2: 다른 호스트로 파일 전송 후 테스트

### 1단계: 빌드된 파일 준비
```bash
cd /home/ssafy/robot-config-archive-api
./build.sh

# 파일 압축 (전송 편의를 위해)
tar czf workspace-controller-static.tar.gz build/workspace-controller
```

### 2단계: 깨끗한 우분투 시스템으로 전송
```bash
# SCP를 사용한 예시
scp workspace-controller-static.tar.gz user@clean-ubuntu-host:/tmp/

# 또는 USB 드라이브, 네트워크 공유 등을 사용
```

### 3단계: 타겟 시스템에서 테스트
```bash
# 타겟 시스템에서
cd /tmp
tar xzf workspace-controller-static.tar.gz

# 테스트 스크립트 사용
cat > test-on-host.sh << 'EOF'
#!/bin/bash
chmod +x workspace-controller
ldd workspace-controller 2>&1 || echo "정적 실행 파일"
./workspace-controller
EOF

chmod +x test-on-host.sh
./test-on-host.sh
```

## 방법 3: 가상 머신에서 테스트

### VirtualBox 예시
1. 새 우분투 VM 생성 (최소 설치)
2. 네트워크 어댑터 비활성화 또는 NAT 네트워크에서 테스트
3. 빌드된 파일을 VM으로 전송 (공유 폴더, USB 등)
4. VM 내에서 실행 테스트

### QEMU/KVM 예시
```bash
# 깨끗한 우분투 이미지 다운로드 (한 번만)
wget https://cdimage.ubuntu.com/ubuntu/releases/22.04/release/ubuntu-22.04-server-amd64.iso

# 네트워크 없는 VM 생성
qemu-system-x86_64 \
  -m 2048 \
  -drive file=ubuntu-test.img,format=raw \
  -cdrom ubuntu-22.04-server-amd64.iso \
  -netdev none \
  -device virtio-net,netdev=none
```

## 방법 4: Docker Compose로 네트워크 격리 테스트

```yaml
# docker-compose.test.yml
version: '3.8'
services:
  test:
    build:
      context: .
      dockerfile: Dockerfile.test
    network_mode: none  # 네트워크 완전 격리
    command: workspace-controller
```

실행:
```bash
docker-compose -f docker-compose.test.yml up
```

## 검증 체크리스트

정적 빌드가 성공했는지 확인:

- [ ] `ldd workspace-controller` 결과가 "not a dynamic executable" 또는 "statically linked"
- [ ] `file workspace-controller` 결과에 "statically linked" 포함
- [ ] 네트워크 없는 환경에서도 실행 가능
- [ ] 시스템 라이브러리 없이도 실행 가능 (필요한 경우)

## 문제 해결

### "command not found" 오류
- 실행 권한 확인: `chmod +x workspace-controller`
- 경로 확인: `./workspace-controller` (상대 경로 사용)

### "cannot execute binary file" 오류
- 아키텍처 불일치 가능: 빌드한 시스템과 다른 아키텍처인지 확인
- `file workspace-controller`로 아키텍처 확인

### 네트워크 관련 오류
- 정적 빌드는 네트워크 없이도 작동해야 함
- glibc 경고는 정상이며 대부분의 경우 실행에는 문제 없음

