
FROM debian:stretch-slim
ARG PYTHON_VERSION

RUN apt-get update -y && apt-get install -y \
  wget \
  build-essential \
  zlib1g-dev \
  libncurses5-dev \
  libgdbm-dev \
  libnss3-dev \
  libssl-dev \
  libsqlite3-dev \
  libreadline-dev \
  libffi-dev \
  libbz2-dev \
  curl

RUN cd /tmp && \
  wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz && \
  tar -zxvf Python-${PYTHON_VERSION}.tgz

WORKDIR /tmp/Python-${PYTHON_VERSION}

RUN ./configure
RUN make
RUN make install
RUN python3 -m pip install --upgrade pip

WORKDIR /
RUN rm -rf /tmp/Python-${PYTHON_VERSION} /tmp/Python-${PYTHON_VERSION}.tgz
