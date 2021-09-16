# Taken from https://www.github.com/jenkinsci/docker-ssh-agent
FROM openjdk:11-jdk-buster

ARG JENKINS_AGENT_HOME=/root
ARG JENKINS_AGENT_WORK_DIR=/var/jenkins

ENV JENKINS_AGENT_HOME ${JENKINS_AGENT_HOME}
ENV JENKINS_AGENT_WORK_DIR ${JENKINS_AGENT_WORK_DIR}

# Configure time zone information which is needed for some packages.
# Install SSH, docker and a few tools.
RUN truncate -s0 /tmp/preseed.cfg \
    && (echo "tzdata tzdata/Areas select Etc" >> /tmp/preseed.cfg) \
    && (echo "tzdata tzdata/Zones select UTC" >> /tmp/preseed.cfg) \
    && debconf-set-selections /tmp/preseed.cfg \
    && rm -f /etc/timezone /etc/localtime \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true apt-get install -y tzdata \
    && apt-get update \
    && apt-get install --no-install-recommends -y openssh-server wget docker-compose \
    && apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release build-essential \
    && curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update \
    && apt-get install --no-install-recommends -y docker-ce-cli \
    && rm -rf /var/lib/apt/lists/*

# Setup SSH
RUN sed -i /etc/ssh/sshd_config \
    -e 's/#RSAAuthentication.*/RSAAuthentication yes/'  \
    -e 's/#PasswordAuthentication.*/PasswordAuthentication no/' \
    -e 's/#SyslogFacility.*/SyslogFacility AUTH/' \
    -e 's/#LogLevel.*/LogLevel INFO/' \
    && mkdir /var/run/sshd

VOLUME "${JENKINS_AGENT_HOME}" "/tmp" "/run" "/var/run"
WORKDIR "${JENKINS_AGENT_HOME}"

RUN echo "PATH=${PATH}" >> /etc/environment
COPY setup-sshd /usr/local/bin/setup-sshd
RUN chmod 550 /usr/local/bin/setup-sshd

EXPOSE 22

ENTRYPOINT ["setup-sshd"]
