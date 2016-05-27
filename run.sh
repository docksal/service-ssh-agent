#!/bin/sh

case "$1" in
	ssh-agent)
		# Create proxy-socket for ssh-agent (to give anyone accees to the ssh-agent socket)
		echo "Creating proxy socket..."
		rm ${SSH_AUTH_SOCK} ${SSH_AUTH_PROXY_SOCK} > /dev/null 2>&1
		socat UNIX-LISTEN:${SSH_AUTH_PROXY_SOCK},perm=0666,fork UNIX-CONNECT:${SSH_AUTH_SOCK} &
		echo "Launching ssh-agent..."
		exec /usr/bin/ssh-agent -a ${SSH_AUTH_SOCK} -d
		;;
	*)
		exec $@;;
esac
