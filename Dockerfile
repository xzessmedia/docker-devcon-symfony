FROM xzesstence/docker-ubuntu:latest
MAINTAINER "Tim Koepsel"

#https://www.digitalocean.com/community/tutorials/how-to-install-linux-nginx-mysql-php-lemp-stack-ubuntu-18-04


ENV TZ 'Europe/Brussels'

# https://bugs.debian.org/830696 (apt uses gpgv by default in newer releases, rather than gpg)
RUN set -ex; \
        apt-get update; \
        if ! which gpg; then \
                apt-get install -y --no-install-recommends gnupg; \
        fi; \
# Ubuntu includes "gnupg" (not "gnupg2", but still 2.x), but not dirmngr, and gnupg 2.x requires dirmngr
# so, if we're not running gnupg 1.x, explicitly install dirmngr too
        if ! gpg --version | grep -q '^gpg (GnuPG) 1\.'; then \
                 apt-get install -y --no-install-recommends dirmngr; \
        fi; \
        rm -rf /var/lib/apt/lists/*


RUN apt-get update
RUN apt-get install -q -y nodejs && apt-get install -q -y npm
RUN apt-get install -q -y openssh-server
RUN apt-get install -q -y git
RUN export DEBIAN_FRONTEND=noninteractive && DEBIAN_FRONTEND=noninteractive apt-get update \
 && echo $TZ > /etc/timezone \
 && apt-get install -q -y php-cli
RUN curl -sS https://getcomposer.org/installer | \
    php -- --install-dir=/usr/bin/ --filename=composer

RUN apt-get install -q -y nginx

RUN useradd -d /home/xdev -ms /bin/bash -g root -G sudo xdev
RUN echo 'xdev:123456' | chpasswd
USER xdev
WORKDIR /home/xdev

#COPY /dist/ /xdev
#COPY /Backend/Symfony/chomba-backend /xdev/API

CMD sudo /etc/init.d/ssh start
ENTRYPOINT ["tail", "-f", "/dev/null"]
CMD ["bash"]
