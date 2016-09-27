# Docker SSH Agent for Docksal

## How to use

### 0. Build 

```
docker build -t docksal/ssh-agent:stable -f Dockerfile .
```

### 1. Run a long-lived container 

```
docker run -d --name=ssh-agent docksal/ssh-agent:stable
```

### 2. Add your ssh keys

Run a temporary container with volume mounted from host that includes your SSH keys. SSH key id_rsa will be added to ssh-agent (you can replace id_rsa with your key name):

```
docker run --rm --volumes-from=ssh-agent -v ~/.ssh:/root/.ssh -it docksal/ssh-agent:stable ssh-add /root/.ssh/id_rsa
```

### 3. Delete all ssh keys from ssh-agent

Run a temporary container and delete all known keys from ssh-agent:

```
docker run --rm --volumes-from=ssh-agent -it docksal/ssh-agent:stable ssh-add -D
```

### 4. Add ssh-agent socket to other container:

Use two options for running your container:

```
  volumes_from:
    - ssh-agent
  environment:
    - SSH_AUTH_SOCK=/.ssh-agent/socket
```

It works only for root user. ssh-agent socket is accessible only to the user which started this agent or for root user. So other users don't have access to /.ssh-agent/socket. If you have another user (for example docker) in your container, do next things:
- install 'socat' utility in your container
- make proxy-socket in your conatainer:
```
sudo socat UNIX-LISTEN:~/.ssh/socket,fork UNIX-CONNECT:/.ssh-agent/socket &
```
- change owner for this proxy-socket
```
sudo chown $(id -u) ~/.ssh/socket
```
- you need use different SSH_AUTH_SOCK for this user:
```
SSH_AUTH_SOCK=~/.ssh/socket
```
