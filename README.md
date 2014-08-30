Docker container for Omniwallet Port
====================================

This project sets up a Docker container to run an Omniwallet instance. There is currently a fair amount of configuration in here which is specific to my environment, so please go through the various config files carefully.

This container is set up to write logs and the wallet data to directories mounted from the host. That way they are not lost when the container quits and can be monitored/backed up.


Build Image
===========
git clone https://github.com/peterloron/ow_docker
cd ow_docker
docker build -t mcwallet .


Run Image
=========
docker run -h wallet.merchantcoin.net -p 80:80 -p 443:443 -p 2222:22 -v /home/peterl/stlog:/var/log -v /opt/omniallet-data:/opt/omniwallet-data mcwallet

Be sure to adjust your hostname and mount points according to your environment.


More docs to come.
