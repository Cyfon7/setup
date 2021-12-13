# Include environment variables from .env
include .env

RAILS_CMD=bin/rails
RAKE_CMD=bin/rake

# Colors
GREEN=\033[0;32m
RED=\033[0;31m
NC=\033[0m # No Color

# If code is executed inside a container
ifneq ($(wildcard /.dockerenv),)
	DOCKER_HOST_IP := $(shell /sbin/ip route|awk '/default/ { print $$3 }')
else
	DOCKER_APP_CONTAINER_ID := $(shell docker ps --filter="name=$(APP_CONTAINER_NAME)" -q)
endif

# Models
scaffold_models:
	$(RAILS_CMD) g scaffold Company \
		name:string{255} \
		address:string{255} \
		location:st_point \
		working_week_days:json;

	$(RAILS_CMD) g scaffold Group \
		name:string{255} \
		description:string{255} \
		address:string{255} \
		location:st_point \
		company:references;

	$(RAILS_CMD) g scaffold Role \
		name:string{255};

	$(RAILS_CMD) g scaffold User \
		first_name:string{255} \
		last_name:string{255} \
		enabled:boolean \
		transportation_type:integer \
		address:string{255} \
		phone_number:string{255} \
		location:st_point \
		role:references \
		company:references;

	$(RAILS_CMD) g scaffold Parameter \
		key:string{255} \
		value:string{255};

	$(RAILS_CMD) g scaffold Campaign \
		name:string{255} \
		description:string{255} \
		date_start:date \
		date_end:date \
		company:references \
		user:references;

	$(RAILS_CMD) g scaffold State \
		name:string{255} \
		description:string{255} \
		company:references;

	$(RAILS_CMD) g scaffold CustomerType \
		name:string{255};

	$(RAILS_CMD) g scaffold Customer \
		name:string{255} \
		address:string{255} \
		phone:string{50} \
		location:st_point \
		working_week_days:json \
		customer_type:references \
		user:references \
		company:references;

	$(RAILS_CMD) g scaffold Scheduling \
		checkin:st_point \
		checkin_at:timestamp \
		comment_info:text \
		comment_visit:text \
		route:geometry \
		date:date \
		time_start:time \
		time_end:time \
		user:references \
		customer:references \
		state:references \
		campaign:references \
		scheduling:references;

	$(RAILS_CMD) g scaffold Segment \
		name:string{255} \
		description:string{255} \
		company:references;

	$(RAILS_CMD) g scaffold Holiday \
		date_start:date \
		date_end:date \
		company:references;

	$(RAILS_CMD) g model UserGroup \
		user:references \
		group:references;

	$(RAILS_CMD) g model CustomerUser \
		customer:references \
		user:references;

	$(RAILS_CMD) g model CustomerSegment \
		customer:references \
		segment:references;

	$(RAILS_CMD) g model CampaignUser \
		campaign:references \
		user:references;

diagram:
	$(RAKE_CMD) diagram:all;

destroy_models:
	$(RAILS_CMD) d scaffold Company;
	$(RAILS_CMD) d scaffold Group;
	$(RAILS_CMD) d scaffold Role;
	$(RAILS_CMD) d scaffold User;
	$(RAILS_CMD) d scaffold Parameter;
	$(RAILS_CMD) d scaffold Campaign;
	$(RAILS_CMD) d scaffold State;
	$(RAILS_CMD) d scaffold CustomerType;
	$(RAILS_CMD) d scaffold Customer;
	$(RAILS_CMD) d scaffold Scheduling;
	$(RAILS_CMD) d scaffold Segment;
	$(RAILS_CMD) d scaffold Holiday;
	$(RAILS_CMD) d model UserGroup;
	$(RAILS_CMD) d model CustomerUser;
	$(RAILS_CMD) d model CustomerSegment;

# Devise
enable_devise:
	$(RAILS_CMD) generate devise:install;
	$(RAILS_CMD) generate devise User;
	$(RAILS_CMD) generate migration add_authentication_token_to_users "authentication_token:string{30}:uniq";

disable_devise:
	$(RAILS_CMD) destroy devise:install;
	$(RAILS_CMD) destroy devise User;

# Policies
scaffold_policies:
	$(RAILS_CMD) g pundit:policy company;
	$(RAILS_CMD) g pundit:policy group;
	$(RAILS_CMD) g pundit:policy role;
	$(RAILS_CMD) g pundit:policy user;
	$(RAILS_CMD) g pundit:policy parameter;
	$(RAILS_CMD) g pundit:policy campaign;
	$(RAILS_CMD) g pundit:policy state;
	$(RAILS_CMD) g pundit:policy customer_type;
	$(RAILS_CMD) g pundit:policy customer;
	$(RAILS_CMD) g pundit:policy scheduling;
	$(RAILS_CMD) g pundit:policy segment;
	$(RAILS_CMD) g pundit:policy holiday;

destroy_policies:
	$(RAILS_CMD) d pundit:policy company;
	$(RAILS_CMD) d pundit:policy droup;
	$(RAILS_CMD) d pundit:policy role;
	$(RAILS_CMD) d pundit:policy user;
	$(RAILS_CMD) d pundit:policy parameter;
	$(RAILS_CMD) d pundit:policy campaign;
	$(RAILS_CMD) d pundit:policy state;
	$(RAILS_CMD) d pundit:policy customer_type;
	$(RAILS_CMD) d pundit:policy customer;
	$(RAILS_CMD) d pundit:policy scheduling;
	$(RAILS_CMD) d pundit:policy segment;
	$(RAILS_CMD) d pundit:policy holiday;

paperclip_models:
	$(RAILS_CMD) g paperclip Scheduling photo;

# Database
create_db:
	# $(RAKE_CMD) db:schema:load;	# Load db schema (Delete and Create empty DB)
	$(RAKE_CMD) db:drop;			# Drop DB
	$(RAKE_CMD) db:create;			# Create DB if doesn't exists
	#$(RAKE_CMD) db:clear;			# Drop tables from environment related db
	$(RAKE_CMD) db:migrate;			# Create tables and relations - Used for version control

clear:
	$(RAKE_CMD) db:clear RAILS_ENV=$(ENV);

migrate:
	$(RAKE_CMD) db:migrate RAILS_ENV=$(ENV);

seed:
	$(RAKE_CMD) db:seed RAILS_ENV=$(ENV);

init: migrate seed
scaffold: scaffold_models paperclip_models scaffold_policies enable_devise
destroy: disable_devise destroy_models destroy_policies
redo: destroy scaffold create_db seed

deploy:
	git push heroku master:master
	heroku run rake db:migrate -a mc-checkin;

deploy_force:
	git push heroku master:master --force
	heroku run rake db:migrate -a mc-checkin;

deploy_staging:
	git push staging dev:master;
	heroku run rake db:migrate -a mc-checkin-staging;

build:
ifeq ($(wildcard /.dockerenv),)
	docker-compose build
endif

run:
ifeq ($(wildcard /.dockerenv),)
	docker-compose up
endif

start:
ifeq ($(wildcard /.dockerenv),)
	docker-compose up -d
endif

stop:
ifeq ($(wildcard /.dockerenv),)
	docker-compose stop
endif

restart:
ifeq ($(wildcard /.dockerenv),)
	docker-compose restart
endif

rm-containers:
ifeq ($(wildcard /.dockerenv),)
	docker rm $(shell docker stop $(APP_CONTAINER_NAME) $(DATABASE_CONTAINER_NAME) $(REDIS_CONTAINER_NAME) $(WORKERS_CONTAINER_NAME))
endif

clean-images:
ifeq ($(wildcard /.dockerenv),)
	docker rmi $(shell docker images -q -f "dangling=true")
endif

rebuild:
	(${MAKE} rm-containers || ${MAKE} clean-images || true) && ${MAKE} build

enter:
	docker exec -it $(APP_CONTAINER_NAME) /bin/bash -l

enter-db:
	docker exec -it $(DATABASE_CONTAINER_NAME) /bin/bash -l

enter-wk:
	docker exec -it $(WORKERS_CONTAINER_NAME) /bin/bash -l

enter-rd:
	docker exec -it $(REDIS_CONTAINER_NAME) /bin/bash -l

status:
ifeq ($(wildcard /.dockerenv),)
ifeq ($(DOCKER_APP_CONTAINER_ID),)
	@echo "$(RED)APP container is not running$(NC)"
else
	@echo "$(GREEN)APP container is running$(NC)"
endif
endif

s: server
server: start
ifeq ($(wildcard /.dockerenv),)
	docker exec -it $(APP_CONTAINER_NAME) /bin/bash -l -c "make server";
else
	TRUSTED_IP=$(DOCKER_HOST_IP) RAILS_ENV=$(ENV) $(RAILS_CMD) s -b 0.0.0.0 -p 3000 #TRUSTED_IP=$(DOCKER_HOST_IP) RAILS_ENV=$(ENV) bundle exec puma -b tcp://0.0.0.0 -p 3000
	
endif

wk: worker
worker: start
ifeq ($(wildcard /.dockerenv),)
	docker exec -it $(WORKERS_CONTAINER_NAME) /bin/bash -l -c "make worker";
else
	TRUSTED_IP=$(DOCKER_HOST_IP) RAILS_ENV=$(ENV) bundle exec rake jobs:work
endif

c: console
console: start
ifeq ($(wildcard /.dockerenv),)
	docker exec -it $(APP_CONTAINER_NAME) /bin/bash -l -c "make console";
else
	TRUSTED_IP=$(DOCKER_HOST_IP) RAILS_ENV=$(ENV) $(RAILS_CMD) c
endif

b: bundle
bundle: start
ifeq ($(wildcard /.dockerenv),)
	docker exec -it $(APP_CONTAINER_NAME) /bin/bash -l -c "make script";
else
	/bin/bash -l -c /etc/my_init.d/0000_init_container.sh;
endif