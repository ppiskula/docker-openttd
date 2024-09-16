# OpenTTD Server in Docker

Built from OpenTTD source to provide the leanest, meanest image you'll come across for putting trainsets in containers.

## Build
### Clone the repository
```bash
git clone https://github.com/ppiskula/docker-openttd.git
```
```bash
cd docker-openttd
```
### Build the image
```bash
docker build -t ppiskula/openttd-server:latest .
```

## Usage
### Simple run
```bash
docker run --rm -it -p 3979:3979/tcp -p 3979:3979/udp ppiskula/openttd-server:latest
```

### Detached run with persistant state
```bash
docker run -name openttd-server -p 3979:3979/tcp -p 3979:3979/udp -v <path_on_host>:/config -e loadgame='exit' -d ppiskula/openttd-server:latest
```

You'll probably want stuff to be persistant between container rebuilds, so we've got the `/config` volume for exactly that purpose.

```
-v <path_on_host>:/config
```

The container is set by default to start a fresh game every time you restart the container. You can, however, change this behaviour with the `loadgame` envvar:
```
-e loadgame='{false|last-autosave|exit|(savename)}'
```
where:
* false: standard behaviour, just start a new game
* last-autosave: load the last chronological autosave
* exit: try to load autosave/exit.sav, otherwise default to a new game
* (savename): full name of a save file in config/saves

---
&copy; 2024 Patrycja "P4tka" Piskuła fork based on [ropenttd/docker_openttd](https://github.com/ropenttd/docker_openttd) &middot; Licensed under GNU GPL v3