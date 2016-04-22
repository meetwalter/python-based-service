FROM phusion/baseimage:0.9.13
MAINTAINER Michael Williams
ENV REFRESHED_AT 2016-04-22

# Set correct environment variables.
ENV PYTHON_MAJOR 2.7
ENV PYTHON_VERSION 2.7.11

# ENV HOME does not seem to work currently; HOME is unset in Docker container.
# See discussion at: https://github.com/phusion/baseimage-docker/issues/119
RUN echo /root > /etc/container_environment/HOME

# Regenerate SSH host keys. baseimage-docker does not contain any, so you
# have to do that yourself. You may also comment out this instruction; the
# init system will auto-generate one during boot.
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

# Baseimage-docker enables an SSH server by default, so that you can use SSH
# to administer your container. In case you do not want to enable SSH, here's
# how you can disable it. Uncomment the following:
#RUN rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh

# Use phusion/baseimage's init system.
CMD ["/sbin/my_init"]

# Set the locale.
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# See discussion at: https://github.com/phusion/baseimage-docker/issues/58
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Install dependencies and useful tools.
RUN apt-get update \
  && apt-get install -y autoconf autotools-dev bison blt-dev build-essential \
  bzip2 dpkg-dev g++-multilib gcc-multilib libbluetooth-dev libbz2-dev \
  libexpat1-dev libffi-dev libffi6 libffi6-dbg libgdbm-dev libgdbm3 libgpm2 \
  libncurses5-dev libncursesw5-dev libreadline-dev libreadline6-dev \
  libsqlite3-dev libssl-dev libtinfo-dev libyaml-dev mime-support net-tools \
  netbase python-crypto python-mox3 python-pil python-ply quilt tk-dev \
  libxml2-dev zlib1g-dev

# Build and install Python.
RUN mkdir -p /usr/src/python \
  && curl -SL "https://www.python.org/ftp/python/2.7.11/Python-2.7.11.tgz" | tar -xz -f - -C /usr/src/python --strip-components=1 \
  && cd /usr/src/python \
  && ./configure --prefix /usr/local/lib/python2.7.11 --enable-ipv6 \
  && make -j"$(nproc)" \
  && make install \
  && rm -r /usr/src/python

# Make sure C-based wheels have headers to build against.
RUN apt-get install -y python2.7-dev

# Install Pip (and SetupTools).
RUN mkdir -p /usr/src/pip \
  && curl -o /usr/src/pip/get-pip.py https://bootstrap.pypa.io/get-pip.py \
  && python /usr/src/pip/get-pip.py

# Clean up.
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
