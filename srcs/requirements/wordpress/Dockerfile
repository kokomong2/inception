# Dockerfile is made up of series of commands, each of which represents a layer in the final image.

# Context: files and directories in the Dockerfile's directory. (Inception/srcs/requirements/wordpress/)
# The context is the set of files at a specified location PATH or URL.
# Every files and directories in the Dockerfile's directory are sent to Docker daemon as context.
# Therefore, it is strongly recommended create a .dockerignore file in the Dockerfile's directory to exclude unnecessary files and directories.

# [FROM]
# Choose the base image for the build process, with FROM command.
# The base image is the first layer in the Dockerfile and it is the image that all subsequent layers are built upon.
# In Docker, a container is an image with a read-write layer on top of read-only layer.
FROM alpine:3.19.0

# [ENV]
# Set environment variables. These variables are available in Dockerfile and Container.
# Priority of environment variables: docker-compose.yml > Shell environment variables > Value from environment file > Value from Dockerfile
#
# usage:
# ENV <key> <value>
# ENV <key1>=<value1> <key2>=<value2>...
# ENV <key1>=<value1> --default <key2>=<value2>...
ENV SERVICE_USER=www

# [RUN]
# Execute a command in a new layer on top of the current image and commit the results.
# RUN command is used to install packages, update the system, create directories, etc.
#
# It can be written in two ways: shell form and exec form.
# By default, the shell form is used through /bin/sh -c interpreter.
# exec form is executed as a direct exec call, so environment variables are not expanded.
#
# usage:
# - Shell form: RUN <command>
#               RUN yum -y install nginx
# - Exec form:  RUN ["executable", "param1", "param2"]
#               RUN ["yum", "-y", "install", "nginx"]
#               RUN ["/bin/sh", "-c", "yum -y install nginx"]
#
# The exec form is the preferred form as it is more explicit regarding the command and it prevents some issues, such as PATH being reset.
# Because RUN command is a layer, it is recommended to chain the RUN command to reduce the number of layers.
#
# [apk]
# Alpine Linux package management tool.
# apk update: update the index of available packages.
# apk upgrade: upgrade the installed packages to the latest available versions.
# apk add: install packages.
# apk --no-cache: do not cache the index locally. (It is recommended to use --no-cache option when installing packages to keep the image lightweight.)
#     By doing so, we don't need to remove the cache manually. (rm -rf /var/cache/apk/*)
RUN apk upgrade --no-cache &&                           \
    apk add --no-cache  curl                            \
                        php81                           \
                        php81-curl                      \
                        php81-phar                      \
                        php81-fpm                       \
                        php81-mysqli                    \
                        php81-iconv                     \
                        php81-tokenizer                 \
                        mariadb-client                  \
                        redis                           \
                        fcgi &&                         \
    adduser -u 1000 -D -h /var/www ${SERVICE_USER} &&   \
    chown -R ${SERVICE_USER}:${SERVICE_USER} /var/www

# [WORKDIR]
# Changes the directory in which the following instructions are executed, just like cd in a shell.
# RUN, CMD, ENTRYPOINT, COPY and ADD instructions that follow it in the Dockerfile will be executed in the new working directory.
WORKDIR /var/www

# [ADD]
# Copy files or directories from the context to the filesystem of the container.
# ADD command is similar to COPY command, but it has some additional features.
# ADD command can copy files from remote URL, and it can extract TAR files automatically.
#
# usage:
# ADD [--chown=<user>:<group>] <src>... <dest>
# ADD [--chown=<user>:<group>] ["<src>",... "<dest>"] (this form is required for paths containing whitespace)
ADD --chmod=755 https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar /usr/local/bin/wp

# [COPY]
# Copy files or directories from the context to the filesystem of the container.
#
# usage:
# COPY [--chown=<user>:<group>] <src>... <dest>
# COPY [--chown=<user>:<group>] ["<src>",... "<dest>"] (this form is required for paths containing whitespace)
COPY --chmod=644 conf/www.conf /etc/php81/php-fpm.d/www.conf
COPY --chmod=755 tools/entrypoint.sh /

# [ENTRYPOINT]
# CMD and ENTRYPOINT are used to specify the command that will be executed when a container is started.
# Set the primary command to always run when the container starts.
# Additional commands and arguments can be added after ENTRYPOINT command.
# Cannot be overridden by command line arguments (docker run -it <image> <command>).
#
# usage:
# ENTRYPOINT ["executable", "param1", "param2"]
ENTRYPOINT ["/entrypoint.sh"]

# [EXPOSE]
# Inform Docker that the container listens on the specified network ports at runtime.
# EXPOSE command does not make the ports of the container accessible to the host. (It is done by -p option of docker run command.)
# It is used to document which ports are used, and it is used when linking containers together.
# EXPOSE 9000

# [VOLUME]
# Create a mount point with the specified name and mark it as holding externally mounted volumes from native host or other containers.
# Since Docker containers are stateless, the data inside the container will be lost when the container is removed. To persist the data, we need to use volumes.
# VOLUME command is used to share data between the host and the container.
# VOLUME ["/var/www"]

# [STOPSGINAL]
# Set the system call signal that will be sent to the container to exit.
# The default signal is SIGTERM.
# When command 'docker container stop' is executed, the container will receive SIGTERM signal.
# If the container does not exit after a grace period (default: 10s), it will receive SIGKILL signal.
#
# (KNOWN ISSUE)
# When using unix socket through nginx, Docker daemon send SIGTERM signal to the container,
#        resulting nginx to stop and disconnect all the conneections, causing unclean shutdown.
# https://github.com/nginxinc/docker-nginx/issues/167
# https://github.com/nginxinc/docker-nginx/issues/377
STOPSIGNAL SIGQUIT

# [HEALTHCHECK]
# Check the health of the running container.
# If a healthcheck is specified in the Dockerfile, it will be executed automatically when the container is started.
# ONLY ONE healthcheck can be specified in the Dockerfile. If multiple healthchecks are specified, only the last one will take effect.
# HEALTHCHECK status can be queried by command 'docker container inspect <container>' or 'docker container ls'.
#
# Exit codes:
# 0: success
# 1: unhealthy
# 2: reserved (do not use this exit code)
#
# usage:
# HEALTHCHECK [OPTIONS] CMD command (check container health by running a command inside the container)
# HEALTHCHECK NONE (disable any healthcheck inherited from the base image)
# HEALTHCHECK --interval=10s --start-period=5s --timeout=3s --retries=3 CMD cgi-fcgi -bind -connect localhost:9000 || exit 1

# [ARG]
# Set build-time variables. These variables are only available in Dockerfile.
#
# usage:
# ARG <name>[=<default value>]
# ARG <name1>=<value1> <name2>=<value2>...
# ARG <name1>=<value1> --default <name2>=<value2>...

# [USER]
# Set the user name or UID to use when running the image.
# The user can be specified by either its name or UID.
# If the user does not exist, it will be created.
# If the user is not specified, the image will be run as root.
#
# usage:
# USER <user>[:<group>]
# USER <UID>[:<GID>]
# USER ${SERVICE_USER}
