FROM ubuntu:bionic

ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL C.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

RUN dpkg --add-architecture i386
RUN apt-get update && apt-get install -y wget gnupg software-properties-common
RUN wget -O - https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/xUbuntu_18.04/Release.key | apt-key add -
RUN apt-add-repository 'deb https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/xUbuntu_18.04/ ./'
RUN wget -O - https://dl.winehq.org/wine-builds/winehq.key | apt-key add -
RUN apt-add-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ bionic main'
RUN apt-get update && apt-get install -y winehq-stable xvfb x11vnc fluxbox python3 python3-setuptools

ENV WINEPREFIX /root/prefix32
ENV WINEARCH win32
ENV DISPLAY :0

WORKDIR /root/

ENV NOVNC_VERSION 1.1.0
RUN wget -O - https://github.com/novnc/noVNC/archive/v${NOVNC_VERSION}.tar.gz | tar -xzv -C /root/ \
  && mv /root/noVNC-${NOVNC_VERSION} /root/novnc \
  && ln -s /root/novnc/vnc.html /root/novnc/index.html

ENV WEBSOCKIFY_VERSION 0.9.0
RUN wget -O - https://github.com/novnc/websockify/archive/v${WEBSOCKIFY_VERSION}.tar.gz | tar -xzv -C /root/ \
  && cd /root/websockify-${WEBSOCKIFY_VERSION} \
  && python3 setup.py install \
  && rm -rf /root/websockify-${WEBSOCKIFY_VERSION}

ENV ENTRYKIT_VERSION 0.4.0
RUN wget -O - https://github.com/progrium/entrykit/releases/download/v${ENTRYKIT_VERSION}/entrykit_${ENTRYKIT_VERSION}_Linux_x86_64.tgz | tar -xzv -C /root/ \
  && mv entrykit /bin/entrykit \
  && chmod +x /bin/entrykit \
  && entrykit --symlink

ENTRYPOINT ["codep", \
  "Xvfb :0 -screen 0 1280x800x24", \
  "x11vnc -forever -shared -noxrecord", \
  "/root/novnc/utils/launch.sh --vnc localhost:5900 --listen 8080", \
  "fluxbox", \
  "wine explorer", \
  "--" \
  ]
