#
# This Docker image encapsulates the Volatility Framework (version 2.5) by The 
# Volatility Foundation from http://www.volatilityfoundation.org/#!releases/component_71401
#
# To run this image after installing Docker, use the following command:
# sudo docker run --rm -it -v ~/memdumps:/home/nonroot/memdumps remnux/volatility bash
#
# Before running Volatility, create the ~/memdumps directory and make it world-accessible
# (“chmod a+xwr").

FROM ubuntu:18.04
MAINTAINER Hestat (@laskow26)

# Install packages from apt repository
USER root
RUN apt-get -qq update && apt-get install -y \
  automake \
  build-essential \
  git \
  ipython \
  libbz2-dev \
  libc6-dev \
  libfreetype6-dev \
  libgdbm-dev \
  libjansson-dev \
  libjpeg8-dev \
  libmagic-dev \
  libreadline-gplv2-dev \
  libtool \
  python2.7 \
  python-dev \
  python-pillow \
  python-pip \
  tar \
  unzip \
  wget \
  zlib1g \
  zlib1g-dev \
  clamav \
  libssl-dev && \
  
# Ensure we're using Python 2.7
ln -fs /usr/bin/python2.7 /usr/bin/python
  
# Install additional dependencies
RUN pip install distorm3 \
  openpyxl \
  pycrypto \
  pytz

# Retrieve remaining dependencies
RUN cd /tmp && \
  wget -O yara-v3.10.0.tar.gz "https://github.com/VirusTotal/yara/archive/v3.10.0.tar.gz" && \
  wget -O calamity.zip "https://github.com/Hestat/calamity/archive/master.zip" && \


# If hashes OK, install Yara and prepare Volatility setup
  unzip calamity.zip && \
  cd calamity-master && \
  ./install.sh && \
  cd /tmp && \
  tar vxzf yara-v3.10.0.tar.gz && \
  cd yara-3.10.0 && \
  ./bootstrap.sh && \
  ./configure && \
  make && \
  make install && \

#fix clamav setup and install sigs
   chown clamav. /var/log/clamav/freshclam.log && \
   freshclam && \

# Add nonroot user and setup environment
  groupadd -r nonroot && \
  useradd -r -g nonroot -d /home/nonroot -s /sbin/nologin -c "Nonroot User" nonroot && \
  mkdir /home/nonroot && \

# Setup Volatility
  cd /opt/calamity/volatility/ && \
  chmod +x vol.py && \
  ln -fs /opt/calamity/volatility/vol.py /usr/local/bin/ && \
  chown -R nonroot:nonroot /home/nonroot

# Clean up
RUN  apt-get remove -y --purge automake build-essential libtool && \
  apt-get autoremove -y --purge && \
  apt-get clean -y && \
  rm -rf /var/lib/apt/lists/*

USER nonroot
ENV HOME /home/nonroot
ENV USER nonroot
WORKDIR /home/nonroot/

