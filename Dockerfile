FROM ubuntu:18.04
MAINTAINER Oleg Orlov "orelcokolov@gmail.com"

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y ssh vim nano && apt-get clean

RUN mkdir /var/run/sshd
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
RUN sed -ri 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config

# Create and configure vagrant user
RUN useradd --create-home -s /bin/bash vagrant

# Configure SSH access
RUN mkdir -p /home/vagrant/.ssh
RUN echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key" > /home/vagrant/.ssh/authorized_keys
RUN chown -R vagrant: /home/vagrant/.ssh
RUN echo -n 'vagrant:vagrant' | chpasswd
RUN touch /home/vagrant/.hushlogin

# Enable passwordless sudo for vagrant
RUN apt-get update && apt-get install -y sudo && apt-get clean
RUN mkdir -p /etc/sudoers.d && echo "vagrant ALL= NOPASSWD: ALL" > /etc/sudoers.d/vagrant && chmod 0440 /etc/sudoers.d/vagrant

CMD ["/usr/sbin/sshd", "-D", "-e"]
EXPOSE 22

RUN apt-get install -y vim nano aptitude apt-file xvfb git-core tmux rabbitmq-server mysql-server-5.7 libmysqlclient-dev \
	libv8-3.14.5 libv8-dev nodejs ruby-dotenv g++ gcc autoconf automake bison libc6-dev libffi-dev libgdbm-dev \
    libncurses5-dev libsqlite3-dev libtool libyaml-dev make pkg-config sqlite3 zlib1g-dev libgmp-dev libreadline-dev \
    libssl-dev qt5-default libqt5webkit5-dev gstreamer1.0-plugins-base gstreamer1.0-tools gstreamer1.0-x golang-go curl \
    tzdata inotify-tools ruby \
    fontconfig libjpeg-turbo8 libxrender1 xfonts-75dpi xfonts-base libpng16-16

RUN  sudo gem install parallel colorize commander os pry bundler

# Overmind
RUN go get -u -f github.com/DarthSim/overmind
RUN mv $HOME/go/bin/overmind /usr/local/bin/
RUN rm -rf ./go

# Wkhtmltopdf
RUN wget https://downloads.wkhtmltopdf.org/0.12/0.12.5/wkhtmltox_0.12.5-1.bionic_amd64.deb -O wkhtmltox_0.12.5-1.bionic_amd64.deb
RUN dpkg -i  wkhtmltox_0.12.5-1.bionic_amd64.deb
RUN rm wkhtmltox_0.12.5-1.bionic_amd64.deb

# RVM
RUN su - vagrant -c "bash -c 'curl -sSL https://get.rvm.io | bash'"

# Install rubies
RUN su - vagrant -c 'bash -c "source $HOME/.rvm/scripts/rvm && $(which rvm) install 2.5.3"'
RUN su - vagrant -c 'bash -c "source $HOME/.rvm/scripts/rvm && $(which rvm) install 2.5.0"'
RUN su - vagrant -c 'bash -c "source $HOME/.rvm/scripts/rvm && $(which rvm) install 2.4.2"'
RUN su - vagrant -c 'bash -c "source $HOME/.rvm/scripts/rvm && $(which rvm) install 2.3.1"'
