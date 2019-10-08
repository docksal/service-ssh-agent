#!/usr/bin/env bash

set -e # Abort if anything fails

# Create the temporary key storage directory
mkdir -p ${SSH_DIR}

# Service mode
if [[ "$1" == "ssh-agent" ]]; then
	# Clean up previous socket files
	rm -f ${SSH_AUTH_SOCK} ${SSH_AUTH_PROXY_SOCK}

	# Create proxy-socket for ssh-agent (to give anyone accees to the ssh-agent socket)
	echo "Creating proxy socket..."
	socat UNIX-LISTEN:${SSH_AUTH_PROXY_SOCK},perm=0666,fork UNIX-CONNECT:${SSH_AUTH_SOCK} &

	# Start ssh-agent
	echo "Launching ssh-agent..."
	exec /usr/bin/ssh-agent -a ${SSH_AUTH_SOCK} -d

# Proxy mode
elif [[ "$1" == "ssh-proxy" ]]; then
	# Clean up previous socket files
	rm -f ${SSH_AUTH_SOCK} ${SSH_AUTH_PROXY_SOCK}

	# Create proxy-socket for TCP target
	tcp_target_ip="$2"
	tcp_target_port="$3"
	exec socat UNIX-LISTEN:${SSH_AUTH_PROXY_SOCK},perm=0666,fork TCP:${tcp_target_ip}:${tcp_target_port}

# Command mode
else
	exec "$@"
fi
