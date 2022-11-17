FROM docker.io/ubuntu:22.04
RUN apt update -y && apt install -y sudo python3 ca-certificates python3-apt apt-utils
