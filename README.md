[![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/adripo/minecraft-server-forge?style=flat-square)](https://github.com/adripo/minecraft-server-forge/releases)
[![Docker Pulls](https://img.shields.io/docker/pulls/adripo/minecraft-server-forge?style=flat-square)](https://hub.docker.com/r/adripo/minecraft-server-forge)
[![Docker Image Size (latest semver)](https://img.shields.io/docker/image-size/adripo/minecraft-server-forge?style=flat-square)](https://hub.docker.com/r/adripo/minecraft-server-forge/tags)
[![GitHub Workflow Status](https://img.shields.io/github/workflow/status/adripo/minecraft-server-forge/publish-dockerhub?style=flat-square)](https://github.com/adripo/minecraft-server-forge/actions?workflow=publish-dockerhub)

![Minecraft Forge](https://files.minecraftforge.net/static/images/logo.svg)


# About

Minecraft Server Forge wrapped in a Docker image.

## Version Tags

This image provides various versions that are available via tags.

| Tag             | Alternative tags      | Description                                                   |
|-----------------|-----------------------|---------------------------------------------------------------|
| `1.18.1-39.1.2` | `1.18.1`, `1.18`, `1` | Minecraft server version _1.18.1_<br/> Forge version _39.1.2_ |


## Usage

Here are some example snippets to help you get started creating a container.

### docker-compose (recommended, [click here for more info](https://docs.linuxserver.io/general/docker-compose))

> **NOTE:** You can find a docker-compose [example](https://github.com/adripo/minecraft-server-forge/tree/main/example) in this repository.\
> It uses a `.env` file with all the main variables that can be changed.

This is an example without the `.env` file:
```yaml
services:
  server:
    container_name: mc-forge
    image: adripo/minecraft-server-forge:1.18.1
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/London
      - JVM_XMS=2G
      - JVM_XMX=8G
      - STOP_TIMEOUT=600
      - MC_online_mode=false
    ports:
      - 25565:25565
    volumes:
      - /path/to/data:/data
    stop_grace_period: 600s
    restart: unless-stopped
```

#### Image update

```bash
docker-compose pull
docker-compose up -d
```

#### Stop container

```bash
docker-compose down
```

### docker cli ([click here for more info](https://docs.docker.com/engine/reference/commandline/cli/))

```bash
docker run -d \
  --name=mc-forge \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Europe/London \
  -e JVM_XMS=2G \
  -e JVM_XMX=8G \
  -e STOP_TIMEOUT=600 \
  -e MC_online_mode=false \
  -p 25565:25565 \
  -v /path/to/data:/data \
  --stop_grace_period: 600s
  --restart unless-stopped \
  lscr.io/linuxserver/nextcloud
```

#### Stop container

To stop the container remember to use `--time` option [s] for a graceful stop:

```bash
docker stop \
  --time=600 \
  mc-forge
```


## Parameters

| Parameter                  | Function                                        |
|----------------------------|-------------------------------------------------|
| -p `25565`:`25565`         | Bind `host_port`:`container_port`               |
| -v `/path/to/data`:`/data` | Bind host `path/do/data` with container `/data` |

### Environment variables

| Env Variable       | Default Value | Function                                                                                                                                                                                                                                                                                                                                                 |
|--------------------|---------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| PUID               | 1000          | UserID used to access shared volumes on host (see below)                                                                                                                                                                                                                                                                                                 |
| PGID               | 1000          | GroupID  used to access shared volumes on host (see below)                                                                                                                                                                                                                                                                                               |
| TZ                 | UTC           | Time zone to use (eg. Europe/London)                                                                                                                                                                                                                                                                                                                     |
| JVM_XMS            | -             | Java JVM `-Xms` parameter used for initial memory allocation pool.<br/>_Example:_<br/>`JVM_XMS=1G` will set `-Xms1G`                                                                                                                                                                                                                                     |
| JVM_XMX            | -             | Java JVM `-Xmx` parameter used for the maximum memory allocation pool.<br/>_Example:_<br/>`JVM_XMX=4G` will set `-Xmx4G`                                                                                                                                                                                                                                 |
| JVM_EXTRA          | -             | Extra JVM parameters if you need special configurations. The args must be space-seprated (` `).<br/>_Example:_<br/>`-XX:ParallelGCThreads=4` if your CPU has got 4 threads.                                                                                                                                                                              |
| STOP_TIMEOUT       | 0             | Timeout duration until server stops gracefully (suggested: 600s) <br/> **_NOTE:_** Remember to set the same value for `stop_grace_period`                                                                                                                                                                                                                |
| ACCEPT_EULA        | false         | Automatically accept Minecraft eula on new config.<br/> If `false` the server will continuously restart until eula is accepted manually by editing `eula.txt` file in data directory                                                                                                                                                                     |
| MC_[custom_option] | -             | Set custom option in `server.properties`.<br/> **_NOTE:_ every option must be written with `_` instead of`-`, but will be automatically converted to apply the correct property.**<br/>_Example:_<br/>- `MC_online_mode=false` will set `online-mode=false` in `server.properties`<br/>- `MC_level_name=custom-world` will set `level-name=custom-world` |

> `STOP_TIMEOUT` is the maximum time the Minecraft server is allowed to process the `save` command (save the world) and stop gracefully.


## User / Group Identifiers

When using volumes (`-v` flags) permissions issues can arise between the host OS and the container. To avoid this issue you can specify the user `PUID` and group `PGID`.

Ensure any volume directories on the host are owned by the same user you specify and any permissions issues will vanish like magic.

In this instance `PUID=1000` and `PGID=1000`. To find yours use `id user` as below:

```bash
$ id username
  uid=1000(dockeruser) gid=1000(dockergroup) groups=1000(dockergroup)
```


## Supported Architectures

The architectures supported by this image are:

| Architecture      | Latest tag        |
|-------------------|-------------------|
| `x86-64`          | [version]         |


## Custom commands to server

To execute a command in the minecraft server you need to use the following:
> docker exec -u abc `CONTAINER_NAME` sh -c "echo '`/COMMAND`' > in"


Example:
```bash
docker exec -u abc mc-forge sh -c "echo '/give PlayerName minecraft:water_bucket 1' > in"
```

The output will be visible with:
```bash
docker logs -n 10 mc-forge
```


## Manual Build
```
source build.env
DATE_NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

docker build \
    --no-cache \
    --pull \
    -t adripo/${MC_NAME}:${MC_VERSION} \
    --build-arg BUILDTIME=${DATE_NOW} \
    $(cat build.env | sed -e 's/#.*//' -e 's/[ ^I]*$//' -e '/^$/ d' -e 's/^/--build-arg /g' | tr '\n' ' ') \
    .
```