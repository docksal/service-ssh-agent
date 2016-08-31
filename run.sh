#!/bin/sh

# Print a debug message if debug mode is on ($DEBUG is not empty)
# @param message
debug_msg ()
{
	if [ -n "$DEBUG" ]; then
		echo "$@"
	fi
}

case "$1" in
	# Start ssh-agent
	ssh-agent)
		# Create proxy-socket for ssh-agent (to give anyone accees to the ssh-agent socket)
		echo "Creating proxy socket..."
		rm ${SSH_AUTH_SOCK} ${SSH_AUTH_PROXY_SOCK} > /dev/null 2>&1
		socat UNIX-LISTEN:${SSH_AUTH_PROXY_SOCK},perm=0666,fork UNIX-CONNECT:${SSH_AUTH_SOCK} &
		echo "Launching ssh-agent..."
		# Start ssh-agent
		exec /usr/bin/ssh-agent -a ${SSH_AUTH_SOCK} -d
		;;
	# Manage SSH identities
	ssh-add)
		shift # remove argument from the array

		# .ssh folder from host is expected to be mounted on /.ssh
		# We copy keys from there into /root/.ssh and fix permissions (necessary on Windows hosts) 
		host_ssh_path="/.ssh"
		if [ -d $host_ssh_path ]; then
			debug_msg "Copying host SSH keys and setting propper permissions..."
			cp -a $host_ssh_path/. ~/.ssh/
			chmod 700 ~/.ssh
			chmod 600 ~/.ssh/*
			chmod 644 ~/.ssh/*.pub
		fi
		
		# Make sure the key existis if provided.
		# Otherwise we may be getting an argumet, which we'll handle late.
		# When $ssh_key_path is empty, ssh-agent will be looking for both id_rsa and id_dsa in the home directory.
		ssh_key_path=""
		if [ -n "$1" ] && [ -f "/root/.ssh/$1" ]; then
			ssh_key_path="/root/.ssh/$1"
			shift # remove argument from the array
		fi

		# Calling ssh-add. This should handle all arguments cases.
		_command="ssh-add $ssh_key_path $@"
		debug_msg "Executing: $_command"
		# When $key_path is empty, ssh-agent will be looking for both id_rsa and id_dsa in the home directory.
	 	# We do a sed hack here to strip out '/root/.ssh' from the key path in the output from ssh-add, since this path may confuse people.
		# echo "Press ENTER or CTRL+C to skip entering passphrase (if any)."
		# We store and return exit code from the first command (there is no $PIPESTATUS in sh...)
		exec $_command 2>&1 || ret=$? | sed 's/\/root\/.ssh\///g'
		return $ret
		;;
	*)
		exec $@
		;;
esac
