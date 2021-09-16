# jenkins-docker-agent

Jenkins docker and ssh agent with docker cli installed.

This allows you start an agent that will be able to run commands in docker installed on the local host instance.

## Run the container

```sh
# Adding to a export just to make the command shorter
export JENKINS_PUBLIC_KEY="ssh-rsa AAAAxxxx"

# Run image
# Mount docker socket
# Optionally you can also mount these directories for data persistance.
# "/home/jenkins" "/tmp" "/run" "/var/run"
docker run \
-d \
--rm \
--name jenkins-agent \
-v /var/run/docker.sock:/var/run/docker.sock \
-v /var/jenkins:/var/jenkins \
-p 23:22 \
-e "JENKINS_AGENT_SSH_PUBKEY=$JENKINS_PUBLIC_KEY" \
morfien101/jenkins-ssh-docker:latest
```
## Docker socket

Generally this image will be run on a server where you have control of the docker socket. To gain access to the socket the container creates a group called `docker` and allocates group id `998`. This can be override while building the image. Your docker socket needs to have read and write `group permission number 6` for group id `998`. If it doesn't you will need to build the build the container with the correct ID using build arg `docker_gid` and your group id number. Or change it via a shell script of some kind.

## Special mentions

The initial source for this project comes from the Jenkins project. See: (Jenkins)[https://github.com/jenkinsci/docker-ssh-agent]