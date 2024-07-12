# =============================================
# SHELL
# =============================================
SHELL 					:= /bin/bash

# =============================================
# VARIABLES
# =============================================
SRC_FOLDER				:= srcs
REQ_FOLDER				:= requirements
CERT_FOLDER				:= certificates
TOOLS_FOLDER			:= tools
DATA_FOLDER				:= data
VOLUME_FOLDER			:= volumes
export REQ_FOLDER CERT_FOLDER

REQ_DIR					:= $(SRC_FOLDER)/$(REQ_FOLDER)
CERT_DIR				:= $(REQ_DIR)/$(CERT_FOLDER)
CERT_MAKEFILE_PATH		:= $(REQ_DIR)/$(TOOLS_FOLDER)/$(CERT_FOLDER)
export CERT_DIR

ENV_FILE 				:= .env
ENV_TEMPLATE_FILE		:= .env.template
ENV_PATH 				:= $(SRC_FOLDER)/$(ENV_FILE)
ENV_TEMPLATE_PATH		:= $(SRC_FOLDER)/$(ENV_TEMPLATE_FILE)
export ENV_FILE

VOLUME_DIR				:= $(HOME)/$(DATA_FOLDER)/$(VOLUME_FOLDER)
MARIADB_VOLUME_DIR		:= $(VOLUME_DIR)/mariadb
WORDPRESS_VOLUME_DIR	:= $(VOLUME_DIR)/wordpress
WEBSITE_VOLUME_DIR		:= $(VOLUME_DIR)/website
MONITOR_VOLUME_DIR		:= $(VOLUME_DIR)/monitor
export VOLUME_DIR

NAME					:= .inception
HOSTS_PATH				:= /etc/hosts
HOSTFILE_SETUP			:= .hostfile_setup

export DOMAIN

# =============================================
# ENVIRONMENT VARIABLE FOR DOCKER COMPOSE
# =============================================
export COMPOSE_FILE		:= $(SRC_FOLDER)/docker-compose.yml

# =============================================
# GENERAL RULES
# =============================================
all: $(NAME)

$(NAME): check_env set_certificate set_hosts
	@mkdir -p $(MARIADB_VOLUME_DIR) $(WORDPRESS_VOLUME_DIR) $(WEBSITE_VOLUME_DIR) $(MONITOR_VOLUME_DIR)
	docker compose up --build -d

clean:
	docker compose down --rmi all --volumes --remove-orphans
	make -C $(CERT_MAKEFILE_PATH) clean

fclean:
	make clean
	docker system prune --all --volumes --force
	@make -C $(CERT_MAKEFILE_PATH) fclean
	sudo rm -rf $(VOLUME_DIR)
	rm -f $(NAME)

re:
	make fclean
	make all

.PHONY: all clean fclean re

# =============================================
# SETUP
# =============================================
check_env:
	$(info Checking $(ENV_FILE) file...)
	@if [ ! -f $(ENV_PATH) ]; then \
		echo "Setting up $(ENV_FILE) file..."; \
		cp $(ENV_TEMPLATE_PATH) $(ENV_PATH); \
		while IFS= read -u9 -r line; do \
			if [[ $$line =~ ^\#.* ]] || [[ $$line =~ ^\s*$$ ]]; then \
				continue; \
			else \
				key=$$(echo $$line | cut -d '=' -f 1); \
				if [ ! -z $$(echo $$line | cut -d '=' -f 2) ]; then \
					continue; \
				fi; \
				read -r -p "    Enter value for $$key: " value; \
				sed -i'' "s/$$key=.*/$$key=$$value/g" $(ENV_PATH); \
			fi \
		done 9< $(ENV_TEMPLATE_PATH); \
		echo "Successfully created $(ENV_FILE) file."; \
	fi
	@echo "Checking $(ENV_FILE) file...Done."

set_hosts: $(HOSTFILE_SETUP)

$(HOSTFILE_SETUP):
	$(info Setting up $(HOSTS_PATH) file to access $(DOMAIN)...)
	@if [ ! -f $(HOSTFILE_SETUP) ]; then \
		sudo chmod 777 $(HOSTS_PATH); \
		sudo echo "127.0.0.1 $(DOMAIN)" >> $(HOSTS_PATH); \
		touch $@; \
	fi
	@echo "Setting up $(HOSTS_PATH) file to access $(DOMAIN)...Done."

set_certificate:
	@if [ ! -d $(CERT_DIR) ]; then \
		mkdir $(CERT_DIR); \
	fi
	$(eval DOMAIN := $(shell grep '^DOMAIN=' $(ENV_PATH) | cut -d '=' -f2))
	$(info Checking certificate for $(DOMAIN)...)
	@echo "Setting up certificate for $(DOMAIN)...";
	make -C $(CERT_MAKEFILE_PATH) all;
	@echo "Successfully created certificate.";
	@echo "Checking certificate for $(DOMAIN)...Done."

.PHONY: check_env set_hosts set_certificate

# =============================================
# DOCKER MONITORING
# =============================================
status: ps images volume network top

.PHONY: status

ps logs images top:
	docker compose $@

.PHONY: ps logs images top 

network volume:
	docker $@ ls

.PHONY: network volume
