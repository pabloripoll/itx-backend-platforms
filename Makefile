# This Makefile requires GNU Make.
MAKEFLAGS += --silent

# Settings
ifeq ($(strip $(OS)),Windows_NT) # is Windows_NT on XP, 2000, 7, Vista, 10...
    DETECTED_OS := Windows
	C_BLU=''
	C_GRN=''
	C_RED=''
	C_YEL=''
	C_END=''
else
    DETECTED_OS := $(shell uname) # same as "uname -s"
	C_BLU='\033[0;34m'
	C_GRN='\033[0;32m'
	C_RED='\033[0;31m'
	C_YEL='\033[0;33m'
	C_END='\033[0m'
endif

include .env

ROOT_DIR=$(patsubst %/,%,$(dir $(realpath $(firstword $(MAKEFILE_LIST)))))
DIR_BASENAME=$(shell basename $(ROOT_DIR))

# -------------------------------------------------------------------------------------------------
#  Help
# -------------------------------------------------------------------------------------------------
.PHONY: help

help: ## shows this Makefile help message
	echo "Usage: $$ make "${C_GRN}"[target]"${C_END}
	echo ${C_GRN}"Targets:"${C_END}
	awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9_-]+:.*?## / {printf "$$ make \033[0;33m%-30s\033[0m %s\n", $$1, $$2}' ${MAKEFILE_LIST} | column -t -c 2 -s ':#'

# -------------------------------------------------------------------------------------------------
#  System
# -------------------------------------------------------------------------------------------------
.PHONY: local-info local-ownership local-ownership-set

local_ip ?= $(word 1,$(shell hostname -I))
local-info: ## shows local machine ip and container ports set
	echo ${C_BLU}"Local IP / Hostname:"${C_END} ${C_YEL}"$(local_ip)"${C_END}

user ?= ${USER}
group ?= root
local-ownership: ## shows local ownership
	echo $(user):$(group)

local-ownership-set: ## sets recursively local root directory ownership
	$(SUDO) chown -R ${user}:${group} $(ROOT_DIR)/

# -------------------------------------------------------------------------------------------------
#  Network
# -------------------------------------------------------------------------------------------------
.PHONY: network-create network-inspect network-restart

network-create: ## creates network
	$(DOCKER) network create $(PROJECT_LEAD)-$(PROJECT_CNET)

network-inspect: ## inspects network
	$(DOCKER) network inspect $(PROJECT_LEAD)-$(PROJECT_CNET)

network-restart: ## restart containers inside network
	$(DOCKER) network inspect $(PROJECT_LEAD)-$(PROJECT_CNET) --format '{{range .Containers}}{{.Name}} {{end}}'

# -------------------------------------------------------------------------------------------------
#  Services
# -------------------------------------------------------------------------------------------------
.PHONY: services-set services-create services-info services-start services-stop services-destroy

services-set: ## sets all container services
	$(MAKE) apirest-set grafana-set k6-set influxdb-set simulado-set

services-create: ## builds and starts up all container services
	$(MAKE) apirest-create grafana-create k6-create influxdb-create simulado-create

services-info: ## shows all container services information
	$(MAKE) apirest-info grafana-info k6-info influxdb-info simulado-info

services-start: ## starts all container services
	$(MAKE) apirest-start grafana-start k6-start influxdb-start simulado-start

services-stop: ## stops all container services
	$(MAKE) apirest-stop grafana-stop k6-stop influxdb-stop simulado-stop

services-restart: ## restarts all container services
	$(MAKE) apirest-restart grafana-restart k6-restart influxdb-restart simulado-restart

services-destroy: ## destroys all container services
	$(MAKE) apirest-destroy grafana-destroy k6-destroy influxdb-destroy simulado-destroy

# -------------------------------------------------------------------------------------------------
#  Backend API Service
# -------------------------------------------------------------------------------------------------
.PHONY: apirest-hostcheck apirest-info apirest-set apirest-create apirest-network apirest-ssh apirest-start apirest-stop apirest-destroy

apirest-hostcheck: ## shows this project ports availability on local machine for apirest container
	cd platforms/$(APIREST_PLTF) && $(MAKE) port-check

apirest-info: ## shows the apirest docker related information
	cd platforms/$(APIREST_PLTF) && $(MAKE) info

apirest-set: ## sets the apirest enviroment file to build the container
	cd platforms/$(APIREST_PLTF) && $(MAKE) env-set

apirest-create: ## creates the apirest container from Docker image
	cd platforms/$(APIREST_PLTF) && $(MAKE) build up

