#!/bin/bash

CONTAINER_NAME=jenkins
JENKINS_PORT=8080
JENKINS_PORT_JNLP=50000
JENKINS_PATH_HOST=/data-jenkins

docker pull jenkinsci/blueocean

docker run --detach \
    --name ${CONTAINER_NAME} \
    --user root \
    --publish ${JENKINS_PORT}:8080 \
    --publish ${JENKINS_PORT_JNLP}:50000 \
    --volume ${JENKINS_PATH_HOST}:/var/jenkins_home \
    --volume /var/run/docker.sock:/var/run/docker.sock \
    jenkinsci/blueocean
