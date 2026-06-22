# Self-build fallback for Gemma 4 E2B/E4B MTP support.
# Build when the official GHCR image is too old or MTP fails with unknown model architecture: gemma4-assistant.
ARG CUDA_VERSION=13.0.1
FROM nvidia/cuda:${CUDA_VERSION}-devel-ubuntu24.04 AS build

ARG LLAMA_CPP_REF=master
ARG CUDA_DOCKER_ARCH=all

RUN apt-get update && apt-get install -y --no-install-recommends \
    git cmake build-essential ca-certificates curl ccache nano \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src
RUN git clone https://github.com/ggml-org/llama.cpp.git . \
    && git checkout ${LLAMA_CPP_REF}

RUN cmake -B build \
    -DGGML_CUDA=ON \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CUDA_ARCHITECTURES=${CUDA_DOCKER_ARCH} \
    && cmake --build build -j --target llama-server llama-cli llama-mtmd-cli

FROM nvidia/cuda:${CUDA_VERSION}-runtime-ubuntu24.04
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl libgomp1 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=build /src/build/bin/llama-server /app/llama-server
COPY --from=build /src/build/bin/llama-cli /app/llama-cli
COPY --from=build /src/build/bin/llama-mtmd-cli /app/llama-mtmd-cli

ENV HF_HOME=/root/.cache/huggingface
EXPOSE 8080
ENTRYPOINT ["/app/llama-server"]
