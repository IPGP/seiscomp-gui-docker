FROM debian:12-slim

LABEL org.opencontainers.image.authors="boissier@ipgp.fr"
LABEL version="1.0"
LABEL description="Docker image running SeisComP version 6 \
on Debian 12."

## Environment variables

# Directories
ENV WORK_DIR=/home/sysop/
ENV INSTALL_DIR=/opt/seiscomp
ENV LOG_DIR=/home/sysop/.seiscomp
ENV DATA_DIR=/opt/data
# Set system to non-interactive during build only
ARG DEBIAN_FRONTEND=noninteractive
# NOT SURE IF USEFUL => ASK F. MASSIN
#ENV INITRD=No
# Simulate a chroot environment
ENV FAKE_CHROOT=1
# Setup sysop's user and group id
ENV USER_ID=1000
ENV GROUP_ID=1000
# Ensures that the OpenGL graphics library will not try to direct access GPU in the container
ENV LIBGL_ALWAYS_INDIRECT=1

WORKDIR $WORK_DIR

## System upgrade and packages install

# Configure dpkg to use unsafe I/O operations in order 
# to improve package installation and update performance.
RUN echo 'force-unsafe-io' | tee /etc/dpkg/dpkg.cfg.d/02apt-speedup \
    # Configure apt to automatically delete downloaded package files after each installation or update operation
    && echo 'DPkg::Post-Invoke {"/bin/rm -f /var/cache/apt/archives/*.deb || true";};' | tee /etc/apt/apt.conf.d/no-cache \
    # System upgrade
    && apt-get update \
    && apt-get dist-upgrade -y --no-install-recommends \
    # Install generic tools
    && apt-get install -y \
        openssh-server \
        openssl \
        libssl-dev \
        net-tools \
        python3 \
        python3-pip \
        sudo \
        wget \
        vim \
        git \
        pipx \
        # Useful for X11 forwarding
        mesa-utils \
        libgl1-mesa-glx \
    # Install GSM dependencies
    && pip install \
        configparser \
        cryptography \
        humanize \
        natsort \
        python-dateutil \
        pytz \
        requests \
        tqdm \
        tzlocal \
        urllib3 \
        bs4 \
        gnupg \
        --break-system-packages \
    # Cleanup
    && apt-get autoremove -y --purge \
    && apt-get clean 

## Setup ssh access

RUN mkdir /var/run/sshd \
    # Generate SSH host keys 
    && ssh-keygen -A \
    && sed -i'' -e's/^#X11UseLocalhost yes$/X11UseLocalhost no/' /etc/ssh/sshd_config \
    && sed -i'' -e's/^#AllowAgentForwarding yes$/AllowAgentForwarding yes/' /etc/ssh/sshd_config \
    && sed -i'' -e's/^#PermitRootLogin prohibit-password$/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -i'' -e's/^#PasswordAuthentication yes$/PasswordAuthentication yes/' /etc/ssh/sshd_config \
    && sed -i'' -e's/^#PermitEmptyPasswords no$/PermitEmptyPasswords yes/' /etc/ssh/sshd_config \
    && sed -i'' -e's/^UsePAM yes/UsePAM no/' /etc/ssh/sshd_config \
    # SSH login fix. Otherwise user is kicked off after login
    && sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

# Expose SSH TCP port
EXPOSE 22

## Users and groups

# Create sysop user and group
RUN groupadd --gid $GROUP_ID -r sysop \
    && useradd -m -s /bin/bash --uid $USER_ID -r -g sysop sysop \
    # No password for sysop
    && passwd -d sysop \
    # Set root password to 'password'
    && echo 'root:password' | chpasswd \
    # Add sysop to sudoers
    && echo 'sysop ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/sysop \
    && chmod 0440 /etc/sudoers.d/sysop

## Directories

RUN mkdir -p $LOG_DIR \
    && chown -R sysop:sysop /home/sysop \
    && mkdir -p $INSTALL_DIR \
    && chown -R sysop:sysop $INSTALL_DIR \
    && chmod g+w $INSTALL_DIR \
    && mkdir -p $DATA_DIR \
    && chown -R sysop:sysop $DATA_DIR \
    && chmod g+w $DATA_DIR

USER sysop

## Install GSM
RUN wget https://data.gempa.de/gsm/gempa-gsm.tar.gz \
    && tar xvfz gempa-gsm.tar.gz 

COPY gsm/gsmsetup gsm/

## Install SeisComP
RUN rm -rf gsm/sync \
    && cd gsm \
    && bash ./gsmsetup 

## Install SeisComP deps and database
RUN sed -i 's;apt;apt -y;' $INSTALL_DIR/share/deps/*/*/install-*.sh \
    && $INSTALL_DIR/bin/seiscomp install-deps base gui fdsnws

# SeisComP Maps
RUN wget https://www.seiscomp.de/downloader/seiscomp-maps.tar.gz \
    && tar xzf seiscomp-maps.tar.gz -C /opt/

## SeisComP configuration
RUN $INSTALL_DIR/bin/seiscomp print env >> /home/sysop/.profile

# Copy user-defined configuration files
COPY ./seiscomp/etc/* $INSTALL_DIR/etc/
RUN find $INSTALL_DIR/etc/ -type f -name "*.cfg" -print0 | xargs -0 sudo chmod 644 \
    && find $INSTALL_DIR/etc/ -type f -name "*.cfg" -print0 | xargs -0 sudo chown sysop:sysop

# Start sshd in foreground - useful for "detached" mode
CMD sudo /usr/sbin/sshd -D

## Build :
# docker build -t seiscomp-version6:latest .
## Lancer le conteneur en arrière plan
# docker run -d -p 2222:22 \
#            -v /HOST/PATH/TO/seiscomp/share/nll:/INSTALL_DIR/share/nll \
#            -v /HOST/PATH/TO/seiscomp/share/maps/OCMap:/INSTALL_DIR/share/maps/OCMap \
#            --name scolv seiscomp-version6:latest
