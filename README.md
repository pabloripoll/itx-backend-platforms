# ITX BACKEND PLATFORMS

- [Exam Objetives](./resources/docs/Objetives.md)
- [Platforms Set Up](#platforms-set-up)
- [Platforms Structure](#platforms-structure)
- [REST API Installation](#rest-api-installation)

## <a id="platforms-set-up"></a>Platforms set up

Read the `.env.example` comments that explains the variable usage target so building all the containers required can be automated.

- Copy `.env.example` *(or the `.env.example-clean`)* to `.env` and adjust platforms settings (rest api port, grafana port, k6 port, container RAM usage, etc.). The example environment file has already tested the minimum required resources

- By default, your local machine port 5000 will be used for the project as it is required by the exam. The other ports are editable.
<br>

### Automation by Makefile

There is a make recipe that helps you to find out each recipe content bounded to its platform
```sh
$ make help

Usage: $ make [target]
Targets:
$ make help                           shows this Makefile help message
$ make local-info                     shows local machine ip and container ports set
$ make local-ownership                shows local ownership
$ make local-ownership-set            sets recursively local root directory ownership

$ make services-set                   sets all container services
$ make services-create                builds and starts up all container services
$ make services-info                  shows all container services information
$ make services-start                 starts all container services
$ make services-stop                  stops all container services
$ make services-destroy               destroys all container services

$ make apirest-hostcheck              shows this project ports availability on local machine for apirest container
$ make apirest-info                   shows the apirest docker related information
$ make apirest-set                    sets the apirest enviroment file to build the container
$ make apirest-create                 creates the apirest container from Docker image
$ make apirest-network                creates the apirest container network - execute this recipe first before others
$ make apirest-ssh                    enters the apirest container shell
$ make apirest-start                  starts the apirest container running
$ make apirest-stop                   stops the apirest container but its assets will not be destroyed
$ make apirest-restart                restarts the running apirest container
$ make apirest-destroy                destroys completly the apirest container

$ make grafana-hostcheck              shows this project ports availability on local machine for container
$ make grafana-info                   shows the docker related information
$ make grafana-set                    sets the enviroment file to build the container
$ make grafana-create                 creates the container from Docker image
$ make grafana-network                creates the container network - execute this recipe first before others
$ make grafana-ssh                    enters the container shell
$ make grafana-start                  starts the container running
$ make grafana-stop                   stops the container but its assets will not be destroyed
$ make grafana-restart                restarts the running container
$ make grafana-destroy                destroys completly the container

$ make k6-hostcheck                   shows this project ports availability on local machine for container
$ make k6-info                        shows the docker related information
$ make k6-set                         sets the enviroment file to build the container
$ make k6-create                      creates the container from Docker image
$ make k6-network                     creates the container network - execute this recipe first before others
$ make k6-ssh                         enters the container shell
$ make k6-start                       starts the container running
$ make k6-stop                        stops the container but its assets will not be destroyed
$ make k6-restart                     restarts the running container
$ make k6-destroy                     destroys completly the container
$ make k6-tests-run                   runs the tests in container # run the E2E tests

$ make influxdb-hostcheck             shows this project ports availability on local machine for container
$ make influxdb-info                  shows the docker related information
$ make influxdb-set                   sets the enviroment file to build the container
$ make influxdb-create                creates the container from Docker image
$ make influxdb-network               creates the container network - execute this recipe first before others
$ make influxdb-ssh                   enters the container shell
$ make influxdb-start                 starts the container running
$ make influxdb-stop                  stops the container but its assets will not be destroyed
$ make influxdb-restart               restarts the running container
$ make influxdb-destroy               destroys completly the container

$ make simulado-hostcheck             shows this project ports availability on local machine for container
$ make simulado-info                  shows the docker related information
$ make simulado-set                   sets the enviroment file to build the container
$ make simulado-create                creates the container from Docker image
$ make simulado-network               creates the container network - execute this recipe first before others
$ make simulado-ssh                   enters the container shell
$ make simulado-start                 starts the container running
$ make simulado-stop                  stops the container but its assets will not be destroyed
$ make simulado-restart               restarts the running container
$ make simulado-destroy               destroys completly the container

$ make repo-flush                     echoes clearing commands for git repository cache on local IDE and sub-repository tracking remove
$ make repo-commit                    echoes common git commands
```

Once you set all the `.env` variables, it is needed to execute the following for each platform because each of them need an `.env` before create the container service. E.g.:
```sh
$ make services-set
```

Or, you can set each platform variables individually to set its `.env`. E.g.:
```sh
$ make grafana-set
```

Before building the containers, create the Docker shared network
```sh
$ make network-create
# See the network created
$ make network-inspect
```

Now, you can build and run all the containers
```sh
$ make services-create
```

To know each container information you can execute `$ make services-info` *(except k6 container that is not continuously running)* or by each container, as e.g. the API:
```sh
$ make apirest-info
ITX BACKEND EXAM: NGINX + JAVA 21
Container ID.: 511116ee3c94
Name.........: itx-pr-api-dev
Image........: itx-pr-api-dev:alpine3.23-nginx-java21
CPUs.........: 2.00
RAM..........: 256M
SWAP.........: 512M
Host.........: 127.0.0.1:6500
Hostname.....: 192.168.1.41:6500
Docker.Host..: 172.20.0.2
NetworkID....: 2fc4830a1b14ea222ac786bd68b51d429233121c6bb1fc1ce8862e3e3cbb539e
```

Once the container are built, restart the shared network
```sh
$ make network-restart
# See the network updated
$ make network-inspect
```

To follow the project evaluation, follow the REST API README.md, once the repository has been cloned, inside the `./apirest` directory.

Don't forget to follow the REST API cloning repository documentation: [REST API Installation](#rest-api-installation)
<br><br>

## <a id="platforms-structure"></a>Use this Platform Repository for your own REST API repositories

Repository directories structure overview:
```bash
.
├── apirest         # Core directory binded in Docker main container for back-end
│   └── ...         # sub-module or detach with the real project respository
│
├── platforms
│   ├── grafana-8.1
│   │   ├── Makefile
│   │   └── docker
│   │       ├── .env
│   │       ├── .env.sample
│   │       ├── config
│   │       │   ├── dashboards
│   │       │   │   ├── dashboard.yml
│   │       │   │   └── performance-test-dasboard.json
│   │       │   └── datasources
│   │       │       └── datasource.yml
│   │       └── docker-compose.yaml
│   ├── influxdb-1.8
│   │   ├── Makefile
│   │   └── docker
│   │       ├── .env
│   │       ├── .env.sample
│   │       └── docker-compose.yaml
│   ├── k6-0.28
│   │   ├── Makefile
│   │   └── docker
│   │       ├── .env
│   │       ├── .env.sample
│   │       ├── config
│   │       │   └── test.js
│   │       └── docker-compose.yaml
│   ├── nginx-java-21
│   │   ├── LICENSE
│   │   ├── Makefile
│   │   ├── README.md
│   │   └── docker
│   │       ├── .dockerignore
│   │       ├── .env
│   │       ├── .env.example
│   │       ├── .gitignore
│   │       ├── Dockerfile
│   │       ├── Dockerfile.JDK
│   │       ├── Dockerfile.JRE
│   │       ├── config
│   │       │   ├── crontab
│   │       │   ├── java
│   │       │   │   ├── conf.d
│   │       │   │   │   └── .gitkeep
│   │       │   │   └── conf.d-sample
│   │       │   │       └── default.conf
│   │       │   ├── nginx
│   │       │   │   ├── conf.d
│   │       │   │   │   ├── .gitkeep
│   │       │   │   │   └── default.conf  # required to expose the API
│   │       │   │   ├── conf.d-sample
│   │       │   │   │   └── default.conf
│   │       │   │   └── nginx.conf
│   │       │   ├── ownerships.sh
│   │       │   └── supervisor
│   │       │       ├── conf.d
│   │       │       │   ├── .gitkeep
│   │       │       │   ├── java-dev.conf # required to expose the API
│   │       │       │   ├── java-jar.conf # required to expose the API JAR
│   │       │       │   └── nginx.conf    # required to expose the API on designated port
│   │       │       ├── conf.d-sample
│   │       │       │   ├── java-dev.conf
│   │       │       │   ├── java-jar.conf
│   │       │       │   └── nginx.conf
│   │       │       └── supervisord.conf
│   │       ├── docker-compose.network.yml
│   │       └── docker-compose.yml
│   └── simulado
│       ├── Makefile
│       └── docker
│           ├── .env
│           ├── .env.sample
│           ├── config
│           │   └── mocks.json
│           └── docker-compose.yaml
│
├── resources
│   ├── apirest         # rest api backup script
│   ├── automation
│   │   ├── local
│   │   │   ├── Makefile
│   │   │   └── Makefile.child
│   │   └── remote
│   │       └── ...
│   ├── databases
│   │   └── ...
│   └── docs
│       └── images
│           └── ...
│
├── .env          # Platforms main values applied
├── .env.example  # Platforms main values example
├── Makefile      # Automated commands into recipes
└── README.md
```
<br>

## <a id="rest-api-installation"></a>Managing the `apirest` as Detached Repository

Here’s a step-by-step guide for using this Platform repository along with the REST API repository. The approach applied to manage the REST API project is as detached repository in other to separate the concernes of back-end from platform maintenance.

#### **GIT Detached Repository (Recommended)**

> Git commands can be executed **whether from inside the container or on the local machine**.

- Remove `apirest` from local and git cache:
  ```bash
  $ git rm -r --cached -- "apirest/*" ":(exclude)apirest/.gitkeep"
  $ git clean -fd
  $ git reset --hard
  $ git commit -m "Remove apirest directory and its default installation"
  ```

- Clone the desired repository as a detached repository:
  ```bash
  $ git clone https://github.com/pabloripoll/itx-backend-rest-api ./apirest
  ```

- The `apirest` directory is now an **independent repository**, not tracked as a submodule in your main repo. You can use `git` commands freely inside `apirest` from anywhere.
<br>

#### **Summary Table**

| Approach         | Repo independence | Where to run git commands  | Use case                              |
|------------------|------------------|-----------------------------|---------------------------------------|
| Submodule        | Tracked by main  | Inside container            | Main repo controls rest api version   |
| Detached (rec.)  | Fully independent| Local or container          | Maximum flexibility                   |

> **Note**: After new project cloned inside `./apirest`, consider adding `./apirest/.gitkeep` in it to prevent accidental tracking *(especially for detached repository)*.

<br>

## License

This project is open-sourced under the [Apache license](LICENSE).

<!-- FOOTER -->
<br>

---

<br>