apirest-network: ## creates the apirest container network - execute this recipe first before others
	$(MAKE) apirest-stop
	cd platforms/$(APIREST_PLTF) && $(DOCKER_COMPOSE) -f docker-compose.yml up -d

apirest-ssh: ## enters the apirest container shell
	cd platforms/$(APIREST_PLTF) && $(MAKE) ssh

apirest-start: ## starts the apirest container running
	cd platforms/$(APIREST_PLTF) && $(MAKE) start

apirest-stop: ## stops the apirest container but its assets will not be destroyed
	cd platforms/$(APIREST_PLTF) && $(MAKE) stop

apirest-restart: ## restarts the running apirest container
	cd platforms/$(APIREST_PLTF) && $(MAKE) restart

apirest-destroy: ## destroys completly the apirest container
	echo ${C_RED}"Attention!"${C_END};
	echo ${C_YEL}"You're about to remove the "${C_BLU}"$(APIREST_PLTF)"${C_END}" container and delete its image resource."${C_END};
	@echo -n ${C_RED}"Are you sure to proceed? "${C_END}"[y/n]: " && read response && if [ $${response:-'n'} != 'y' ]; then \
        echo ${C_GRN}"K.O.! container has been stopped but not destroyed."${C_END}; \
    else \
		cd platforms/$(APIREST_PLTF) && $(MAKE) stop clear destroy; \
		echo -n ${C_GRN}"Do you want to clear DOCKER cache? "${C_END}"[y/n]: " && read response && if [ $${response:-'n'} != 'y' ]; then \
			echo ${C_YEL}"The following command is delegated to be executed by user:"${C_END}; \
			echo "$$ $(DOCKER) system prune"; \
		else \
			$(DOCKER) system prune; \
			echo ${C_GRN}"O.K.! DOCKER cache has been cleared up."${C_END}; \
		fi \
	fi

# -------------------------------------------------------------------------------------------------
#  Grafana Service
# -------------------------------------------------------------------------------------------------
.PHONY: grafana-hostcheck grafana-info grafana-set grafana-create grafana-network grafana-ssh grafana-start grafana-stop grafana-destroy

grafana-hostcheck: ## shows this project ports availability on local machine for container
	cd platforms/$(GRAFANA_PLTF) && $(MAKE) port-check

grafana-info: ## shows the docker related information
	cd platforms/$(GRAFANA_PLTF) && $(MAKE) info

grafana-set: ## sets the enviroment file to build the container
	cd platforms/$(GRAFANA_PLTF) && $(MAKE) env-set

grafana-create: ## creates the container from Docker image
	cd platforms/$(GRAFANA_PLTF) && $(MAKE) build up

grafana-network: ## creates the container network - execute this recipe first before others
	$(MAKE) grafana-stop
	cd platforms/$(GRAFANA_PLTF) && $(DOCKER_COMPOSE) -f docker-compose.yml up -d

grafana-ssh: ## enters the container shell
	cd platforms/$(GRAFANA_PLTF) && $(MAKE) ssh

grafana-start: ## starts the container running
	cd platforms/$(GRAFANA_PLTF) && $(MAKE) start

grafana-stop: ## stops the container but its assets will not be destroyed
	cd platforms/$(GRAFANA_PLTF) && $(MAKE) stop

grafana-restart: ## restarts the running container
	cd platforms/$(GRAFANA_PLTF) && $(MAKE) restart

grafana-destroy: ## destroys completly the container
	echo ${C_RED}"Attention!"${C_END};
	echo ${C_YEL}"You're about to remove the "${C_BLU}"$(GRAFANA_PLTF)"${C_END}" container and delete its image resource."${C_END};
	@echo -n ${C_RED}"Are you sure to proceed? "${C_END}"[y/n]: " && read response && if [ $${response:-'n'} != 'y' ]; then \
        echo ${C_GRN}"K.O.! container has been stopped but not destroyed."${C_END}; \
    else \
		cd platforms/$(GRAFANA_PLTF) && $(MAKE) stop clear destroy; \
		echo -n ${C_GRN}"Do you want to clear DOCKER cache? "${C_END}"[y/n]: " && read response && if [ $${response:-'n'} != 'y' ]; then \
			echo ${C_YEL}"The following command is delegated to be executed by user:"${C_END}; \
			echo "$$ $(DOCKER) system prune"; \
		else \
			$(DOCKER) system prune; \
			echo ${C_GRN}"O.K.! DOCKER cache has been cleared up."${C_END}; \
		fi \
	fi

