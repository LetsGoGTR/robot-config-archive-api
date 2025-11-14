cmake_minimum_required(VERSION 3.10)
project(workspace-controller)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 정적 빌드 설정
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -static")
set(CMAKE_FIND_LIBRARY_SUFFIXES ".a;.so")

# pkg-config를 사용하여 libarchive와 모든 의존성 가져오기 (선택적)
find_package(PkgConfig QUIET)
if(PKG_CONFIG_FOUND)
  pkg_check_modules(LIBARCHIVE libarchive)
endif()

# pkg-config가 없거나 실패하면 수동으로 찾기
if(NOT LIBARCHIVE_FOUND)
  message(STATUS "pkg-config를 사용할 수 없습니다. 수동으로 libarchive를 찾습니다...")
  
  # libarchive 헤더 찾기
  find_path(LIBARCHIVE_INCLUDE_DIR
    NAMES archive.h
    PATHS /usr/include /usr/local/include
  )
  
  # libarchive 라이브러리 찾기 (정적 라이브러리 우선)
  find_library(LIBARCHIVE_LIB
    NAMES archive
    PATHS /usr/lib/x86_64-linux-gnu /usr/lib /usr/local/lib
  )
  
  if(LIBARCHIVE_INCLUDE_DIR AND LIBARCHIVE_LIB)
    set(LIBARCHIVE_FOUND TRUE)
    set(LIBARCHIVE_INCLUDE_DIRS ${LIBARCHIVE_INCLUDE_DIR})
    set(LIBARCHIVE_LIBRARIES ${LIBARCHIVE_LIB})
    message(STATUS "libarchive를 찾았습니다: ${LIBARCHIVE_LIB}")
  else()
    message(FATAL_ERROR "libarchive를 찾을 수 없습니다. libarchive-dev를 설치해주세요.")
  endif()
endif()

# Find bcrypt (정적 라이브러리)
find_library(CRYPT_LIB
  NAMES crypt
  PATHS /usr/lib/x86_64-linux-gnu /usr/lib /usr/local/lib
)

# libarchive가 필요로 하는 모든 의존성 라이브러리 링크
# pkg-config Libs.private: -lnettle -lacl -llzma -lzstd -llz4 -lbz2 -lz -lxml2
# 추가로 libxml2가 필요로 하는 의존성: ICU (libicuuc, libicudata, libicui18n)
# -static 플래그를 사용할 때 링커가 자동으로 정적 라이브러리를 찾도록 라이브러리 이름만 전달
# 각 라이브러리가 존재하는지 확인 후 링크
set(LIBARCHIVE_DEPS)
set(REQUIRED_DEPS nettle acl lzma zstd lz4 bz2 z xml2 icuuc icudata icui18n)

foreach(lib_name ${REQUIRED_DEPS})
  # 정적 라이브러리(.a) 먼저 확인
  find_file(LIB_${lib_name}_STATIC
    NAMES lib${lib_name}.a
    PATHS /usr/lib/x86_64-linux-gnu /usr/lib /usr/local/lib
    NO_DEFAULT_PATH
  )
  
  if(LIB_${lib_name}_STATIC)
    # 정적 라이브러리 경로 직접 사용
    list(APPEND LIBARCHIVE_DEPS ${LIB_${lib_name}_STATIC})
    message(STATUS "정적 라이브러리 찾음: ${lib_name} -> ${LIB_${lib_name}_STATIC}")
  else()
    # 정적 라이브러리가 없으면 라이브러리 이름만 전달 (링커가 찾도록)
    list(APPEND LIBARCHIVE_DEPS ${lib_name})
    message(WARNING "${lib_name} 정적 라이브러리를 찾을 수 없습니다. 설치 필요: lib${lib_name}-dev")
  endif()
endforeach()

add_executable(
  workspace-controller
  src/main.cc
  src/utils/utils.cc
  src/services/workspaceService.cc
  src/services/authService.cc
  src/controllers/httpController.cc
  src/controllers/robotController.cc
  src/controllers/workspaceController.cc
)

target_include_directories(workspace-controller
  PRIVATE
    ${CMAKE_SOURCE_DIR}/src
    ${LIBARCHIVE_INCLUDE_DIR}
)

# 정적 링킹 시 라이브러리 순서가 중요합니다.
# libxml2가 zlib과 lzma 함수를 필요로 하는데, 
# 링커는 앞에서 뒤로 심볼을 찾으므로 zlib과 lzma를 libxml2 뒤에 다시 링크해야 합니다.
target_link_libraries(workspace-controller
  PRIVATE
    ${LIBARCHIVE_LIBRARIES}
    ${LIBARCHIVE_DEPS}
    ${CRYPT_LIB}
    pthread
    # libxml2가 필요로 하는 의존성을 다시 링크 (순환 의존성 해결)
    z
    lzma
)

# 정적 링킹 강제 (모든 심볼을 정적으로 해결)
target_link_options(workspace-controller
  PRIVATE
    -static-libgcc
    -static-libstdc++
)
