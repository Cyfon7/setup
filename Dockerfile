FROM phusion/passenger-ruby26

# LABEL Name=openroadmap Version=0.0.1

# # CMD ["/sbin/my_init"]

# # RUN useradd -ms /bin/bash openroadmap

# # Update OS, packages & install postgresql-client
# # Remove cache
# RUN apt-get update && apt-get install -y \
#   postgresql-client \
#   && rm -rf /var/lib/apt/lists/* /tmp/* /var/temp/*

# RUN gem install rails -v 5.2.6

# # USER openroadmap
# WORKDIR /openroadmap
# # RUN chown -R openroadmap .

# # throw errors if Gemfile has been modified since Gemfile.lock
# RUN bundle config --global frozen 1

# # COPY Gemfile Gemfile.lock ./
# # COPY ./config/database.yml ./config/database.yml
# COPY . .
# RUN bundle install


# EXPOSE 3000

# CMD ["rails", "server"]


# FROM ruby:2.5
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client
WORKDIR /myapp
COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock
RUN bundle install
COPY . .
# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

# Configure the main process to run when running the image
CMD ["rails", "server", "-b", "0.0.0.0"]