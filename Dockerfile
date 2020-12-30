FROM alpine:latest AS builder

RUN set -eux; \
	apk add --no-cache \
    # install ca-certificates so that HTTPS works consistently
		ca-certificates \
	;

RUN apk upgrade --update && apk add --no-cache git make cmake libstdc++ gcc g++ automake libtool autoconf linux-headers

WORKDIR /opt/src

RUN git clone https://github.com/xmrig/xmrig.git \
	&& mkdir xmrig/build \
	&& cd xmrig/scripts \
	&& ./build_deps.sh \
	&& cd ../build \
	&& cmake .. -DXMRIG_DEPS=scripts/deps -DBUILD_STATIC=ON \
	&& make -j$(nproc)

FROM alpine:latest

RUN set -eux; \
	apk add --no-cache \
		ca-certificates \
	;

WORKDIR /opt/src
COPY --from=builder /opt/src/xmrig/build/xmrig /opt/src