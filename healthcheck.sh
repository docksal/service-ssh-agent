#!/usr/bin/env bash

netstat -nlp | grep -E "LISTENING.*${SSH_AUTH_PROXY_SOCK}" >/dev/null || exit 1
netstat -nlp | grep -E "LISTENING.*${SSH_AUTH_SOCK}" >/dev/null || exit 1

exit 0
