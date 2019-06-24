#!/usr/bin/env bash
set -eo pipefail

netstat -nlp | grep -qE "LISTENING.*${SSH_AUTH_PROXY_SOCK}"
if [[ "$DOCKSAL_SSH_AGENT_USE_HOST" != "1" ]]; then
	netstat -nlp | grep -qE "LISTENING.*${SSH_AUTH_SOCK}"
fi
