# scolv-docker
SeisComP scolv GUI utility in a docker container

## Mac install

### Homebrew install

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Docker install

```bash
brew install docker --cask
brew install docker-buildx
```

Start Docker Desktop (Applications folder) : it will start the docker daemon.

## Running Docker container

### Build Docker image

#### On Mac with an Apple Silicon (ARM64) processor

Docker Desktop can use Rosetta 2 to emulate x86_64 images on Apple Silicon Macs. Here's how to enable it :

- Open Docker Desktop.
- Go to Settings > General.
- Enable the option "Use Rosetta for x86/amd64 emulation on Apple Silicon".

Then start building the image :

```bash
docker buildx build -t seiscomp-version6:latest --platform linux/amd64 .
```

#### On Mac with an Intel processor

```bash
docker build -t seiscomp-version6:latest .
```

### Create and start container

#### Simple container without configuration

Create and start a simple container without base configuration :

```bash
docker run -d -p 2222:22 --name scolv seiscomp-version6:latest          
```

#### Pre-configured environment

You can place custom SeisComP configuration files in ./seiscomp/etc/

You can place any folder in ./seiscomp/ and mount it on the container. For example, assuming you have a folder containing the nll configuration and OpenStreetMap maps on your Mac's hard drive in the directory /HOST/PATH/TO/seiscomp/share/, you can create and start a preconfigured container:

```bash
docker run -d -p 2222:22 \
           -v /HOST/PATH/TO/seiscomp/share/nll:/opt/seiscomp/share/nll \
           -v /HOST/PATH/TO/seiscomp/share/maps/OCMap:/opt/seiscomp/share/maps/OCMap \
           --name scolv seiscomp-version6:latest
```

### Connect to container with SSH

```bash
ssh -Y -p 2222 sysop@localhost
```
### Start scolv

```bash
ssh -Y -p 2222 sysop@localhost
```

## Credits

This project was inspired by [Fred Massin](https://github.com/FMassin). Many thanks!!
