FROM debian:bookworm-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    pkg-config \
    libarchive-dev \
    libcrypt-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY . .

RUN mkdir -p /home/default/workspace \
    && chown -R 1000:1000 /home/default/workspace

RUN cmake -S . -B build \
    && cmake --build build

EXPOSE 80

CMD ["./build/workspace-controller"]

