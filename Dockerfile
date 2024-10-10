FROM alpine:3.16

RUN apk update \
    && apk add --no-cache perl curl xz dmidecode pciutils usbutils \
    smartmontools hdparm sysstat util-linux lm_sensors acpi iw wireless-tools glib libxrandr zlib eudev-libs libusb libdrm  \
    alsa-utils xrandr xdpyinfo xinput acpica iasl perl-libwww i2c-tools hwinfo libx86emu meson \
    && apk add --no-cache --virtual build-deps git gcc g++ make autoconf automake libtool file bsd-compat-headers libc-dev util-linux-dev flex linux-headers glib-dev libxrandr-dev zlib-dev eudev-dev libusb-dev libdrm-dev i2c-tools-dev kmod-dev

RUN git clone https://git.linuxtv.org/edid-decode.git 2>/dev/null \
    && cd edid-decode \
    #&& find . -type f | perl -lne 'print if -B and -x' | xargs strip \
    && meson setup build \
    && meson compile -C build \
    && meson install -C build \
    && cd .. \
    && rm -fr edid-decode

RUN git clone https://github.com/rockowitz/ddcutil.git \
    && cd ddcutil \
    && git checkout 1.2.2-release \
    && NOCONFIGURE=1 NO_CONFIGURE=1 sh autogen.sh \
    && ./configure --prefix=/usr \
    && make \
    && find . -type f | perl -lne 'print if -B and -x' | xargs strip \
    && make install \
    && cd .. \
    && rm -fr ddcutil

RUN curl -L https://github.com/linuxhw/build-stuff/releases/download/1.6/hw-probe-1.6-AI.tar.gz > hw-probe-1.6-AI.tar.gz \
    && tar -xf hw-probe-1.6-AI.tar.gz \
    && rm -fr hw-probe-1.6-AI.tar.gz \
    && cd hw-probe-1.6-AI \
    && make install \
    && cd .. \
    && rm -fr hw-probe-1.6-AI

RUN apk del build-deps \
    && rm -fr /usr/bin/acpibin /usr/bin/acpiexamples /usr/bin/acpiexec /usr/bin/acpihelp /usr/bin/acpinames /usr/bin/acpisrc /usr/bin/lsusb.py /usr/bin/usbhid-dump \
    && rm -fr /usr/sbin/convert_hd /usr/sbin/check_hd /usr/sbin/mk_isdnhwdb /usr/sbin/getsysinfo /usr/sbin/fancontrol /usr/sbin/pwmconfig /usr/sbin/isadump /usr/sbin/isaset /usr/sbin/ownership /usr/sbin/setpci /usr/sbin/vpddecode /usr/sbin/update-smart-drivedb /usr/sbin/smartd \
    && rm -fr /usr/share/man /usr/share/doc /usr/share/pkgconfig /usr/share/cmake /usr/share/ddcutil \
    && rm -fr /usr/include \
    && rm -fr /usr/lib/pkgconfig /usr/lib/systemd /usr/lib/libddc* \
    && rm -fr /usr/share/perl5/vendor_perl/libwww/*.pod \
    && rm -fr /usr/bin/lwp-* \
    && rm -fr /var/cache/apk/*

ENV LD_LIBRARY_PATH /usr/lib64:/usr/lib
ENV DISPLAY :0

ENTRYPOINT ["/usr/bin/hw-probe", "-docker"]