# -------------------------------------------------------------------------------------------------
#  Grafana K6 Service
# -------------------------------------------------------------------------------------------------
.PHONY: k6-hostcheck k6-info k6-set k6-create k6-network k6-ssh k6-start k6-stop k6-destroy

k6-hostcheck: ## shows this project ports availability on local machine for container
	cd platforms/$(K6_PLTF) && $(MAKE) port-check

k6-info: ## shows the docker related information
	cd platforms/$(K6_PLTF) && $(MAKE) info

k6-set: ## sets the enviroment file to build the container
	cd platforms/$(K6_PLTF) && $(MAKE) env-set

k6-create: ## creates the container from Docker image
	cd platforms/$(K6_PLTF) && $(MAKE) build up

k6-network: ## creates the container network - execute this recipe first before others
	$(MAKE) k6-stop
	cd platforms/$(K6_PLTF) && $(DOCKER_COMPOSE) -f docker-compose.yml up -d

k6-ssh: ## enters the container shell
	cd platforms/$(K6_PLTF) && $(MAKE) ssh

k6-start: ## starts the container running
	cd platforms/$(K6_PLTF) && $(MAKE) start

k6-stop: ## stops the container but its assets will not be destroyed
	cd platforms/$(K6_PLTF) && $(MAKE) stop

k6-restart: ## restarts the running container
	cd platforms/$(K6_PLTF) && $(MAKE) restart

k6-destroy: ## destroys completly the container
	echo ${C_RED}"Attention!"${C_END};
	echo ${C_YEL}"You're about to remove the "${C_BLU}"$(K6_PLTF)"${C_END}" container and delete its image resource."${C_END};
	@echo -n ${C_RED}"Are you sure to proceed? "${C_END}"[y/n]: " && read response && if [ $${response:-'n'} != 'y' ]; then \
        echo ${C_GRN}"K.O.! container has been stopped but not destroyed."${C_END}; \
    else \
		cd platforms/$(K6_PLTF) && $(MAKE) stop clear destroy; \
		echo -n ${C_GRN}"Do you want to clear DOCKER cache? "${C_END}"[y/n]: " && read response && if [ $${response:-'n'} != 'y' ]; then \
			echo ${C_YEL}"The following command is delegated to be executed by user:"${C_END}; \
			echo "$$ $(DOCKER) system prune"; \
		else \
			$(DOCKER) system prune; \
			echo ${C_GRN}"O.K.! DOCKER cache has been cleared up."${C_END}; \
		fi \
	fi

# -------------------------------------------------------------------------------------------------
#  InfluxDB Service
# -------------------------------------------------------------------------------------------------
.PHONY: influxdb-hostcheck influxdb-info influxdb-set influxdb-create influxdb-network influxdb-ssh influxdb-start influxdb-stop influxdb-destroy

influxdb-hostcheck: ## shows this project ports availability on local machine for container
	cd platforms/$(INFLUXDB_PLTF) && $(MAKE) port-check

influxdb-info: ## shows the docker related information
	cd platforms/$(INFLUXDB_PLTF) && $(MAKE) info

influxdb-set: ## sets the enviroment file to build the container
	cd platforms/$(INFLUXDB_PLTF) && $(MAKE) env-set

influxdb-create: ## creates the container from Docker image
	cd platforms/$(INFLUXDB_PLTF) && $(MAKE) build up

influxdb-network: ## creates the container network - execute this recipe first before others
	$(MAKE) influxdb-stop
	cd platforms/$(INFLUXDB_PLTF) && $(DOCKER_COMPOSE) -f docker-compose.yml up -d

influxdb-ssh: ## enters the container shell
	cd platforms/$(INFLUXDB_PLTF) && $(MAKE) ssh

influxdb-start: ## starts the container running
	cd platforms/$(INFLUXDB_PLTF) && $(MAKE) start

influxdb-stop: ## stops the container but its assets will not be destroyed
	cd platforms/$(INFLUXDB_PLTF) && $(MAKE) stop

influxdb-restart: ## restarts the running container
	cd platforms/$(INFLUXDB_PLTF) && $(MAKE) restart

