#!/bin/bash

GITLAB_ADDR=10.100.101.222
GITLAB_PORT=80
GITLAB_PORT_SSL=443
GITLAB_PORT_SSH=22022
CONTAINER_NAME=gitlab
GITLAB_PATH_HOST=/srv/gitlab
GITLAB_PATH_BACKUP=/var/opt/gitlab/backups

docker pull gitlab/gitlab-ce

docker run --detach \
    --hostname ${GITLAB_ADDR} \
    --publish ${GITLAB_PORT}:80 --publish ${GITLAB_PORT_SSL}:443 --publish ${GITLAB_PORT_SSH}:22 \
    --name ${CONTAINER_NAME} \
    --restart always \
    --volume ${GITLAB_PATH_HOST}"/config":/etc/gitlab \
    --volume ${GITLAB_PATH_HOST}"/logs":/var/log/gitlab \
    --volume ${GITLAB_PATH_HOST}"/data":/var/opt/gitlab \
    gitlab/gitlab-ce:latest

echo "" >> ${GITLAB_PATH_HOST}"/config/gitlab.rb"
echo "external_url 'http://${GITLAB_ADDR}:${GITLAB_PORT}'" >> ${GITLAB_PATH_HOST}"/config/gitlab.rb"
echo "gitlab_rails['gitlab_ssh_host'] = '${GITLAB_ADDR}'" >> ${GITLAB_PATH_HOST}"/config/gitlab.rb"
echo "gitlab_rails['gitlab_shell_ssh_port'] = ${GITLAB_PORT_SSH}" >> ${GITLAB_PATH_HOST}"/config/gitlab.rb"
echo "gitlab_rails['backup_path'] = '${GITLAB_PATH_BACKUP}'" >> ${GITLAB_PATH_HOST}"/config/gitlab.rb"

docker restart ${CONTAINER_NAME}
