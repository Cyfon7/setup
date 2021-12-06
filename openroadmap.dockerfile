FROM phusion/passenger-ruby26

# Passenger setup
ENV HOME /root

CMD ["/sbin/my_init"]

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# OS setup
RUN apt-get update -qq && apt-get install -y postgresql-client

WORKDIR /openroadmap

# User setup
USER openroadmap

RUN chown -R openroadmap:openroadmap /openroadmap

# Rails setup
COPY Gemfile /openroadmap/Gemfile

COPY Gemfile.lock /openroadmap/Gemfile.lock

RUN bundle install

CMD ["rails", "db:create"]

# Entrypoint
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

# Run Server
CMD ["rails", "server", "-b", "0.0.0.0"]