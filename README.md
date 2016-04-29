# docker-ssh-agent
 
Docker SSH Agent

## How to use

### 0. Build 

```console
docker build -t blinkreaction/docker-ssh-agent:latest -f Dockerfile .
```

### 1. Run a long-lived container 

```console
docker run -d --name=ssh-agent blinkreaction/docker-ssh-agent:latest
```

### 2. Add your ssh keys

Run a temporary container with volume mounted from host that includes your SSH keys. SSH key id_rsa will be added to ssh-agent (you can replace id_rsa with your key name):

```console
docker run --rm --volumes-from=ssh-agent -v ~/.ssh:/root/.ssh -it blinkreaction/docker-ssh-agent:latest ssh-add /root/.ssh/id_rsa
```

### 3. Delete all ssh keys from ssh-agent

Run a temporary container and delete all known keys from ssh-agent:

```console
docker run --rm --volumes-from=ssh-agent -it blinkreaction/docker-ssh-agent:latest ssh-add -D
```

### 4. Add ssh-agent socket to other container:

Use two options for running your container:

```console
  volumes_from:
    - ssh-agent
  environment:
    - SSH_AUTH_SOCK=/sshagent/socket
```

It works only for root user. Ssh-agent socket is accessible only to the user which started this agent or for root user. So other users don't have access to /sshagent/socket. If you have another user (for example docker) in your container, do next things:
- install 'socat' utility in your container
- make proxy-socket in your conatainer:
```console
sudo socat UNIX-LISTEN:/home/docker/.ssh/docker,fork UNIX-CONNECT:/sshagent/socket &
```
- change owner for this proxy-socket
```console
sudo chown docker /home/docker/.ssh/docker
```
- you need use different SSH_AUTH_SOCK for this user:
```console
SSH_AUTH_SOCK=/home/docker/.ssh/docker
```
