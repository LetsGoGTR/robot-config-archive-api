### 서버사이드 프로그램

## 실행 방법

1. 정적 빌드
```
cmake -DBUILD_STATIC=ON ..
make
```

2. 동적 빌드
```
cmake ..
make
```

## 콘솔 로그 활성화

main.cc 수정
- 기존 init 라인을 주석 처리
```cpp
plog::init(plog::info, &fileAppender);
```
- 다음 주석을 해제 후 재빌드
```cpp
// static plog::ColorConsoleAppender<plog::TxtFormatter> consoleAppender;
// plog::init(plog::info, &fileAppender).addAppender(&consoleAppender);
```
