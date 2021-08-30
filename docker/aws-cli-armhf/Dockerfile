
FROM tintinho/python:3.9.6-armhf

RUN apt-get update -y && \
  apt-get install -y git cmake

WORKDIR /opt/aws-cli

RUN git clone https://github.com/aws/aws-cli . && git checkout v2
RUN python3 -m pip install -r requirements.txt
RUN python3 -m pip install .

WORKDIR /
RUN rm -rf /opt/aws-cli
