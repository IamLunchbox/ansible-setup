FROM docker.io/kalilinux/kali-rolling
RUN apt update -y && apt install -y sudo python3 ca-certificates python3-apt apt-utils
