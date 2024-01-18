FROM golang:1.20.7 AS builder_calibration

RUN apt update
RUN apt upgrade -y
RUN apt install cargo mesa-opencl-icd ocl-icd-opencl-dev gcc git bzr jq pkg-config curl clang build-essential hwloc libhwloc-dev -y
RUN apt install -y git ssh wget

WORKDIR /build

RUN git clone --depth 1 --branch v1.25.2 -v --progress https://github.com/filecoin-project/lotus.git .

SHELL ["/bin/bash", "-c"]
RUN wget https://sh.rustup.rs -O rustup-init
RUN chmod +x rustup-init
RUN ./rustup-init -y && source $HOME/.cargo/env
RUN make clean calibnet
RUN make install


FROM golang:1.20.7

COPY --from=builder_calibration /usr/local/bin /usr/local/bin
RUN adduser --disabled-password --gecos "" --uid 1000 service
WORKDIR /home/service
RUN apt update && apt install libhwloc-dev -y
USER service

ENTRYPOINT ["lotus", "daemon"]