influxdb-destroy: ## destroys completly the container
	echo ${C_RED}"Attention!"${C_END};
	echo ${C_YEL}"You're about to remove the "${C_BLU}"$(INFLUXDB_PLTF)"${C_END}" container and delete its image resource."${C_END};
	@echo -n ${C_RED}"Are you sure to proceed? "${C_END}"[y/n]: " && read response && if [ $${response:-'n'} != 'y' ]; then \
        echo ${C_GRN}"K.O.! container has been stopped but not destroyed."${C_END}; \
    else \
		cd platforms/$(INFLUXDB_PLTF) && $(MAKE) stop clear destroy; \
		echo -n ${C_GRN}"Do you want to clear DOCKER cache? "${C_END}"[y/n]: " && read response && if [ $${response:-'n'} != 'y' ]; then \
			echo ${C_YEL}"The following command is delegated to be executed by user:"${C_END}; \
			echo "$$ $(DOCKER) system prune"; \
		else \
			$(DOCKER) system prune; \
			echo ${C_GRN}"O.K.! DOCKER cache has been cleared up."${C_END}; \
		fi \
	fi

# -------------------------------------------------------------------------------------------------
#  Simulado Service
# -------------------------------------------------------------------------------------------------
.PHONY: simulado-hostcheck simulado-info simulado-set simulado-create simulado-network simulado-ssh simulado-start simulado-stop simulado-destroy

simulado-hostcheck: ## shows this project ports availability on local machine for container
	cd platforms/$(SIMULADO_PLTF) && $(MAKE) port-check

simulado-info: ## shows the docker related information
	cd platforms/$(SIMULADO_PLTF) && $(MAKE) info

simulado-set: ## sets the enviroment file to build the container
	cd platforms/$(SIMULADO_PLTF) && $(MAKE) env-set

simulado-create: ## creates the container from Docker image
	cd platforms/$(SIMULADO_PLTF) && $(MAKE) build up

simulado-network: ## creates the container network - execute this recipe first before others
	$(MAKE) simulado-stop
	cd platforms/$(SIMULADO_PLTF) && $(DOCKER_COMPOSE) -f docker-compose.yml up -d

simulado-ssh: ## enters the container shell
	cd platforms/$(SIMULADO_PLTF) && $(MAKE) ssh

simulado-start: ## starts the container running
	cd platforms/$(SIMULADO_PLTF) && $(MAKE) start

simulado-stop: ## stops the container but its assets will not be destroyed
	cd platforms/$(SIMULADO_PLTF) && $(MAKE) stop

simulado-restart: ## restarts the running container
	cd platforms/$(SIMULADO_PLTF) && $(MAKE) restart

simulado-destroy: ## destroys completly the container
	echo ${C_RED}"Attention!"${C_END};
	echo ${C_YEL}"You're about to remove the "${C_BLU}"$(SIMULADO_PLTF)"${C_END}" container and delete its image resource."${C_END};
	@echo -n ${C_RED}"Are you sure to proceed? "${C_END}"[y/n]: " && read response && if [ $${response:-'n'} != 'y' ]; then \
        echo ${C_GRN}"K.O.! container has been stopped but not destroyed."${C_END}; \
    else \
		cd platforms/$(SIMULADO_PLTF) && $(MAKE) stop clear destroy; \
		echo -n ${C_GRN}"Do you want to clear DOCKER cache? "${C_END}"[y/n]: " && read response && if [ $${response:-'n'} != 'y' ]; then \
			echo ${C_YEL}"The following command is delegated to be executed by user:"${C_END}; \
			echo "$$ $(DOCKER) system prune"; \
		else \
			$(DOCKER) system prune; \
			echo ${C_GRN}"O.K.! DOCKER cache has been cleared up."${C_END}; \
		fi \
	fi

# -------------------------------------------------------------------------------------------------
#  Repository Helper
# -------------------------------------------------------------------------------------------------
.PHONY: repo-flush repo-commit

repo-flush: ## echoes clearing commands for git repository cache on local IDE and sub-repository tracking remove
	echo ${C_YEL}"Clear repository for untracked files:"${C_END}
	echo ${C_YEL}"$$"${C_END}" git rm -rf --cached .; git add .; git commit -m \"maint: cache cleared for untracked files\""
	echo ""
	echo ${C_YEL}"Platform repository against REST API repository:"${C_END}
	echo ${C_YEL}"$$"${C_END}" git rm -r --cached -- \"apirest/*\" \":(exclude)apirest/.gitkeep\""

repo-commit: ## echoes common git commands
	echo ${C_YEL}"Common commiting commands:"${C_END}
	echo ${C_YEL}"$$"${C_END}" git add . && git commit -m \"feat: ... \""
	echo ""
	echo ${C_YEL}"For fixing pushed commit comment:"${C_END}
	echo ${C_YEL}"$$"${C_END}" git commit --amend"
	echo ${C_YEL}"$$"${C_END}" git push --force origin [branch]"
