# scolv-docker
SeisComP scolv GUI utility in a docker container

## Mac install

### Homebrew install

```bash
$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Docker install

```bash
$ brew install docker --cask
```
## Running Docker container

### Build Docker image

```bash
$ docker build -t seiscomp-version6:latest .
```

### Start container

```bash
$ docker run -d --name -p 2222:22 scolv seiscomp-version6:latest
```

### Connect to container with SSH

docker run -d --name scolv -p 2222:22 seiscomp-version6:latest
