#!/bin/bash

CONTAINER_NAME=gitlab-runner
GITLAB_URL=http://10.100.101.22/
GITLAB_TOKEN=8XUMnHw6aVssvrquv4Kx
GITLAB_RUNNER_DESC=gitlab-runner-docker
GITLAB_RUNNER_TAGS=wtt,gj

docker pull gitlab/gitlab-runner

docker run -d \
    --restart always \
    --name ${CONTAINER_NAME} \
    -v /srv/gitlab-runner/config:/etc/gitlab-runner \
    -v /var/run/docker.sock:/var/run/docker.sock \
    gitlab/gitlab-runner:latest

docker run --rm -it \
    ${CONTAINER_NAME} \
    register \
    --non-interactive \
    --executor docker \
    --docker-image alpine:latest \
    --url ${GITLAB_URL} \
    --registration-token ${GITLAB_TOKEN} \
    --description ${GITLAB_RUNNER_DESC} \
    --tag-list ${GITLAB_RUNNER_TAGS} \
    --run-untagged true \
    --locked false \
    --access-level not_protected
