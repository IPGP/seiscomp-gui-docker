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
```
## Running Docker container

### Build Docker image

```bash
docker build -t seiscomp-version6:latest .
```

### On Mac with an Apple Silicon (ARM64) processor (NOT TESTED YET)

Docker Desktop can use Rosetta 2 to emulate x86_64 images on Apple Silicon Macs. Here's how to enable it:

- Open Docker Desktop.
- Go to Settings > General.
- Enable the option "Use Rosetta for x86/amd64 emulation on Apple Silicon".

### Start container

```bash
docker run -d -p 2222:22 \
           -v /HOST/PATH/TO/seiscomp/share/nll:/INSTALL_DIR/share/nll \
           -v /HOST/PATH/TO/seiscomp/share/maps/OCMap:/INSTALL_DIR/share/maps/OCMap \
           --name scolv seiscomp-version6:latestdocker run -d -p 2222:22 --name mon_conteneur seiscomp-version6:latest
```

### Connect to container with SSH

```bash
ssh -p 2222 sysop@localhost
```

## Credits

This project was inspired by [Fred Massin](https://github.com/FMassin). Many thanks!!
