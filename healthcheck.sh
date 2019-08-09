#!/usr/bin/env bash
set -eo pipefail

# Get the name of the process with pid=1
docker_cmd=$(cat /proc/1/comm)

# Health checks for ssh-agent mode
if [[ "${docker_cmd}" == "ssh-agent" ]]; then
	netstat -nlp | grep -qE "LISTENING.*${SSH_AUTH_PROXY_SOCK}"
	netstat -nlp | grep -qE "LISTENING.*${SSH_AUTH_SOCK}"
fi

# Health checks for ssh-proxy mode
if [[ "${docker_cmd}" == "socat" ]]; then
	netstat -nlp | grep -qE "LISTENING.*${SSH_AUTH_PROXY_SOCK}"
fi
