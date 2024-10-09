FROM ubuntu:22.04 AS build

# Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    wget \
    ca-certificates \
    tar \
    gzip \
    autoconf \
    libhts-dev \
    && rm -rf /var/lib/apt/lists/* \
    mkdir /app

# Clone the repository
WORKDIR /app
RUN wget https://github.com/andersen-lab/ivar/archive/refs/tags/v1.4.3.tar.gz \
  && tar xvzf v1.4.3.tar.gz

# Build the project
WORKDIR /app/ivar-1.4.3/
RUN ./autogen.sh \
  && ./configure \
  && make

# Clone the repository
WORKDIR /app
RUN git clone https://github.com/nexomis/loose_ends.git

# Build the project
WORKDIR /app/loose_ends
RUN make

# Stage 2: Final
FROM ubuntu:22.04

# Install runtime dependencies
RUN export DEBIAN_FRONTEND=noninteractive \ 
  && apt-get update \
  && apt-get -y install --no-install-recommends \
    libstdc++6 \
    libc6 \
    libhts3 \
    samtools \
    && rm -rf /var/lib/apt/lists/*

# Copy the built executable from the build stage
COPY --from=build /app/loose_ends/loose_ends /usr/local/bin/loose_ends
COPY --from=build /app/ivar-1.4.3/src/ivar /usr/local/bin/ivar
