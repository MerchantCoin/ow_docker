Docker container for Omniwallet
===================================

This project sets up a Docker container to run an Omniwallet instance. There is currently a fair amount of configuration in here which is specific to my environment, so please go through the various config files carefully.



docker run -p 80:80 -p 2222:22 -v /home/peterl/stlog:/var/log -v /opt/omniallet-data:/opt/omniwallet-data suptest


More docs to come.
