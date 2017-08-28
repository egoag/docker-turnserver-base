FROM python:slim

# Use baseimage-docker's init system.
COPY . /bd_build

ENV DEBIAN_FRONTEND="teletype" \
    LANG="en_US.UTF-8" \
    LANGUAGE="en_US:en" \
    LC_ALL="en_US.UTF-8"

CMD ["/sbin/my_init"]

ENV HOME /root

RUN apt-get update && \
	/bd_build/system_services.sh && \
	apt-get install -y --no-install-recommends \
	gdebi-core \
	telnet \
	libpq5 \
	libhiredis0.10 \
	libevent-core-2.0-5 \
	libevent-extra-2.0-5 \
	libevent-openssl-2.0-5 \
	libevent-pthreads-2.0-5 \
	mysql-common \
	libmysqlclient18 \
	curl && \
	apt-get install -y \
	gcc && \
	/bd_build/cleanup.sh

ENV COTURN_VER 4.4.5.3
RUN cd /tmp/ && curl -sL http://turnserver.open-sys.org/downloads/v${COTURN_VER}/turnserver-${COTURN_VER}-debian-wheezy-ubuntu-mint-x86-64bits.tar.gz | tar -xzv

RUN groupadd turnserver
RUN useradd -g turnserver turnserver
RUN gdebi -n /tmp/coturn*.deb

RUN mkdir /etc/service/turnserver
ADD turnserver.sh /etc/service/turnserver/run
RUN chmod a+x /etc/service/turnserver/run


ONBUILD COPY requirements.txt /root/.
ONBUILD RUN cd /root && pip3 install -r requirements.txt

ONBUILD RUN mkdir /etc/service/pythonserver
ONBUILD ADD pythonserver.sh /etc/service/pythonserver/run
ONBUILD RUN chmod +x /etc/service/pythonserver/run

ONBUILD COPY . /root/
