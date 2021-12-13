#!/bin/bash

install_ruby_gems () {
  # Bundle install only if dependencies are not satisfied
  echo "Installing ruby gems..."
  bundle check || bundle install --jobs 4 --retry 6
}

# Do somethin
echo "Init app..."
install_ruby_gems

# Ok
echo "################################"
echo "#                              #"
echo "#    APP CONTAINER IS READY    #"
echo "#                              #"
echo "################################"
echo "User: $APP_USER"
echo "Home: $HOME"

# Starting Server
echo "Starting Server......"
bundle exec puma