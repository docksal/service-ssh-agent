#!/usr/bin/env bats

# Debugging
teardown() {
	echo
	echo "Output:"
	echo "================================================================"
	echo "${output}"
	echo "================================================================"
}

# To work on a specific test:
# run `export SKIP=1` locally, then comment skip in the test you want to debug

@test "ssh-agent container is up and using the \"${IMAGE}\" image" {
	[[ ${SKIP} == 1 ]] && skip

	run docker ps --filter "name=docksal-ssh-agent" --format "{{ .Image }}"
	[[ "$output" =~ "$IMAGE" ]]
	unset output
}

@test "fin ssh-key add" {
	[[ ${SKIP} == 1 ]] && skip

	# Generate a key
	ssh_key_name="ssh_agent_test_id_rsa"
	ssh_key_file="${HOME}/.ssh/${ssh_key_name}"
	rm -f ${ssh_key_file}
	ssh-keygen -t rsa -b 4096 -f ${ssh_key_file} -q -N ""

	# Add the key to the agent
	run fin ssh-key add ${ssh_key_name}
	# Cleanup garbage \r from the output otherwise there won't be an exact match
	[[ "$(echo ${output} | tr -d '\r')" == "Identity added: ${ssh_key_name} (${ssh_key_name})" ]]
	unset output

	# Check they key is present in the agent
	run fin ssh-key add -l
	[[ ${output} == *${ssh_key_name}* ]]
	unset output

	# Cleanup
	rm -f ${ssh_key_file}
}
