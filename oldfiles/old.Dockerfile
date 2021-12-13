# FROM phusion/passenger-ruby26:1.0.17
FROM phusion/passenger-ruby26:2.0.1

LABEL Name=openroadmap Version=0.0.1

ARG USER_ID
ARG GROUP_ID
RUN addgroup --gid $GROUP_ID user
RUN adduser --disabled-password --gecos '' --uid $USER_ID --gid $GROUP_ID user

ENV INSTALL_PATH /openroadmap
RUN mkdir -p $INSTALL_PATH

WORKDIR $INSTALL_PATH
RUN chown -R user:user $INSTALL_PATH
# RUN chown -R user:user /usr/local/rvm/gems/ruby-2.6.7
RUN chown -R user:user /usr/local/rvm/gems/ruby-2.6.8

# RUN gem install rails bundler
RUN gem install bundler
COPY Gemfile ./Gemfile
COPY Gemfile.lock ./Gemfile.lock

# USER $USER_ID
RUN bundle install

# CMD ["/bin/sh"]


# Old commands

# RUN apt-get update -qq && apt-get install -y nodejs postgresql-client
# WORKDIR /openroadmap
# COPY Gemfile ./Gemfile
# COPY Gemfile.lock ./Gemfile.lock
# RUN gem install rails bundler
# RUN bundle install

# Add a script to be executed every time the container starts.
# COPY entrypoint.sh /usr/bin/
# RUN chmod +x /usr/bin/entrypoint.sh
# ENTRYPOINT ["entrypoint.sh"]

# Old commands end

EXPOSE 3000

# USER $USER_ID

# Configure the main process to run when running the image
CMD ["rails", "server", "-b", "0.0.0.0"]


