# FROM phusion/passenger-customizable:0.9.21
FROM phusion/passenger-ruby22:0.9.21

# Set correct environment variables
ENV HOME /root
ENV APP_HOME /home/app/webapp

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# #   Ruby support
# RUN /pd_build/ruby-2.2.5.sh
# #   Node.js and Meteor standalone support.
# #   (not needed if you already have the above Ruby support)
# RUN /pd_build/nodejs.sh

# PG Client, backup database
RUN apt-get update && apt-get install -y postgresql-client-9.5
RUN gem install backup -v 4.2.3

# NodeJS y bower global
RUN apt-get update && apt-get install -y nodejs npm && npm -g install bower@1.7.9

# Geospatial libraries
RUN apt-get update && apt-get install -y binutils libgeos-3.5.0 libgeos-dev libproj-dev libproj9

# Imagemagick
RUN apt-get update && apt-get install -y libmagickwand-dev libmagickcore-dev imagemagick && gem install rmagick -v 2.15.4

#Graphviz for Railroady
RUN apt-get update && apt-get install -y graphviz

# Workdir for bundle and bower
WORKDIR /home/app/webapp/

# Add files
ADD . /home/app/webapp/

# Change /home/app/webapp owner to user app
RUN chown -R app:app /home/app/webapp/

# Enable ssh and insecure key permanently (development)
RUN rm -f /etc/service/sshd/down
RUN /usr/sbin/enable_insecure_key

# Add init scripts
ADD docker/my_init.d/*.sh /etc/my_init.d/
# Ensure premissions to execute and Unix newlines
RUN chmod +x /etc/my_init.d/*.sh && sed -i 's/\r$//' /etc/my_init.d/*.sh

# Ensure permission to execute and Unix newlines on bin files
RUN chmod +x /home/app/webapp/bin/* && sed -i 's/\r$//' /home/app/webapp/bin/*

# Clean up APT when done
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /var/tmp/*