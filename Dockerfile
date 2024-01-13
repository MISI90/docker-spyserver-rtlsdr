FROM ubuntu:bionic

ARG TARGETPLATFORM
ENV TARGETPLATFORM "$TARGETPLATFORM"
ENV LIBS "kmod"
ENV TEMP_LIBS "libusb-1.0-0-dev git cmake pkg-config wget"

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install $LIBS $TEMP_LIBS -y
RUN git clone https://github.com/rtlsdrblog/rtl-sdr-blog && \
    cd rtl-sdr-blog && \
    mkdir build && \
    cd build && \
    cmake ../ -DINSTALL_UDEV_RULES=ON && \
    make && \
    make install && \
    cp ../rtl-sdr.rules /etc/udev/rules.d/ && \
    ldconfig && \
    echo sudo 'blacklist dvb_usb_rtl28xxu' > /etc/modprobe.d/blacklist-dvb_usb_rtl28xxu.conf && \
    cd / && \
    rm -r rtl-sdr-blog

RUN set -ex; \
  if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
    wget https://airspy.com/downloads/spyserver-linux-x64.tgz;\
    tar xvzf spyserver-linux-x64.tgz;\
    rm spyserver-linux-x64.tgz;\
  elif [ "$TARGETPLATFORM" = "linux/arm/v7" ]; then \
    wget https://airspy.com/downloads/spyserver-arm32.tgz;\
    tar xvzf spyserver-arm32.tgz;\
    rm spyserver-arm32.tgz;\
  fi;

RUN mv spyserver spyserver_ping /usr/bin && \
    mkdir -p /etc/spyserver && \
    mv spyserver.config /etc/spyserver

RUN DEBIAN_FRONTEND=noninteractive apt-get purge $TEMP_LIBS -y

COPY entrypoint.sh .
ENTRYPOINT ["/bin/sh", "entrypoint.sh"]
