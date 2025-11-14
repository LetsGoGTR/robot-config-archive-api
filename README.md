# robot-config-archive-api

로봇 설정 아카이브 API 서버

## 정적 빌드

이 프로젝트는 인터넷이 없는 환경에서도 실행 가능하도록 정적 빌드를 지원합니다.

### 사전 요구사항

정적 빌드를 위해서는 모든 의존성 라이브러리의 정적 버전이 필요합니다.

#### 1단계: 의존성 라이브러리 설치 (먼저 실행)

```bash
chmod +x install-static-deps.sh
./install-static-deps.sh
```

또는 수동으로 설치:

```bash
sudo apt-get update
sudo apt-get install -y \
  build-essential \
  cmake \
  pkg-config \
  libarchive-dev \
  zlib1g-dev \
  libbz2-dev \
  liblzma-dev \
  libzstd-dev \
  liblz4-dev \
  nettle-dev \
  libxml2-dev \
  libacl1-dev \
  libicu-dev
```

### 빌드 방법

#### 방법 1: 빌드 스크립트 사용 (권장)

```bash
chmod +x build.sh
./build.sh
```

#### 방법 2: 수동 빌드

```bash
mkdir -p build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j$(nproc)
```

빌드가 완료되면 `build/workspace-controller` 실행 파일이 생성됩니다.

### 정적 빌드 확인

정적 빌드가 성공적으로 완료되었는지 확인:

```bash
ldd build/workspace-controller
```

"not a dynamic executable" 또는 "statically linked" 메시지가 표시되면 정적 빌드가 성공한 것입니다.

### 실행

```bash
./build/workspace-controller
```

### 정적 라이브러리 설치 (Ubuntu/Debian)

필수 패키지 설치:

```bash
sudo apt-get update
sudo apt-get install build-essential cmake libarchive-dev
```

일반적으로 `libarchive-dev`를 설치하면 정적 라이브러리(`.a`)가 함께 설치됩니다.

