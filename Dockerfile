FROM jdrouet/wasm-pack:latest as builder
COPY . .
ENV RUSTUP_PERMIT_COPY_RENAME=true

RUN apt-get -qq update; \
    apt-get install -qqy --no-install-recommends \
        gnupg2 wget ca-certificates apt-transport-https \
        autoconf automake cmake dpkg-dev file make patch libc6-dev

# Set repository key
RUN wget -nv -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add -

# Install
RUN echo "deb http://apt.llvm.org/buster/ llvm-toolchain-buster-15 main" \
        > /etc/apt/sources.list.d/llvm.list; \
    apt-get -qq update && \
    apt-get install -qqy -t llvm-toolchain-buster-15 \
    clang-format clang-tidy clang-tools clang libc++-dev libc++1 libc++abi-dev \
    libc++abi1 libclang-dev libclang1 liblldb-dev libllvm-ocaml-dev libomp-dev libomp5 \
    lld lldb llvm-dev llvm-runtime llvm  && \
    for f in /usr/lib/llvm-buster/bin/*; do ln -sf "$f" /usr/bin; done && \
    rm -rf /var/lib/apt/lists/*

RUN rustup install nightly-2022-06-01-x86_64-unknown-linux-gnu
RUN rustup component add rust-src --toolchain nightly-2022-06-01-x86_64-unknown-linux-gnu

# Build the WASM package
CMD ["wasm-pack", "build", "--target", "web", "-d", "wasm/pkg"]

# FROM debian:buster-slim
# RUN apt-get update && apt-get install -y extra-runtime-dependencies && rm -rf /var/lib/apt/lists/*
# COPY --from=builder /usr/local/cargo/bin/myapp /usr/local/bin/myapp
# CMD ["myapp"]