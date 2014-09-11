# Installs Omniwallet
FROM ubuntu:14.04
MAINTAINER Peter Loron <peterloron@gmail.com>

ENV DEST /opt/omniwallet
ENV MCTDEST /opt/mastercoin-tools
ENV DATADIR /opt/omniwallet-data
ENV OBELISK_SERVER tcp://merchantcoin.cloudapp.net:9091
ENV NAME omniwallet

# Load in the sx installer script
ADD install-sx.sh /tmp/
RUN chmod a+x /tmp/install-sx.sh

# add user to run omniwallet
RUN useradd -r $NAME && \
    mkdir /home/$NAME && \
    chown -R $NAME:$NAME /home/$NAME

# Add some needed repos
RUN apt-get -qq update && \
    apt-get -qqy install software-properties-common && \
    add-apt-repository -y ppa:chris-lea/node.js && \
    add-apt-repository -y ppa:nginx/stable && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C7A7DA52

# Update and install dependencies
RUN apt-get -qq update
RUN apt-get -qqy --force-yes install build-essential openssh-server ack-grep htop multitail daemontools tmux supervisor vim git curl libssl-dev make lib32z1-dev pkg-config ant autoconf libtool libboost-all-dev pkg-config libcurl4-openssl-dev libleveldb-dev libzmq-dev libconfig++-dev libncurses5-dev ruby python python-dev python-setuptools python-software-properties python-simplejson python-git python-pip libffi-dev nginx uwsgi uwsgi-plugin-python nodejs

RUN gem install sass --no-ri --no-rdoc && \
    npm install -g forever  && \
    npm install -g grunt-cli && \
    npm install -g less && \
    npm install -g jshint && \
    npm install -g uglify-js && \
    npm install -g bower

# clean up permissions
RUN chown -R $NAME:$NAME ~/.npm && \
    chown -R $NAME:$NAME ~/tmp

#install sx and friends
RUN bash /tmp/install-sx.sh

#Get Omniwallet - might be relevant
RUN mkdir /root/.ssh
ADD docker.key /root/.ssh/docker.key
ADD ssh_config /root/.ssh/config
RUN git clone git@github.com:MerchantCoin/omniwallet.git $DEST
RUN chown -R $NAME:$NAME $DEST
WORKDIR /opt/omniwallet
RUN git checkout mc

# Install various deps and generate things
RUN pip install -r ./requirements.txt

# Config nginx
RUN sed -i "s/\/home\/myUser\/omniwallet\/www/\/opt\/omniwallet\/www/g" $DEST/etc/nginx/sites-available/default && \
    sed -i "s/var\/lib\/omniwallet/opt\/omniwallet-data/g" $DEST/etc/nginx/sites-available/default && \
    cp $DEST/etc/nginx/sites-available/default /etc/nginx/sites-available && \
    sed -i "s/www-data/omniwallet omniwallet;\\ndaemon off/g" /etc/nginx/nginx.conf && \
    sed -i "s/server_name localhost/server_name wallet.merchantcoin.net/g" /etc/nginx/nginx.conf
ADD 74698b06841e.crt /etc/nginx/74698b06841e.crt
ADD server.key /etc/nginx/server.key
ADD gd_bundle-g2-g1.crt /etc/nginx/gd_bundle-g2-g1.crt

# Config datadog
#ADD datadog.conf /etc/dd-agent/datadog.conf
#ADD nginx.yaml /etc/dd-agent/conf.d/nginx.yaml

# Run bower and npm to install more deps and configure things
USER omniwallet
ENV HOME /opt/omniwallet
RUN bower install
RUN npm install
USER root

# Install starter data
#RUN mkdir $DATADIR
#WORKDIR /tmp
#RUN curl -sSO https://www.omniwallet.org/assets/snapshots/current.tar.gz
#RUN tar xzf current.tar.gz -C $DATADIR
#RUN cp -r $DATADIR/www/* $DATADIR/
#RUN rm $DATADIR/revision.json
#RUN chown -R $NAME:$NAME $DATADIR
#RUN rm /tmp/current.tar.gz

RUN echo "service = \""$OBELISK_SERVER"\"" > /home/$NAME/.sx.cfg
RUN mkdir /home/$NAME/.bitcoin
ADD bitcoin.conf /home/$NAME/.bitcoin/bitcoin.conf
RUN chown -R $NAME:$NAME /home/$NAME/.bitcoin && \
    sed -i "s/\/var\/lib\/omniwallet/\/opt\/omniwallet-data/g" $DEST/app.sh && \
    sed -i "s/\/var\/lib\/omniwallet/\/opt\/omniwallet-data/g" $DEST/lib/stats_backend.py && \
    sed -i "s/\/var\/lib\/omniwallet/\/opt\/omniwallet-data/g" $DEST/api/stats.py && \
    sed -i "s/\/var\/lib\/omniwallet/\/opt\/omniwallet-data/g" $DEST/api/pushtx.py && \
    chmod a+x $DEST/app.sh

# configure sshd
RUN mkdir -p /var/run/sshd  && \
    echo "root:pass" | chpasswd && \
    sed -i "s/PermitRootLogin without-password/PermitRootLogin yes/g" /etc/ssh/sshd_config

# Supervisord conf
ADD supervisord.conf /etc/supervisor/conf.d/omni.conf
RUN sed -i "s/var\/log\/supervisor/var\/log/g" /etc/supervisor/supervisord.conf

# add cron job for blockchain parsing
ADD backend_cron.sh /home/omniwallet/backend_cron.sh
RUN chmod a+x /home/omniwallet/backend_cron.sh && \
    echo "*/5 * * * *   omniwallet    /home/omniwallet/backend_cron.sh" >> /etc/crontab

# set up script which runs at startup
ADD kickoff.sh /root/kickoff.sh
RUN chmod a+x /root/kickoff.sh

ADD nginx_offline /root/nginx_offline

EXPOSE 80 443 1088 1091


#CMD []
#ENTRYPOINT ["/usr/bin/supervisord"]
#CMD ["/bin/bash"]
CMD ["/root/kickoff.sh"]
